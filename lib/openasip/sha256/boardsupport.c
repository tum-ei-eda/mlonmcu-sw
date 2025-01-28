/* Copyright (C) 2019 Clemson University

   Contributor Ola Jeppsson <ola.jeppsson@gmail.com>

   This file is part of Embench.

   SPDX-License-Identifier: GPL-3.0-or-later */

#include <support.h>

void
initialise_board ()
{
}

void __attribute__ ((noinline))
#if !defined(__clang__)
__attribute__ ((externally_visible))
#endif
start_trigger ()
{
}

void __attribute__ ((noinline))
#if !defined(__clang__)
__attribute__ ((externally_visible))
#endif
stop_trigger ()
{
}
