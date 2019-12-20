#!/bin/bash

# This script preps for the next model run

pathBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"
pathScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/scripts_for_collision_efficiency_master_bidisperse_MODULAR"

# Gathering info on data to be prepped. The values defined here must match those defined in genesis.sh
	
# Drop sizes
dropSizeLB=30
dropSizeUB=50
dropSizeInc=10
	
# Ratio of radii of collected (r) and collector (R) droplets
lbrbyR=0.1
ubrbyR=0.9
incrbyR=0.1

# Eddy disspation rates
declare -r edr1=0.000
declare -r edr2=0.002
declare -r edr3=0.005
declare -r edr4=0.010
declare -r edr5=0.020
declare -r edr6=0.050


# Determine if simulations for DSDs, EDRs and flags different from those specified in the subsequent sections need to be prepped
choiceOptionalRuns="No"

# Defining arrays of parameters for additional runs
# List of collector drop sizes
array_collector_drop_sizes=( 30 40 40 50 30 )
# List of collected drop sizes
array_collected_drop_sizes=( 30 40 40 50 30 )
# List of EDRs
array_edrs=( 0.002 0.002 0.002 0.002 0.005 )
# List of ihydro flags
array_ihydro=( 1 0 1 0 1 )

# Inform user of options
echo -------------------------------------------------------------------------------------------------------------------
echo ----------------------------------
echo "| Please specify gomic flag used |"
echo ----------------------------------
echo Note the following:
echo gomic = 0: will spawn gomic1 with appropriately modified flags and restart files  
echo gomic = 1: will spawn 1. gomic2ihydro0 and 2. gomic2ihydro1 with appropriately modified flags and restart files
echo gomic = 2: will appopriately modify the restart files of 1. gomic2ihydro0 and 2. gomic2ihydro1 for the next iteration of the simulation. Additionally, you will be presented with the option to modify simulation run times
echo ------------------------------------------------------------------------------------------------------------------
read gomicFlag


# Allow the user to modify the simulation run time
echo Do you want to change nstop and sbatch? \(y/n\)
read varTimeStep
if [ "$varTimeStep" == "y" ]
then
	echo Enter new nstop
	read nstopNew
	echo Enter new sbatch
	read sbatchNew
fi

if [ $gomicFlag -eq 0 ] 
then
	# Initiating loop to cycle throug paths
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do	
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)
				source $pathScripts/called_operations_4_flag_gomic0.sh
			done
		done
	done
	# Additonal runs	
	if [ $choiceOptionalRuns = "Yes" ]
	then
		for (( counter_4_extra_runs=0; counter_4_extra_runs<=${#array_edrs[@]}; counter_4_extra_runs=$counter_4_extra_runs+1 ))
		do
			dropSize=${array_collector_drop_sizes[$counter_4_extra_runs]}
			colDropSize=${array_collected_drop_sizes[$counter_4_extra_runs]}
			EDR=${array_edrs[$counter_4_extra_runs]}
			source $pathScripts/called_operations_4_flag_gomic0.sh
		done
	fi


elif [ $gomicFlag -eq 1 ]
then
	#Initiating loop to cycle through paths
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)
				source $pathScripts/called_operations_4_flag_gomic1.sh
			done
		done
	done
	# Additonal runs	
	if [ $choiceOptionalRuns = "Yes" ]
	then
		for (( counter_4_extra_runs=0; counter_4_extra_runs<=${#array_edrs[@]}; counter_4_extra_runs=$counter_4_extra_runs+1 ))
		do
			dropSize=${array_collector_drop_sizes[$counter_4_extra_runs]}
			colDropSize=${array_collected_drop_sizes[$counter_4_extra_runs]}
			EDR=${array_edrs[$counter_4_extra_runs]}
			source $pathScripts/called_operations_4_flag_gomic1.sh
		done
	fi

elif [ $gomicFlag -eq 2 ]
then
	# Initiating loops to cycle through paths
	for EDR in $edr6 # $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc))
		do
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				for ihydroChoice in 0 1
				do
					colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)
					source $pathScripts/called_operations_4_flag_gomic2.sh
				done
			done
		done
	done
	# Additonal runs	
	if [ $choiceOptionalRuns = "Yes" ]
	then
		for (( counter_4_extra_runs=0; counter_4_extra_runs<=${#array_edrs[@]}; counter_4_extra_runs=$counter_4_extra_runs+1 ))
		do
			ihydroChoice=${array_ihydro[$counter_4_extra_runs]}
			dropSize=${array_collector_drop_sizes[$counter_4_extra_runs]}
			colDropSize=${array_collected_drop_sizes[$counter_4_extra_runs]}
			EDR=${array_edrs[$counter_4_extra_runs]}
			source $pathScripts/called_operations_4_flag_gomic2.sh
		done

	fi
fi

