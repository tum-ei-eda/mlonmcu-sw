/*
 * Copyright (C) 2021 ETH Zurich, University of Bologna and GreenWaves
 * Technologies
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <string.h>
#include <stdint.h>
#include <stdio.h>

#include "cluster/cl_dma.h"
#include "cluster/cl_pmsis_types.h"
#include "cluster/cluster_data.h"
#include "cluster/fc_to_cl_delegate.h"
#include "cluster/cluster_ctrl_unit.h"
#include "cluster/cl_synchronisation.h"
#include "cluster/cluster_icache_ctrl.h"
#include "cluster/cl_team_internal.h" /* TODO: remove */
#include "cluster/cl_team.h"
#include "cluster/event_unit.h"
#include "cl_l1_malloc.h"

#include "target.h"
#include "link.h"
#include "pmsis_task.h"
#include "pmsis_types.h"
#include "events.h"
#include "os.h"

#define NB_CLUSTER		  (1)
#define CL_MASTER_CORE_STACK_SIZE (0x800) /*!< Stack size for Cluster Master core, 2kB. */
#define CL_SLAVE_CORE_STACK_SIZE  (0x400) /*!< Stack size for Cluster Slave cores, 1kB. */

#ifdef DEBUG
#define PRINTF(fmt, ...) printf("%s:%d: " fmt, __func__, __LINE__, ##__VA_ARGS__);
#else
#define PRINTF(...) ((void)0)
#endif

/* TODO: hack */
#define pi_malloc pi_l2_malloc
#define pi_free	  pi_l2_free

// spinlock left at the disposal of the os to synchronise printfs with cluster
spinlock_t cluster_printf_spinlock;

// ----------------------------------
// Need to be rewritten with OS agnostic symbols
extern char __l1_preload_start;
extern char __l1_preload_start_inL2;
extern char __l1_preload_size;

extern char __l1FcShared_start;
extern char __l1FcShared_size;

extern char __heapsram_start;
extern char __heapsram_size;
// ----------------------------------

PI_L1 pi_cl_dma_cmd_t *fifo_first;
PI_L1 pi_cl_dma_cmd_t *fifo_last;

struct cluster_driver_data *__per_cluster_data[NB_CLUSTER] = {NULL};

static inline void __cluster_start(struct pi_device *device);
static inline void __cluster_start_async(struct pi_device *device, pi_task_t *async_task);
static inline int __cluster_stop(struct pi_device *device);
static inline int __cluster_stop_async(struct pi_device *device, pi_task_t *async_task);
static inline int __cluster_has_task(struct cluster_driver_data *data);

static void __cluster_free_device_event_func(void *arg);

static inline void pi_push_cluster_task(struct cluster_driver_data *data,
					struct pi_cluster_task *task);
static inline void cl_pop_cluster_task(struct cluster_driver_data *data);

// L2 data as L1 cluster might disappear, and is shared between cluster and FC

void cl_task_finish(void);

// accessible through second level ptr or through ioctl
static const struct cluster_driver_api __spec_cluster_api = {
	.send_task = pi_cluster_send_task_to_cl,
	.send_task_async = pi_cluster_send_task_to_cl_async,
	.wait_free = pi_cluster_wait_free,
	.wait_free_async = pi_cluster_wait_free_async};

static const struct pi_device_api __cluster_api = {.open = pi_cluster_open,
						   .close = pi_cluster_close,
						   .open_async = pi_cluster_open_async,
						   .close_async = pi_cluster_close_async,
						   .ioctl = pi_cluster_ioctl,
						   .ioctl_async = pi_cluster_ioctl_async};

static const struct pi_cluster_conf __cluster_default_conf = {.device_type = PI_DEVICE_CLUSTER_TYPE,
							      // by default, us cluster 0
							      .id = 0,
							      // default for heap if no address
							      // provided by user.
							      .heap_start = (void *)0x10000004,
							      .heap_size = 0x400};


void cl_task_finish(void)
{
	int id = __native_cluster_id();

	// TODO: send callback if it exists
	// -----
	struct cluster_driver_data *data = __per_cluster_data[id];
	struct pi_cluster_task *task = data->task_first;

	PRINTF("cl_task_finish: task=%p\n", task);

	// clean up finished cluster task
	cl_pop_cluster_task(data);
	if (task->completion_callback) {
		pi_cl_send_task_to_fc(task->completion_callback);
	}
	// -----
	// PRINTF("cl_task_finish: data=%p\n",data);
}

/**
 * \brief open the cluster described by device with given conf
 */
