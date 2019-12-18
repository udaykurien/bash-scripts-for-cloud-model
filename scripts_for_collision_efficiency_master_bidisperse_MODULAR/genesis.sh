#!/bin/bash

# This script clones an initial copy of the model in the appropriate file hierarchy
# for other scripts to operate on. Important flags and values (EDR, drop size etc.)
# are modified to fit the hierarchy.


# Symbollic representation of EDR values by read only (declare -r) variables
# N.B. declare -r defines a read only variable
declare -r edr1=0.000
declare -r edr2=0.002
declare -r edr3=0.005
declare -r edr4=0.010
declare -r edr5=0.020
declare -r edr6=0.050

# Symbollic representation of collector drop sizes by read only variables
declare -r dropSize1=30
declare -r dropSize2=35
declare -r dropSize3=40
declare -r dropSize4=45
declare -r dropSize5=50

# Symbollic representation of ratio of radii of collected and collector drops
declare -r rbyR01=0.1
declare -r rbyR02=0.2
declare -r rbyR03=0.3
declare -r rbyR04=0.4
declare -r rbyR05=0.5
declare -r rbyR06=0.6
declare -r rbyR07=0.7
declare -r rbyR08=0.8
declare -r rbyR09=0.9
declare -r rbyR10=1.0

# Defining counters
counter_sno_logfile=0
array_index=0

# Initializing variables for subscript calc_number_of_drops.sh
numberOfDrops_temp1=0
reCalcLWC_temp1=0
numberOfDrops_sum=0
reCalcLWC_sum=0

# Define path for subscripts to be called
pathSubScripts="/home/ukurien/projects/def-yaumanko/ukurien/Github/Scripts/scripts_for_collision_efficiency_master_bidisperse"

# Define path for log files
pathLogFiles="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2/Logs"

# Log file containing records of EDR, Drop Sizes and Number of drops
mkdir -p $pathLogFiles #Directory must be created before using touch

#################################################
touch $pathLogFiles/edr_dropsize_dropnumber_2.log
#################################################

# Get information on simulation run times. NB: Walltime scales almost linearly with timesteps.
nstop="5000000" #timesteps
sbatch="1-00:00:00" # walltime expressed as d-hh:mm:ss
 

# Get information on path of models to be cloned.
parentPathPt1="/home/ukurien/projects/def-yaumanko/ukurien"
parentPathPt2="turbulence_spin_up_runs_2"
parentPath=$parentPathPt1/$parentPathPt2

# Get information on where to clone models to
baseClonePath="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Get information on collector drop sizes:
lbDropSize=30 #smallest drop size
ubDropSize=50 #largest drop size
incDropSize=10 # drop size increments

# Get information on radii ratio of collected (r) to collector (R) drops for which collisions will be simulated.
lbrbyR=0.1 #lower bound ratio of collected to collector drop
ubrbyR=1.0 #upper bound ratio of collected to collector drop
incrbyR=0.2 #increments in ratio of collected to collector drop

# Implementation of genesis:
# Nested loops: 1st loop -> EDR, 2nd loop -> Collector drop size, 3rd loop -> Collected drop size
# Collected drop size is determined from the collector drop size and ratio of radii of collected drop to collector drop
# SED used to modify content of clones and generate multiple instances of the model.

