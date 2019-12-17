#!/bin/bash

# This script is intended to be called from a calling script.
# This script retrieves the number of collisions and the run time for each completed simulation.
# The data is stored in the appropriate log file (defined in the calling script).

# Retrieve total number of collissions
colNumber=$(wc -l < $pathSimulation/RUN_aerosol.coldat) 

# Retrieve tail of stdout_graham (simulation run time)
# runTime=$(tail -n 1 $pathSimulation/stdout_graham | cut -d' ' -f15-16)
 runTime=$(tail -n 1 $pathSimulation/stdout_graham | cut -d' ' -f9-11)
# runTime=$(tail -n 1 $pathSimulation/stdout_graham)



