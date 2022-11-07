cd build/bin
# remember to source pulp-freertos/env/pulp.sh first
# and run the 'make run-gvsoc' first for the helloworld example

rm -rdf gvsim
mkdir gvsim
/mnt/d/time_5_semester_TUM/hiwi/pulpino2/pulp-freertos/support/egvsoc.sh --config-file=pulp@config_file=chips/pulp/pulp.json --platform=gvsoc --dir=gvsim --binary=$PWD/generic_mlif prepare run

cd ../..