#!/bin/bash

# This script launches randomly ordered instances of the simulation.
# To use add the model path to the path variable, then add the path variable to the for loop.

# Base path
pathBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Path to subscripts
pathSubScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/correction_scripts"

#Fine path(s)
# General format: pathVar<#>="$pathBase/<EDR>/R<#>/R<#>r<#>/gomic<#>ihydro<#>"
pathVar01="$pathBase/0.002/R30/R30r30/gomic2ihydro0"
pathVar02="$pathBase/0.005/R40/R40r40/gomic2ihydro1"
# pathVar03="$pathBase/0.005/R30/R30r30/gomic2ihydro0"
# pathVar04="$pathBase/0.005/R30/R30r30/gomic2ihydro1"
pathVar05="$pathBase/0.005/R50/R50r50/gomic2ihydro1"
pathVar06="$pathBase/0.010/R30/R30r30/gomic2ihydro1"
# pathVar07="$pathBase/0.050/R30/R30r30/gomic2ihydro1"

# Give users the option to change walltime
echo Do you want to change the wall time? \(y/n\)
read varTimeStep
if [ "$varTimeStep" == "y" ]
then
	echo Enter new sbatch
	read sbatchNew
fi

module restore 20190808

for pathVar in $pathVar06
do
	# Change into directory
	cd $pathVar
	echo $pathVar

	# Prep for re-running gomic2
	source $pathSubScripts/revert_gomic2_records.sh
	
	# Launching simulations
#	./compileandrun_graham

	
#	# Change walltime if the user agreed to
#	if [ "$varTimeStep" == "y" ]
#	then
#		sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh  
#	fi

#	# Clean up
#	# Delete new turbulent restart files
#	rm -rv Zk{1,2,3,4}.out.ncf
#	# Delete new droplet restart files
#	rm -rv drop{1,2,3,4}.out.ncf
#	# Delete all recorded data from failed simulaton
#	rm -rv RUN_aerosol.*
	
done




