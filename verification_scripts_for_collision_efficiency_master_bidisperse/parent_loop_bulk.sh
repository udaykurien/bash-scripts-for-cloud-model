#!/bin/bash

# The script contains the loops to cycle through all of the simulation files.
# External verification scripts are called from within the loops in this script.

# Path to base simulation directory
pathBaseSimulation="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Path to base log directory
pathBaseLog="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2/Logs/Bidisp_R304050_rbyR1to9_collision_logs"

# Name of the log file
# nameLogFile="R30r30-R40r40-R50r50-gomic2ihydro0-gomic2ihydro1-collision.log"
# nameLogFile="R30-50_r30-50_rbyR0.2-0.2-1.0_edr0.002-0.050_microphysics_spinup.log"
tempLogNo=$(ls -l $pathBaseLog/tempLogColBulk_bidisp_R304050_rbyR1to9__No*.log | wc -l)
nameLogFile=tempLogColBulk_bidisp_R304050_rbyR1to9__No$tempLogNo.log

# Final path to log file
pathLogFile="$pathBaseLog/$nameLogFile"

# Creation of log file
touch  $pathLogFile

# Path to subscripts
pathSubScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/verification_scripts_for_collision_efficiency_master_bidisperse"

# Define run number to be included in the log file
echo "Enter run number"
read runNumber

# Loop variables
dropSizeLB=30
dropSizeUB=50
dropSizeInc=10

lbrbyR=1.0
ubrbyR=1.0
rbyRInc=0.2

edr1=0.000
edr2=0.002
edr3=0.005
edr4=0.010
edr5=0.020
edr6=0.050

counter=1

# Write run number to log file before writing other data
echo "--------------" >> $pathLogFile
echo "Run Number: $runNumber" >> $pathLogFile
echo "--------------" >> $pathLogFile

# Labelling columns
# printf "SNo \t R \t r \t EDR \t nstop \t wall \t \t gomic \t ihydro \t Col. \t Run Time \t\n" >> $pathLogFile

printf "%-5s %-8s %-8s %-8s %-7s %-9s %-13s %-7s %-8s %-7s %-10s\n" "SNo" "R" "r" "TND" "EDR" "nstop" "Wall" "Gomic" "iHydro" "Col." "Run time" >> $pathLogFile

for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
do
	for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc ))
	do
		for rbyR in $(seq $lbrbyR $rbyRInc $ubrbyR)
		do
			# Calculating size of collected drop based on dropSize and rbyR
			colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)

			# ----------------------------------
			# Extracting data from gomic2ihydro0
			# ----------------------------------
			# Final directory to scan
			finalDir="gomic2ihydro0"
			
			# Constructing path to the directory
			pathSimulation="$pathBaseSimulation/$EDR/R$dropSize/R"$dropSize"r"$colDropSize"/$finalDir"
			# Check if pathSimulation exists before extracting data (this is necessary since completed simulations maybe shifted out of this directory)
			if test -d $pathSimulation
			then
			
				# Subscripts may be sourced directly beneath this
				source $pathSubScripts/check_col_no_and_run_time.sh
				source $pathSubScripts/check_simulation_parameters.sh
				
				# Shell instructions can be included directly beneath this
				
				# Recording data to file
				printf "%-5s %-8s %-8s %-8s %-7s %-9s %-13s %-7s %-8s %-7s %-10s\n" ""$counter"a." "$dropSizeR_ret" "$dropSizer_ret" "$tnd_ret" "$edr_ret" "$nstop_ret" "$wall_ret" "$gomic_ret" "$ihydro_ret" "$colNumber" "$runTime" >> $pathLogFile


				# ----------------------------------
				# Extracting data from gomic2ihydro1
				# ----------------------------------
				# Final directory to scan
				finalDir="gomic2ihydro1"
				
				# Constructing path to the directory
				pathSimulation="$pathBaseSimulation/$EDR/R$dropSize/R"$dropSize"r"$colDropSize"/$finalDir"
				
				# Subscripts may be sourced directly beneath this
				source $pathSubScripts/check_col_no_and_run_time.sh
				source $pathSubScripts/check_simulation_parameters.sh
				
				# Shell instructions can be included directly beneath this
				
				# Recording data to file
				printf "%-5s %-8s %-8s %-8s %-7s %-9s %-13s %-7s %-8s %-7s %-10s\n" ""$counter"b." "$dropSizeR_ret" "$dropSizer_ret" "$tnd_ret" "$edr_ret" "$nstop_ret" "$wall_ret" "$gomic_ret" "$ihydro_ret" "$colNumber" "$runTime" >> $pathLogFile
	#
				#echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- " >> $pathLogFile

				# Incrementing counter
				counter=$(echo "$counter+1" | bc)
			fi
			
		done
	done
done

# Preview log file
cat $pathLogFile