int pi_cluster_open(struct pi_device *device)
{
	void *conf = device->config;
	PRINTF("device=%p\n", device);
	device->api = (struct pi_device_api *)pi_malloc(sizeof(struct pi_device_api));

	memcpy(device->api, &__cluster_api, sizeof(struct pi_device_api));
	if (conf == NULL) {
		// In this case, heap will be at the first address of L1 cluster
		device->config = pi_malloc(sizeof(struct pi_cluster_conf));
		PRINTF("device->config=%p\n", device->config);
		memcpy(device->config, &__cluster_default_conf, sizeof(struct pi_cluster_conf));
	}

	struct pi_cluster_conf *_conf = (struct pi_cluster_conf *)device->config;
	struct cluster_driver_data *cl_data = __per_cluster_data[_conf->id];
	device->data = cl_data;
	PRINTF("check device->data=%p\n", device->data);
	// if device data has not yet been populated
	if (cl_data == NULL) {
		cl_data = pi_malloc(sizeof(struct cluster_driver_data));
		if (cl_data == NULL) {
			PRINTF("error allocating cluster struct !\n");
			return -11;
		}
		memset(cl_data, 0, sizeof(struct cluster_driver_data));
		__per_cluster_data[_conf->id] = cl_data;
#if !defined(__DISABLE_PRINTF__) && (defined(PRINTF_UART) || defined(PRINTF_SEMIHOST))
		uint8_t cl_nb_cores = pi_cl_cluster_nb_cores();
		uint32_t printf_buffer_size = (uint32_t)PRINTF_BUFFER_SIZE;
		uint32_t buffer_size = cl_nb_cores * printf_buffer_size * sizeof(uint8_t);
		cl_data->printf_buffer = pi_l2_malloc(buffer_size);
		PRINTF("Alloc buffer=%lx, size=%ld\n", cl_data->printf_buffer, buffer_size);
		for (uint8_t i = 0; i < cl_nb_cores; i++) {
			cl_data->printf_buffer_index[i] = 0;
			uint8_t *buffer = &(cl_data->printf_buffer[i * printf_buffer_size]);
			memset(buffer, 0, printf_buffer_size);
		}
#endif /* __DISABLE_PRINTF__ && (PRINTF_UART || PRINTF_SEMIHOST) */
		device->data = __per_cluster_data[_conf->id];
		PRINTF("post-check: device->data=%p\n", device->data);
		pmsis_mutex_init(&(cl_data->task_mutex));
		pmsis_mutex_init(&(cl_data->powerstate_mutex));
		cl_data->task_to_fc = NULL;
		cl_data->hw_barrier_alloc = (uint8_t)CL_ALLOC_INIT_BARRIER;
		PRINTF("per cluster data[%d]=%p\n", _conf->id, __per_cluster_data[_conf->id]);
	}
	_conf->heap_start = (void *)&__heapsram_start;
	_conf->heap_size = (uint32_t)&__heapsram_size;

	PRINTF("before start: device->config=%p\n", device->config);
	PRINTF("before start: _conf:=%p, device->config->heap_start=%p\n", _conf,
	       _conf->heap_start);

	__cluster_start(device);
	mc_fc_delegate_init(NULL);
	return 0;
}

int pi_cluster_open_async(struct pi_device *device, pi_task_t *async_task)
{
	void *conf = device->config;

	// if device has not yet been populated
	if (device->data == NULL) {
		device->api = (struct pi_device_api *)pi_malloc(sizeof(struct pi_device_api));
		memcpy(device->api, &__cluster_api, sizeof(struct pi_device_api));
		if (conf == NULL) {
			// In this case, heap will be at the first address of L1 cluster
			device->config = pi_malloc(sizeof(struct pi_cluster_conf));
			memcpy(device->config, &__cluster_default_conf,
			       sizeof(struct pi_cluster_conf));
		}
		device->data = (void *)pi_malloc(sizeof(struct cluster_driver_data));
		struct cluster_driver_data *_data = (struct cluster_driver_data *)device->data;
		memcpy(device->config, &__cluster_default_conf, sizeof(struct pi_cluster_conf));
	}
	__cluster_start_async(device->data, async_task);
	return 0;
}

