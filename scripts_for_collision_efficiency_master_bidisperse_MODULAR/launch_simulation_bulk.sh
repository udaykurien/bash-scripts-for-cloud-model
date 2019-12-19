#!/bin/bash

# This script sequentially launches multiples instances of the simulation

# Restoring modules required at compilation
module restore 20190808

pathBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Gathering info on data to be prepped
declare -r edr1=0.000
declare -r edr2=0.002
declare -r edr3=0.005
declare -r edr4=0.010
declare -r edr5=0.020
declare -r edr6=0.050

# Gathering information on collector drop sizes (should be identical to definitions in genesis.sh)
lbDropSize=30
ubDropSize=50
incDropSize=10

# Gathering information on ratio of radii of collector (R) and collected drops (r) (should be identical to definitions in genesis.sh)
lbrbyR=0.1
ubrbyR=0.9
incrbyR=0.1

# Defining arrays of parameters for additional runs
# List of collector drop sizes
array_collector_drop_sizes=( 30 40 40 50 30 )
# List of collected drop sizes
array_collected_drop_sizes=( 30 40 40 50 30 )
# List of EDRs
array_edrs=( 0.002 0.002 0.002 0.002 0.005 )
# List of ihydro flags
array_ihydro=( 1 0 1 0 1 )
# List of gomic flags
array_gomic=( 1 1 1 1 1)

# Gathering info on specific simulation to be launched
echo 'Please specify gomic flag for this instance of the simulation( 0/1/2)'
read gomicFlag
echo 'Please specify ihydro flag for this instance of the simulation (0/1)'
read iHydro

# Options for choiceAdditionalSim (y/n)
choiceAdditionalSim="n"

        
# gomic = 0 and ihydro = 0
# ------------------------
if [ "$gomicFlag" == "0" ] && [ "$iHydro" == "0" ] 
then
	# Initiating loop to cycle through paths
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( DropSize=$lbDropSize; DropSize<=$ubDropSize;DropSize=$DropSize+$incDropSize))
		do
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($DropSize*$rbyR)/1" | bc)

				# Following path
				# --------------
				pathModel="$EDR/R$DropSize/R"$DropSize"r$colDropSize"
				pathFinal="$pathBase/$pathModel/gomic0"
			
				echo Entering $pathFinal :
				cd $pathFinal
				echo
				
				# Launch simulation from within directory
				# ---------------------------------------
				echo Launching simulation :
				./compileandrun_graham
				sleep 2 # To satisfy computecanada's requirements
				echo
				
			done
		done
	done

	# gomic = 1 and ihydro = 0
	# ------------------------
	elif [ "$gomicFlag" == "1" ] && [ "$iHydro" == "0" ]
	then
		#Initiating loop to cycle through paths
		for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
		do
			for (( DropSize=$lbDropSize; DropSize<=$ubDropSize;DropSize=$DropSize+$incDropSize))
			do			
				for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
				do
					colDropSize=$(echo "scale=0;($DropSize*$rbyR)/1" | bc)

					# Following path
					# --------------
					pathModel="$EDR/R$DropSize/R"$DropSize"r$colDropSize"
					pathFinal="$pathBase/$pathModel/gomic1"

					
					echo Entering $pathFinal:
					cd $pathFinal
					echo

					# Launch simulation from within directory
					# ---------------------------------------
					echo Launching simulation:
					./compileandrun_graham
					sleep 2 # To satisfy computecanada's requirements
					echo

				done
			done
		done

	# gomic = 2 and ihydro = 0
	# -----------------------
	elif [ "$gomicFlag" == "2" ] && [ "$iHydro" == "0" ]
	then
	#Initiating loop to cycle through paths
	for EDR in $edr6 #$edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( DropSize=$lbDropSize; DropSize<=$ubDropSize;DropSize=$DropSize+$incDropSize))
		do			
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
		
				colDropSize=$(echo "scale=0;($DropSize*$rbyR)/1" | bc)

				# Following path
				# --------------
				pathModel="$EDR/R$DropSize/R"$DropSize"r$colDropSize"
				pathFinal="$pathBase/$pathModel/gomic2ihydro0"

				if test -d $pathFinal
				then
					echo Entering $pathFinal:
					cd $pathFinal
					echo

					# Launch simulation from within directory
					# ---------------------------------------
					echo Launching simulation:
					./compileandrun_graham
					sleep 2 # To satisfy computecanada's requirements
					echo
				fi

			done
		done
	done

# gomic = 2 and ihydro = 1
# ------------------------
elif [ "$gomicFlag" == "2" ] && [ "$iHydro" == "1" ]
then
	#Initiating loop to cycle through paths
	for EDR in $edr6 # $edr6 #$edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( DropSize=$lbDropSize; DropSize<=$ubDropSize;DropSize=$DropSize+$incDropSize))
		do			
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($DropSize*$rbyR)/1" | bc)

				# Following path
				# --------------
				pathModel="$EDR/R$DropSize/R"$DropSize"r$colDropSize"
				pathFinal="$pathBase/$pathModel/gomic2ihydro1"

				if test -d $pathFinal
				then
					echo Entering $pathFinal:
					cd $pathFinal
					echo

					# Launch simulation from within directory
					# ---------------------------------------
					echo Launching simulation:
					./compileandrun_graham
					sleep 2 # To satisfy computecanada's requirements
					echo
				fi

			done
		done
	done
fi

if [ $choiceAdditionalSim = "y" ]
then
	for (( counter_4_extra_runs=0; counter_4_extra_runs<=${#array_edrs[@]}; counter_4_extra_runs=$counter_4_extra_runs+1 ))
	do
		ihydroChoice=${array_ihydro[$counter_4_extra_runs]}
		gomicChoice=${array_gomic[$counter_4_extra_runs]}
		dropSize=${array_collector_drop_sizes[$counter_4_extra_runs]}
		colDropSize=${array_collected_drop_sizes[$counter_4_extra_runs]}
		EDR=${array_edrs[$counter_4_extra_runs]}
		
		# Following path
		# --------------
		pathFinal="$pathBase/$EDR/R$dropSize/R"$dropSize"r$colDropSize/gomic"$gomicChoice"ihydro$ihydroChoice"
			if test -d $pathFinal
			then
				echo Entering $pathFinal:
				cd $pathFinal
				echo

				# Launch simulation from within directory
				# ---------------------------------------
				echo Launching simulation:
				./compileandrun_graham
				sleep 2 # To satisfy computecanada's requirements
				echo
			fi
	done
fi

# Display submitted jobs
# ----------------------
squeue -u ukurien