# Loop 1 -> EDR
# -------------
for  EDR in $edr2 $edr3 $edr4 $edr5 $edr6 
do
	# Loop 2 -> Collector drop sizes
	# -----------------------------
	for (( DropSize=$lbDropSize; DropSize<=$ubDropSize; DropSize=$DropSize+$incDropSize )) 
	do
		# Loop 3 -> Collected drop sizes
		# ------------------------------
		for rbyR in $(seq $lbrbyR $incrbyR $ubrbyR)
		do
			colDropSize=$(echo "scale=0;($DropSize*$rbyR)/1" | bc) # Determine size of collected drop based on r/R values. Scale -> Number of decimal places, bc -> best calculator, supports floating point calculations. Double quotes around argument to echo, because expansion of $variables required instead of passing the argument as a literal. The division by 1 is done to force scale to take effect, which otherwise appears to be, by default, only applicable to division and not multiplications.
			finalClonePath="$baseClonePath/$EDR/R$DropSize/R"$DropSize"r$colDropSize"
			mkdir -pv $finalClonePath/gomic0
			cp -rv $parentPath/$EDR/* $finalClonePath/gomic0/
			cd $finalClonePath/gomic0
	
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
				# NB: SED supports regex
				sed -i "s/#SBATCH --time=[0-9]-[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/#SBATCH --time=$sbatch/" run_graham.sh
			fi
			
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
	
			# drop radius
			# -----------
			# sed(stream editor) -i(inplace) "78s(substituion occurrs only in line 78).."
			sed -i "78s/r(id)=[0-9][0-9].d-6/r=${DropSize}.d-6/" idrops.F90
			sed -i "81s/r(id)=[0-9][0-9].d-6/r=${colDropSize}.d-6/" idrops.F90
				
	
			# EDR
			# ---
			grep -q "edr      = $EDR" main.F90
			exitStatus1=$?
			if [ $exitStatus1 -gt 0 ]
			then
				sed -i "s/edr      = [0-9].[0-9][0-9][0-9]/edr      = $EDR/" main.F90
			fi
			
			# Number of drops (based on domain size determined by EDR)
			# --------------------------------------------------------

			# Call calc_number_of_drops.sh from within the shell (source(or .) /path/to/script.sh) to compute number of drops. Variables from both scripts should, by default, be available to eachother since they share the same environment when calc_number_of_drops.sh is invoked with source.
			source $pathSubScripts/calc_number_of_drops.sh
			# Writing numberOfDrops to appropriate file
			grep -q "integer, parameter :: ndrop = $numberOfDrops_Total" param.inc
			exitStatus1=$?
			if [ $exitStatus1 -gt 0 ]
			then
#				sed -i "s/integer, parameter :: ndrop = [0-9]*/integer, parameter :: ndrop = $numberOfDrops/" param.inc
#			colDropSize=$(echo "scale=0;$colDropSize_half*2" | bc)
				sed -i "s/integer, parameter :: ndrop = [0-9]*/integer, parameter :: ndrop = $numberOfDrops_Total/" param.inc
			fi

			# Job name
			# --------
			sed -i "3s/#SBATCH --job-name=.*/#SBATCH --job-name=$DropSize$colDropSize$EDR/" run_graham.sh


			# Recording information into the log file
			# ---------------------------------------
			
			# Recording EDR, drop sizes (R & r) and number of drops
			echo "$counter_sno_logfile. EDR=$EDR, DS=$domainSize,r/R=$rbyR, R=$DropSize, r=$colDropSize, ND=$numberOfDrops, TND=$numberOfDrops_Total, RLWC=$reCalcLWC; NP=$numberOfProcs" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
			
			# Incrementing the counters
			counter_sno_logfile=$(echo "scale=0;$counter_sno_logfile+1" | bc)
			array_index=$(echo "scale=0;$array_index+1" | bc)
		done
	done
done

# Performing statistical tests on the adjusted number of drops and the re-calculated LWC
# --------------------------------------------------------------------------------------

# Average number of drops
numberOfDrops_avg=$(echo "scale=2;$numberOfDrops_sum/$counter_sno_logfile" | bc)

# Average re-calculated LWC
reCalcLWC_avg=$(echo "scale=7;$reCalcLWC_sum/$counter_sno_logfile" | bc)

# Standard deviation in number of drops and LWC
numberOfDrops_std_numerator=0
reCalcLWC_std_numerator=0
for i in $(seq 0 1 $array_index)
do
	numberOfDrops_std_numerator=$(echo "scale=2;((${numberOfDrops_array1[$i]}-$numberOfDrops_avg)^2)+$numberOfDrops_std_numerator" | bc)
	reCalcLWC_std_numerator=$(echo "scale=20;((${reCalcLWC_array1[$i]}-$reCalcLWC_avg)^2)+$reCalcLWC_std_numerator" | bc)
	echo ${reCalcLWC_array1[i]}
done

numberOfDrops_std=$(echo "scale=2;(sqrt($numberOfDrops_std_numerator/($counter_sno_logfile-1) )  )" | bc)
reCalcLWC_std=$(echo "scale=20;(sqrt($reCalcLWC_std_numerator/($counter_sno_logfile-1) ))" | bc)

# Writing out statistics to the end of the log file
# -------------------------------------------------

echo "/------------- Droplet number and LWC statistics-------------------------------------/" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
echo "Average number of drops: $numberOfDrops_avg" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
echo "Standard deviation of number of drops: $numberOfDrops_std" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
echo "Average LWC: $reCalcLWC_avg" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
echo "Standard deviation of LWC: $reCalcLWC_std" >> $pathLogFiles/edr_dropsize_dropnumber_2.log

#------------------------ D E B U G G I N G    A N D    D I A G N O S T I C S ---------------------#
echo "summation all drops=$numberOfDrops_sum average drop no=$numberOfDrops_avg summation LWC=$reCalcLWC_sum avg LWC=$reCalcLWC_avg counter=$counter_sno_logfile reCalcLWC numerator=$reCalcLWC_std_numerator" >> $pathLogFiles/edr_dropsize_dropnumber_2.log
echo "scale=10;((${reCalcLWC_array1[$i]}-$reCalcLWC_avg)^2)+0" | bc >> $pathLogFiles/edr_dropsize_dropnumber_2.log
