#!/bin/bash

# This script preps for the next model run

pathBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Gathering info on data to be prepped. The values defined here must match those defined in genesis.sh
	
# Drop sizes
dropSizeLB=30
dropSizeUB=50
dropSizeInc=10
	
# Ratio of radii of collected (r) and collector (R) droplets
lbrbyR=0.2
ubrbyR=0.8
incrbyR=0.2

# Eddy disspation rates
declare -r edr1=0.000
declare -r edr2=0.002
declare -r edr3=0.005
declare -r edr4=0.010
declare -r edr5=0.020
declare -r edr6=0.050


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


if [ $gomicFlag -eq 0 ] 
then
		
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

	# Initiating loop to cycle throug paths
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do	
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)	

				# Cloning model and output files to new directory
				# -----------------------------------------------
				pathModel="$EDR/R$dropSize/R"$dropSize"r$colDropSize"
				pathOrigin="$pathBase/$pathModel/gomic0"
				pathDestination="$pathBase/$pathModel/gomic1"
				
				echo Creating gomic1
				mkdir -p $pathDestination
				echo
				
				echo Cloning gomic0 to gomic1
				cp -r $pathOrigin/* $pathDestination/
				echo

				# Naming restart files
				# --------------------
				cd $pathDestination/
				mv Zk4.out.ncf Zk.in.ncf
				echo

				# Modifying model flags for next run
				# ----------------------------------
				echo Changing value of gomic flag from 0 to 1, in gomic1
				sed -i 's/gomic= 0/gomic= 1/g' param.inc
				
				# Modifying job run times
				# -----------------------
				if [ "$varTimeStep" == "y" ]
				then
					sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
					sed -i "148 c nstop    =$nstopNew" main.F90
				fi	
				
				
				# Modifying job name
				# ------------------
				sed -i "3s/#SBATCH --job-name=.*/#SBATCH --job-name=$dropSize$colDropSize$EDR/" run_graham.sh 
				echo	
			done
		done
	done


elif [ $gomicFlag -eq 1 ]
then
		# Current simulation time /(obtained from Rr1010/)
#		echo The current nstop and sbatch are \(obtained from Rr1010\):
#		nStop=$(grep "nstop    =" $pathBase/0.01/Rr1010/gomic0/main.F90)
#		echo "nstop: $nStop"
#		sBatch=$(grep 'SBATCH --time' $pathBase/0.01/Rr1010/gomic0/run_graham.sh) 
#		echo "SBATCH: $sBatch"
#		echo

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
		
		#Initiating loop to cycle through paths
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB;dropSize=$dropSize+$dropSizeInc))
		do			
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)	
			
				# Cloning model and output files to new directories
				# -------------------------------------------------
				pathModel="$EDR/R$dropSize/R"$dropSize"r$colDropSize"
				pathOrigin=$pathBase/$pathModel/gomic1
				pathDestination1=$pathBase/$pathModel/gomic2ihydro0
				pathDestination2=$pathBase/$pathModel/gomic2ihydro1
				
				echo Creating gomic2ihydro0
				mkdir -p $pathDestination1
				echo

				echo Creating gomic2ihydro1
				mkdir -p $pathDestination2
				echo

				echo Cloning gomic1 to gomic2ihydro0
				cp -r $pathOrigin/* $pathDestination1/
				echo

				echo Cloning gomic1 to gomic2ihydro1
				cp -r $pathOrigin/* $pathDestination2/
				echo

				
				# Shifting into gomic2ihydro0 folder
				#-----------------------------------
				cd $pathDestination1

				# Naming restart files
				# --------------------
				echo Naming droplet distribution and turbulent restart files in gomic2ihydro0
				if test -f Zk4.out.ncf
				then	
					mv Zk.in.ncf Zk.in.ncf.old1
					mv Zk4.out.ncf Zk.in.ncf
				fi
				mv drop4.out.ncf drop.in.ncf
				echo

				# Modifying model flags for next run
				# ----------------------------------
				echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
				sed -i 's/gomic= 1/gomic= 2/g' param.inc
				sed -i 's/ihydro   = 0/ihydro   = 0/g' main.F90
				echo

				# Modifying nstop and sbatch values
				# ---------------------------------
				if [ "$varTimeStep" == "y" ]
				then
					sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
					sed -i "148 c nstop    =$nstopNew" main.F90
				fi	
				
				# Modifying job name
				# ------------------
				sed -i "3s/#SBATCH --job-name=.*/#SBATCH --job-name=0.$dropSize$colDropSize$EDR/" run_graham.sh 

				# Shifting into gomic2ihydro1 folder
				# ----------------------------------
				cd $pathDestination2

				# Naming restart files
				# --------------------
				echo Naming droplet distribution and turbulent restart files in gomic2ihydro1
				if test -f Zk4.out.ncf
				then	
					mv Zk.in.ncf Zk.in.ncf.old1
					mv Zk4.out.ncf Zk.in.ncf
				fi
				mv drop4.out.ncf drop.in.ncf
				echo 

				# Modifying model flags for next run
				# ----------------------------------
				echo Changing flags gomic and ihydro from 1 and 0 to 2 and 1, respectively
				sed -i 's/gomic= 1/gomic= 2/g' param.inc
				sed -i 's/ihydro   = 0/ihydro   = 1/g' main.F90
				echo
				
				# Modifying nstop and sbatch values
				# ---------------------------------
				if [ "$varTimeStep" == "y" ]
				then
					sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
					sed -i "148 c nstop    =$nstopNew" main.F90
				fi	
				
				# Modifying job name
				# ------------------
				sed -i "3s/#SBATCH --job-name=.*/#SBATCH --job-name=1.$dropSize$colDropSize$EDR/" run_graham.sh

			done
		done
	done

