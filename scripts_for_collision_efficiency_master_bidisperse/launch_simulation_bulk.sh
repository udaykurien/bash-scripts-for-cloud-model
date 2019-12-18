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
lbrbyR=1.0
ubrbyR=1.0
incrbyR=0.2

# Gathering info on specific simulation to be launched
echo 'Please specify gomic flag for this instance of the simulation( 0/1/2)'
read gomicFlag
echo 'Please specify ihydro flag for this instance of the simulation (0/1)'
read iHydro

        
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


# Display submitted jobs
# ----------------------
squeue -u ukurien


