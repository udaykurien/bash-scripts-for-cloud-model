#!/bin/bash

# The script contains the paths to individual instances of the simulation.
# External verification scripts are called from within the loops in this script.

# Path to base simulation directory
pathBaseSimulation="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Path to base log directory
pathBaseLog="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2/Logs"

# Name of the log file
# nameLogFile="R30r30-R40r40-R50r50-gomic2ihydro0-gomic2ihydro1-collision.log"
# nameLogFile="R30-50_r30-50_rbyR0.2-0.2-1.0_edr0.002-0.050_microphysics_spinup.log"
nameLogFile=test11.log

# Final path to log file
pathLogFile="$pathBaseLog/$nameLogFile"

# Path to subscripts
pathSubScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/verification_scripts_for_collision_efficiency_master_bidisperse"

# Define run number to be included in the log file
echo "Enter run number"
read runNumber

# Paths to individual simulations
# General format: pathVar<#>="$pathBase/<EDR>/R<#>/R<#>r<#>/gomic<#>ihydro<#>"
pathSimulation01="$pathBaseSimulation/0.002/R30/R30r30/gomic2ihydro0"
pathSimulation02="$pathBaseSimulation/0.005/R40/R40r40/gomic2ihydro1"
# pathSimulation03="$pathBaseSimulation/0.005/R30/R30r30/gomic2ihydro0"
# pathSimulation04="$pathBaseSimulation/0.005/R30/R30r30/gomic2ihydro1"
pathSimulation05="$pathBaseSimulation/0.005/R50/R50r50/gomic2ihydro1"
pathSimulation06="$pathBaseSimulation/0.010/R30/R30r30/gomic2ihydro1"
# pathSimulation07="$pathBaseSimulation/0.050/R30/R30r30/gomic2ihydro1"

pathSimulationSingle="$pathBaseSimulation/0.020/R50/R50r50/gomic2ihydro0"

counter=1

# Write run number to log file before writing other data
echo "--------------" >> $pathLogFile
echo "Run Number: $runNumber" >> $pathLogFile
echo "--------------" >> $pathLogFile

# Labelling columns
# printf "SNo \t R \t r \t EDR \t nstop \t wall \t \t gomic \t ihydro \t Col. \t Run Time \t\n" >> $pathLogFile

printf "%-5s %-8s %-8s %-8s %-7s %-9s %-13s %-7s %-8s %-7s %-10s\n" "SNo" "R" "r" "TND" "EDR" "nstop" "Wall" "Gomic" "iHydro" "Col." "Run time" >> $pathLogFile

for pathSimulation in $pathSimulation06
do
	cd $pathSimulation
	
	# Subscripts may be sourced directly beneath this
	source $pathSubScripts/check_col_no_and_run_time.sh
	source $pathSubScripts/check_simulation_parameters.sh
	
	# Shell instructions can be included directly beneath this
	
	# Recording data to file
	printf "%-5s %-8s %-8s %-8s %-7s %-9s %-13s %-7s %-8s %-7s %-10s\n" ""$counter"a." "$dropSizeR_ret" "$dropSizer_ret" "$tnd_ret" "$edr_ret" "$nstop_ret" "$wall_ret" "$gomic_ret" "$ihydro_ret" "$colNumber" "$runTime" >> $pathLogFile


	# Incrementing counter
	counter=$(echo "$counter+1" | bc)
			
done