elif [ $gomicFlag -eq 2 ]
then
	# Current simulation time /(obtained from Rr1010/)
#	echo The current nstop and sbatch are \(obtained from Rr1010\):
#	nStop=$(grep "nstop    =" $pathBase/Rr1010/gomic0/main.F90)
#	echo "nstop: $nStop"
#	sBatch=$(grep 'SBATCH --time' $pathBase/Rr1010/gomic0/run_graham.sh) 
#	echo "SBATCH: $sBatch"
#	echo

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
		
	for EDR in $edr2 $edr3 $edr4 $edr5 $edr6
	do
		for (( dropSize=$dropSizeLB; dropSize<=$dropSizeUB; dropSize=$dropSize+$dropSizeInc))
		do
			for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
			do
				colDropSize=$(echo "scale=0;($dropSize*$rbyR)/1" | bc)	
				# Generating path variable
				# ------------------------
				pathModel="$EDR/R$dropSize/R"$dropSize"r$colDropSize"
				pathDestination1="$pathBase/$pathModel/gomic2ihydro0"
				pathDestination2="$pathBase/$pathModel/gomic2ihydro1"

				if test -d $pathDestination1
				then
					# Shifting into gomic2ihydro0
					# ---------------------------
					cd $pathDestination1
					
					# Making changes to SBATCH and nstop
					# ----------------------------------
					# The 'c' command tells sed to replace the entire line (which contains the pattern specified in sed) with a new pattern. 
					# Remember to use double quotes to allow the shell to expand the variables.
					if [ "$varTimeStep" == "y" ]
					then
						sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
						# 148 -> line number to be changed, c -> replace entire line with pattern that follows. Double quotes to allow shell expansion of variables.
						# For more robust text editing consider using gawk.
						sed -i "148 c nstop    =$nstopNew" main.F90  
					fi
					
					# Renaming restart file, deprecating and preserving last restart file
					# -------------------------------------------------------------------
					# Count the number of old restart files and store them in variable counter
					counterZk=$(ls -l Zk.in.ncf* | wc -l)
					counterDrop=$(ls -l drop.in.ncf* | wc -l)
					
					# Appending the count to obsolete restart files and naming new restart files
					if test -f Zk4.out.ncf
					then	
						mv Zk.in.ncf Zk.in.ncf.old$counterZk
						mv Zk4.out.ncf Zk.in.ncf
					fi

					if test -f drop4.out.ncf
					then					
						mv drop.in.ncf drop.in.ncf.old$counterDrop
						mv drop4.out.ncf drop.in.ncf
					fi

					# Backing up the output files
					# ---------------------------
					# If backup folder does not exist then create it
					if ! test -d BackUp
					then
						mkdir BackUp
					fi


					# Copy output file to back
					cp -r RUN_aerosol* BackUp/

					# Shift in to BackUp
					cd BackUp
					
					# Count existing output files of a kind
					counterRUN=$(ls -l RUN_aerosol.coldat* | wc -l)

					# Append counter to the backup files
					mv RUN_aerosol.coldat RUN_aerosol.coldat.old$counterRUN
					mv RUN_aerosol.dispdat RUN_aerosol.dispdat.old$counterRUN
					mv RUN_aerosol.dsd RUN_aerosol.dsd.old$counterRUN
					mv RUN_aerosol.dsdlog RUN_aerosol.dsdlog.old$counterRUN
					mv RUN_aerosol.eng RUN_aerosol.eng.old$counterRUN
					mv RUN_aerosol.list RUN_aerosol.list.old$counterRUN
					mv RUN_aerosol.nc RUN_aerosol.nc.old$counterRUN
					mv RUN_aerosol.para RUN_aerosol.para.old$counterRUN
					mv RUN_aerosol.spc RUN_aerosol.spc.old$counterRUN
					mv RUN_aerosol.track RUN_aerosol.track.old$counterRUN
				fi


				if test -d $pathDestination2
				then
					# Shifting into gomic2ihydro1
					# ---------------------------
					cd $pathDestination2
					
					# Making changes to SBATCH and nstop
					# ----------------------------------
					# The 'c' command tells sed to replace the entire line (which contains the pattern specified in sed) with a new pattern. 
					# Remember to use double quotes to allow the shell to expand the variables.
					if [ "$varTimeStep" == "y" ]
					then
						sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
						# 148 -> line number to be changed, c -> replace entire line with pattern that follows. Double quotes to allow shell expansion of variables.
						# For more robust text editing consider using gawk.
						sed -i "148 c nstop    =$nstopNew" main.F90  
					fi

					# Renaming restart file, deprecating and preserving last restart file
					# -------------------------------------------------------------------

					# Count the number of old restart files and store them in variable counter
					counterZk=$(ls -l Zk.in.ncf* | wc -l)
					counterDrop=$(ls -l drop.in.ncf* | wc -l)
					
					# Appending the count to obsolete restart files and naming new restart files
					if test -f Zk4.out.ncf
					then	
						mv Zk.in.ncf Zk.in.ncf.old$counterZk
						mv Zk4.out.ncf Zk.in.ncf
					fi
					if test -f drop4.out.ncf
					then
						mv drop.in.ncf drop.in.ncf.old$counterDrop
						mv drop4.out.ncf drop.in.ncf
					fi
					
					# Backing up the output files
					# ---------------------------
					# If backup folder does not exist then create it
					if ! test -d BackUp
					then
						mkdir BackUp
					fi


					# Copy output file to back
					cp -r RUN_aerosol* BackUp/

					# Shift in to BackUp
					cd BackUp
					
					# Count existing output files of a kind
					counterRUN=$(ls -l RUN_aerosol.coldat* | wc -l)

					# Append counter to the backup files
					mv RUN_aerosol.coldat RUN_aerosol.coldat.old$counterRUN
					mv RUN_aerosol.dispdat RUN_aerosol.dispdat.old$counterRUN
					mv RUN_aerosol.dsd RUN_aerosol.dsd.old$counterRUN
					mv RUN_aerosol.dsdlog RUN_aerosol.dsdlog.old$counterRUN
					mv RUN_aerosol.eng RUN_aerosol.eng.old$counterRUN
					mv RUN_aerosol.list RUN_aerosol.list.old$counterRUN
					mv RUN_aerosol.nc RUN_aerosol.nc.old$counterRUN
					mv RUN_aerosol.para RUN_aerosol.para.old$counterRUN
					mv RUN_aerosol.spc RUN_aerosol.spc.old$counterRUN
					mv RUN_aerosol.track RUN_aerosol.track.old$counterRUN
				fi
			
			done
		done
	done
fi

