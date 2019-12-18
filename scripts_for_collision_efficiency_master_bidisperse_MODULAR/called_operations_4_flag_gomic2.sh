#!/bin/bash

# This script preps for the next model run
# It prepares gomic2ihydro0 and gomic2ihydro1 for the next run

# Generating path variable
# ------------------------
pathModel="$EDR/R$dropSize/R"$dropSize"r$colDropSize"
pathDestination1="$pathBase/$pathModel/gomic2ihydro0"
pathDestination2="$pathBase/$pathModel/gomic2ihydro1"

if [ $ihydroChoice -eq 0 ]
then
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
fi

if [ $ihydroChoice -eq 1 ]
then
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
fi

