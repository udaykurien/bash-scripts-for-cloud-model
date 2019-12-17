#!/bin/bash

# The script contains the loops to cycle through all of the simulation files.
# External verification scripts are called from within the loops in this script.

# Path to base simulation directory
pathBaseSimulation="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Path to subscripts
pathSubScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/correction_scripts"

# Loop variables
dropSizeLB=30
dropSizeUB=50
dropSizeInc=10

lbrbyR=0.1
ubrbyR=1.0
rbyRInc=0.1

edr1=0.000
edr2=0.002
edr3=0.005
edr4=0.010
edr5=0.020
edr6=0.050

finalDir1="gomic0"
finalDir2="gomic1"
finalDir3="gomic2ihydro0"
finalDir4="gomic2ihydro1"

for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
do
	for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc ))
	do
		for rbyR in $(seq $lbrbyR $rbyRInc $ubrbyR)
		do
			# Calculating size of collected drop based on dropSize and rbyR
			colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)

			for finalDir in $finalDir2
			do
				# Constructing path to the directory
				pathSimulation="$pathBaseSimulation/$EDR/R$dropSize/R"$dropSize"r"$colDropSize"/$finalDir"
				# Check if pathSimulation exists before extracting data (this is necessary since completed simulations maybe shifted out of this directory)
				echo $pathSimulation
				if test -d $pathSimulation
				then
					# Enter the directory
					cd $pathSimulation
					echo directory present
					pwd
                                        
				        #################################################	
					# Subscripts may be sourced directly beneath this
					#################################################
					# source $pathSubScripts/revert_gomic2_records.sh
									
					##########################################################
					# Shell instructions can be included directly beneath this
					##########################################################
					sed -i "7s/#SBATCH --account=def-yaumanko/#SBATCH --account=rrg-yaumanko-ab/" run_graham.sh
					#sed -i "/#SBATCH --time=1-00:00:00/c\#SBATCH --time=01-00:00:00" run_graham.sh
					#timeStep=grep "nstop    = [0-9]" main.F90 | cut -b 12-19
					sed -i "148s/nstop    =$timeStep/c\\nstop    =$timeStep" main.F90

				fi
			done

		done
	done
done