int pi_cluster_close(struct pi_device *device)
{
	int ret = __cluster_stop(device);
	if (!ret) {
		struct cluster_driver_data *_data = (struct cluster_driver_data *)device->data;
		// if no task has an active handle on device
		// --> clean up data as everything in L1 is going to be lost
		PRINTF("Cluster clean ups\n");
		struct pi_cluster_conf *_conf = (struct pi_cluster_conf *)device->config;
		/* Clean used mutexes. */
		pmsis_mutex_deinit(&(_data->task_mutex));
		pmsis_mutex_deinit(&(_data->powerstate_mutex));
// free all structures
#if !defined(__DISABLE_PRINTF__) && (defined(PRINTF_UART) || defined(PRINTF_SEMIHOST))
		uint8_t cl_nb_cores = pi_cl_cluster_nb_cores();
		uint32_t printf_buffer_size = (uint32_t)PRINTF_BUFFER_SIZE;
		uint32_t buffer_size = cl_nb_cores * printf_buffer_size * sizeof(uint8_t);
		pi_l2_free(_data->printf_buffer, buffer_size);
#endif /* __DISABLE_PRINTF__ && (PRINTF_UART || PRINTF_SEMIHOST) */
		pi_free(device->api);
		pi_free(device->data);
		__per_cluster_data[_conf->id] = NULL; // pointer makes no sense anymore, reset it
	}
	return ret;
}

int pi_cluster_close_async(struct pi_device *device, pi_task_t *async_task)
{
#if 0
    __cluster_stop_async(device, async_task);

    pi_task_t free_task;
    free_task.id = FC_TASK_CALLBACK_ID;
    free_task.arg[0] = (uint32_t)__cluster_free_device_event_func;
    free_task.arg[1] = (uint32_t)device;
    pi_event_append(async_task, free_task);
#endif
	return 0;
}

int pi_cluster_ioctl(struct pi_device *device, uint32_t func_id, void *arg)
{
	struct pi_device_api *api = device->api;
	struct cluster_driver_api *cluster_api = api->specific_api;
	uint32_t ret = 0;
	switch (func_id) {
	case SEND_TASK_ID: {
		struct pi_cluster_task *cl_task = (struct pi_cluster_task *)arg;
		cluster_api->send_task(device, cl_task);
	} break;
	case WAIT_FREE_ID: {
		cluster_api->wait_free(device);
	} break;
	case OPEN_ID: {
		device->api->open(device);
	} break;
	case CLOSE_ID: {
		device->api->close(device);
	} break;
	default:
		break;
	}

	return ret;
}

int pi_cluster_ioctl_async(struct pi_device *device, uint32_t func_id, void *arg,
			   pi_task_t *async_task)
{
	struct pi_device_api *api = device->api;
	struct cluster_driver_api *cluster_api = api->specific_api;
	uint32_t ret = 0;
	switch (func_id) {
	case SEND_TASK_ASYNC_ID: {
		struct pi_cluster_task *cl_task = (struct pi_cluster_task *)arg;
		cluster_api->send_task_async(device, cl_task, async_task);
	} break;
	case WAIT_FREE_ASYNC_ID: {
		cluster_api->wait_free_async(device, async_task);
	} break;
	case OPEN_ASYNC_ID: {
		api->open_async(device, async_task);
	} break;
	case CLOSE_ASYNC_ID: {
		api->close_async(device, async_task);
	} break;
	default:
		break;
	}
	return ret;
}


static inline void __cluster_free_device_event_func(void *arg)
{
	struct pi_device *device = (struct pi_device *)arg;
	// free all structures
	// free(device->data, sizeof(struct cluster_driver_data));
	// free(device->api->specific_api, sizeof(struct cluster_driver_api));
	// free(device->api, sizeof(struct pi_device_api));
	// free(device, sizeof(struct pi_device));
}

