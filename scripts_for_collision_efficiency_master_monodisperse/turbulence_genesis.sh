#!/bin/bash

# This script prepares the sources code for the initial run (i.e. turbulence spin up, gomic=0) for different values of EDR.

#---------------------------- V	A R I A B L E  D E C L A R A T I O N --------------------------------#
												     
nstop=100000												
sbatch=0-05:00:00
basePath="/home/ukurien/projects/def-yaumanko/ukurien/turbulence_spin_up_runs"

#------------------------------------------ E N D --------------------------------------------------#

for  EDR in 0.000 0.002 0.005 0.010 0.020 0.050
do
		finalPath="$basePath/$EDR"
		cd $finalPath
		echo $finalPath
		pwd

		# Checking and modifying cloned content to generate multiple model instances
		# -------------------------------------------------------------------------
		# Implementation:
		# 1. Use grep to check for the pattern
		# 2. If the pattern is present (grep exit status = 0) no changes are made
		# 3. If the pattern is absent (grep exit status != 0). SED is used to update the pattern

		
		# Illustration of implementation on nstop (contained within main.F90)
		# -------------------------------------------------------------------
		# Checking if pattern is present
		grep -q "nstop    = $nstop" main.F90
		
		# Recording exit status of grep
		exitStatus1=$?

		# Modification of file parameters (via sed) contingent on exit status
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "148 c nstop    = $nstop              ! number of timesteps in current restart block" main.F90
		fi
		#--------------------------------------------------------------------
		# This implementation is here on forth applied to other file contents

		# sbatch
		# ------
		grep -q "#SBATCH --time=$sbatch" run_graham.sh
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/#SBATCH --time=[0-9]-[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/#SBATCH --time=$sbatch/" run_graham.sh
		fi
	
		# job name
		# --------
		sed -i "s/#SBATCH --job-name=.*/#SBATCH --job-name=E$EDR/" run_graham.sh # . -> matches any char, * matches all incidents of preceeding regex

		# gomic
		# -----
		grep -q "gomic= 0" param.inc
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/gomic= [0-9]/gomic= 0/" param.inc
		fi
		
		# ihydro
		# ------
		grep -q "ihydro   = 0" main.F90
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/ihydro   = [0-9]/ihydro   = 0/" main.F90
		fi

#		# drop radius
#		# -----------
#		grep -q "r=${DropSize}.d-6" idrops.F90
#		exitStatus1=$?
#		if [ $exitStatus1 -gt 0 ]
#		then
#			sed -i "s/r=[0-9][0-9].d-6/r=${DropSize}.d-6/" idrops.F90
#		fi

		# EDR
		# ---
		grep -q "edr      = $EDR" main.F90
		exitStatus1=$?
		if [ $exitStatus1 -gt 0 ]
		then
			sed -i "s/edr      = [0-9].[0-9][0-9]/edr      = $EDR/" main.F90
		fi

done


		





