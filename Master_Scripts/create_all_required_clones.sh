#!/bin/bash

##################### IMPORTANT - - -  READ BEFORE USING SCRIPT ############################
# STEP 1:	Remove Clone_2 from working directory.
# STEP 2:	Copy backup flies to Clone_2. This contains even r/R with completed turbulent & microphysics spin-ups.
# STEP 3:	Copy turbulent runs into appropriate subdirectories (gomic0 of odd r/R) of Clone_2. 
# STEP 4:	Run correction script to adjust the wall times in run_graham.sh of all gomic0 in the clones.
# STEP 5:	Prep odd r/R clones for the microsphysics spin-up.
# STEP 6:	Run verification script and manually inspect the log files.
############################################################################################

#Generating keys to ensure code is run intentionally
key1=$RANDOM
key2=$RANDOM

echo
echo -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo "WARNING: This script can cause CATASTROPHIC DATA LOSS if used inappropriately."
echo "It is recommended that you read the comments, within this script AND revise the script and associated subscripts before proceeding"
echo "Should you wish to proceed please enter the following code: $key1"
read confirmation1
echo "To confirm, please enter the following code: $key2"
read confirmation2

if [ $confirmation1 -eq $key1 ] && [ $confirmation2 -eq $key2 ]
then
	# Defining Paths
		scriptBasePath="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts"
		workspacePath="/home/ukurien/projects/def-yaumanko/ukurien"

	# STEP 1
		rm -rv $workspacePath/Clones_2

	# STEP 2
		cp -rv $workspacePath/Clones_2_backup_v17_b4_true_bidisperse/ $workspacePath/Clones_2/

	# STEP 3
		$scriptBasePath/scripts_for_collision_efficiency_master_bidisperse_MODULAR/genesis.sh

	# STEP 4
		$scriptBasePath/correction_scripts/parent_loop_bulk.sh

	# STEP 5
		$scriptBasePath/scripts_for_collision_efficiency_master_bidisperse_MODULAR/prep_for_next_run_bidisperse.sh

	# STEP 6
		mkdir $workspacePath/Clones_2/Logs/Parameter_Verification_Logs
		$scriptBasePath/verification_scripts_for_collision_efficiency_master_bidisperse/parent_loop_bulk_alternate_version.sh
else
	echo Exiting
fi