static inline void __cluster_start(struct pi_device *device)
{
	PRINTF("device=%p\n", device);
	struct cluster_driver_data *data = (struct cluster_driver_data *)device->data;
	PRINTF("data=%p\n", data);
	struct pi_cluster_conf *conf = (struct pi_cluster_conf *)device->config;
	pmsis_mutex_take(&data->powerstate_mutex);
	// --- critical zone start ---
	if (!data->cluster_is_on) {
		/* Turn cluster power on. */
		//__pi_pmu_cluster_power_on(); hal_soc_ctrl_cl_isolate_set(0); /*TODO  ? */
		PRINTF("poweron is done\n");

		uint32_t nb_cl_cores = pi_cl_cluster_nb_cores();
		for (uint32_t core_id = 0; core_id < nb_cl_cores; core_id++) {
			// extern uint8_t __irq_vector_base;
			extern uint8_t _start;
			// hal_cl_ctrl_boot_addr_set(ARCHI_CL_CID(0), core_id, (uint32_t)
			// &__irq_vector_base);
			hal_cl_ctrl_boot_addr_set(ARCHI_CL_CID(0), core_id, (uint32_t)&_start);
			// PRINTF("set cluster fetch to %p\n", &_start);
		}
		hal_cl_ctrl_fetch_enable(ARCHI_CL_CID(0), nb_cl_cores);
		PRINTF("enabled cluster fetch\n");
		hal_cl_icache_enable(ARCHI_CL_CID(0));

		/* In case the chip does not support L1 preloading, the initial L1 data are in L2,
		 * we need to copy them to L1 */
#define CLUSTER_BASE			(0x10000000UL)
#define GAP_CLUSTER_TINY_DATA(id, addr) (CLUSTER_BASE + 0x400000 * (id) + (addr & 0xFFF))
		/* TODO: remove macro hack */
		memcpy((char *)GAP_CLUSTER_TINY_DATA(0, (int)&__l1_preload_start),
		       &__l1_preload_start_inL2, (size_t)&__l1_preload_size);

		/* Copy the FC / clusters shared data as the linker can only put it in one section
		 * (the cluster one) */
		memcpy((char *)GAP_CLUSTER_TINY_DATA(0, (int)&__l1FcShared_start),
		       &__l1FcShared_start, (size_t)&__l1FcShared_size);

		PRINTF("conf:%p, heap_start:%p, heap_size:%lx\n", conf, conf->heap_start,
		       conf->heap_size);
		pmsis_l1_malloc_init(conf->heap_start, conf->heap_size);

		int32_t *lock_addr = pmsis_l1_malloc(sizeof(int32_t));
		cl_sync_init_spinlock(&data->fifo_access, lock_addr);
		cl_sync_init_spinlock(&cluster_printf_spinlock, pmsis_l1_malloc(sizeof(uint32_t)));
	}
	data->cluster_is_on++;
	pmsis_mutex_release(&data->powerstate_mutex);
	PRINTF("started cluster\n");
	PRINTF("data ptr: %p\n", data);
}

static inline int __cluster_stop(struct pi_device *device)
{
	struct cluster_driver_data *data = (struct cluster_driver_data *)device->data;
	pmsis_mutex_take(&data->powerstate_mutex);
	// decrement usage counter
	data->cluster_is_on--;

	// if no other tasks are using the cluster, begin poweroff procedure
	if (!data->cluster_is_on) {
		// wait for potential remaining tasks
		//__cluster_wait_termination(device);

		/* Turn cluster power off. */
		// __pi_pmu_cluster_power_off(); hal_soc_ctrl_cl_isolate_set(1)  /* TODO */
	}
	pmsis_mutex_release(&data->powerstate_mutex);
	return data->cluster_is_on;
}

static inline int __cluster_has_task(struct cluster_driver_data *data)
{
	volatile int has_task = 0;
	cl_sync_spinlock_take(&data->fifo_access);
	struct pi_cluster_task *task = data->task_first;
	has_task = !(data->task_first == NULL);
	cl_sync_spinlock_release(&data->fifo_access);
	return has_task;
}

static inline void pi_push_cluster_task(struct cluster_driver_data *data,
					struct pi_cluster_task *task)
{
	// critical section for cluster and fc
	// Use spinlock as it is pretty much the only reliable synchronisation we have
	cl_sync_spinlock_take(&data->fifo_access);
	task->next = NULL;

	PRINTF("task=%p, data->task_first=%p\n", task, data->task_first);
	if (data->task_last == NULL) {
		data->task_first = task;
		data->task_last = task;
	} else {
		data->task_last->next = task;
	}
	PRINTF("task=%p, data->task_first=%p\n", task, data->task_first);
	cl_sync_spinlock_release(&data->fifo_access);
}

static inline void cl_pop_cluster_task(struct cluster_driver_data *data)
{
	// critical section for cluster and fc
	// Uses spinlock as it is pretty much the only reliable synchronisation we have
	cl_sync_spinlock_take(&data->fifo_access);
	struct pi_cluster_task *task = data->task_first;
	data->task_first = task->next;
	if (data->task_first == NULL) {
		data->task_last = NULL;
	}
	cl_sync_spinlock_release(&data->fifo_access);
	if (task->stack_allocated) {
		// put everything back as it was before
		uint32_t stack_size = task->slave_stack_size * ((uint32_t)ARCHI_CLUSTER_NB_PE - 1);
		stack_size += task->stack_size;
		pi_cl_l1_free(NULL, task->stacks, stack_size);
		PRINTF("free %p %ld\n", task->stacks, stack_size);
		task->stacks = NULL;
		task->stack_size = 0;
		task->stack_allocated = 0;
	}
}

