#!/bin/bash

# This script logs model parameters into the appropriate log file.

nstop_ret=$(grep "nstop    =[0-9]" $pathSimulation/main.F90 | cut -b 11-)
wall_ret=$(grep "SBATCH --time" $pathSimulation/run_graham.sh | cut -b 16-27)
gomic_ret=$(grep "gomic=" $pathSimulation/param.inc | cut -d' ' -f11)
ihydro_ret=$(grep "ihydro   = [0-9]" $pathSimulation/main.F90 | cut -d' ' -f7)
edr_ret=$(grep "edr      =" $pathSimulation/main.F90 | cut -d' ' -f10) 
dropSizeR_ret=$(sed -n '78p' $pathSimulation/idrops.F90 | cut -d= -f2)
dropSizer_ret=$(sed -n '81p' $pathSimulation/idrops.F90 | cut -d= -f2)
tnd_ret=$(sed -n 37p $pathSimulation/param.inc | cut -d= -f2 | cut -d! -f1 | cut -d' ' -f2)