static inline void __cluster_start_async(struct pi_device *device, pi_task_t *async_task)
{
	struct cluster_driver_data *cluster_data = (struct cluster_driver_data *)device->data;
}

static inline int __cluster_stop_async(struct pi_device *device, pi_task_t *async_task)
{
	struct cluster_driver_data *cluster_data = (struct cluster_driver_data *)device->data;
	return 0;
}

static inline int __pi_send_task_to_cl(struct pi_device *device, struct pi_cluster_task *task)
{
	struct cluster_driver_data *data = (struct cluster_driver_data *)device->data;
	pmsis_mutex_take(&data->task_mutex);

	if (!data->cluster_is_on) { // cluster is not on, can not reliably use L1 ram
		pmsis_mutex_release(&data->task_mutex);
		return -1;
	}

	/* If Cluster has not finished previous task, wait */

	if (task->nb_cores == 0) {
		task->nb_cores = (uint32_t)pi_cl_cluster_nb_pe_cores();
	}
	task->cluster_team_mask = ((1 << task->nb_cores) - 1);
	// task->nb_cores = task->nb_cores ? task->nb_cores : ARCHI_CLUSTER_NB_PE;

	PRINTF("task->nb_cores:%d\n", task->nb_cores);

	if (task->stacks == NULL) {
		if (task->stack_size == 0) {
			task->stack_size = (uint32_t)CL_MASTER_CORE_STACK_SIZE;
		}
		if (task->slave_stack_size == 0) {
			task->slave_stack_size = (uint32_t)CL_SLAVE_CORE_STACK_SIZE;
		}
		uint32_t stack_size = task->slave_stack_size * ((uint32_t)ARCHI_CLUSTER_NB_PE - 1);
		stack_size += task->stack_size;
		task->stacks = pi_cl_l1_malloc(NULL, stack_size);
		PRINTF("malloc stack %p %ld\n", task->stacks, stack_size);
		if (task->stacks == NULL) {
			pmsis_mutex_release(&(data->task_mutex));
			return -1;
		}
		task->stack_allocated = 1; // to remember freeing memory if allocated by us
	} else {
		task->stack_allocated = 0;
	}

	PRINTF("pushing task to cluster\n");
	pi_push_cluster_task(data, task);

	// Wake cluster up
	PRINTF("waking cluster up\n");
	hal_eu_cluster_evt_trig_set(FC_NOTIFY_CLUSTER_EVENT, 0);
	pmsis_mutex_release(&data->task_mutex);
	return 0;
}

int pi_cluster_send_task_to_cl(struct pi_device *device, struct pi_cluster_task *task)
{
	int32_t ret_send_task = 0;
	pi_task_t task_block;
	PRINTF("creating task\n");
	pi_task_block(&task_block);
	task->completion_callback = &task_block;
	PRINTF("going to send\n");
	ret_send_task = __pi_send_task_to_cl(device, task);
	if (ret_send_task) {
		return ret_send_task;
	}
	PRINTF("going to block on %p\n", &task_block);
	pi_task_wait_on(&task_block);
	PRINTF("block is done\n");
	pi_task_destroy(&task_block);
	PRINTF("destroy is done\n");
	return ret_send_task;
}

int pi_cluster_send_task_to_cl_async(struct pi_device *device, struct pi_cluster_task *task,
				     pi_task_t *fc_task)
{
	task->completion_callback = fc_task;
	while (__pi_send_task_to_cl(device, task)) {
		//__os_native_yield();
		taskYIELD();
	}
	return 0;
}

void pi_cluster_wait_free(struct pi_device *device)
{
	/* If Cluster has not finished previous task, wait */
	while (__cluster_has_task((struct cluster_driver_data *)device->data)) {
		//__os_native_yield();
	}
}

void pi_cluster_wait_free_async(struct pi_device *device, pi_task_t *async_task)
{
}

uint8_t pi_cluster_is_on(void)
{
	for (int i = 0; i < NB_CLUSTER; i++) {
		if (__per_cluster_data[i] && __per_cluster_data[i]->cluster_is_on) {
			return 1;
		}
	}
	return 0;
}


void pi_cluster_conf_init(struct pi_cluster_conf *conf)
{
	conf->device_type = PI_DEVICE_CLUSTER_TYPE;
	conf->id = 0;
}
