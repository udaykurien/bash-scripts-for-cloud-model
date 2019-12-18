#!/bin/bash

# This script calculates the number of drops such that it is <= liquid water content and it is an even number of the number of processors.
# This script is supposed to be called from within the same shell as the caller script

# Declaring read-only constants for calculation of number of drops
# ----------------------------------------------------------------
declare -r constPie=3.14
declare -r constDensityWater=1000.0 #kg/m3 @ 10C
declare -r constDensityAir=1.2466 #kg/m3 @ 10C
declare -r constLWC=0.001 #Kg/Kg

# Retrieving the domain size from the turbulence spin up
#-------------------------------------------------------
# Retrieving domain sizes based on EDR values
lineWithDomainSize=$(grep "Domain size" $parentPath/$EDR/expRUN_aerosol) #Extracting line with domain size infor form expRUN_serosol
domainSize=$(echo $lineWithDomainSize | cut -b 19-23) #Extract characters in lines corrsponding to columns (each column is a byte,b) 19-23 (in this case domain size) and store it in variable domainSize

# Calculating number of drops
# ---------------------------
numberOfDrops=$(echo "scale=20;(3*$constLWC*$constDensityAir*($domainSize^3))/(4*$constPie*$constDensityWater*(($DropSize*(10^(-6)))^3)*(1+$rbyR^3))" | bc) # Derivation of this formula is in notes dated 9 August 2019

# Adjusting the number of drops so that it is an even multiple of the number of processors
# ----------------------------------------------------------------------------------------
# Retrieve number of processors from run_graham.sh
numberOfProcsLine=$(grep "#SBATCH --ntasks" $parentPath/$EDR/run_graham.sh)
numberOfProcs=$(echo $numberOfProcsLine | cut -b 18-19)

# Adjusting the number of drops
quotient=$(echo "$numberOfDrops/$numberOfProcs" | bc)
quotientOddEven=$(echo "$quotient%2" | bc)

if [ $quotientOddEven -eq 0 ]
then
	numberOfDrops=$(echo "$quotient*$numberOfProcs" | bc)
else
	numberOfDrops=$(echo "($quotient-1)*$numberOfProcs" | bc)
fi

# Total number of drops (numberOfDrops represents the total number of drops for each of the two drop sizes. Therefore the total number of drops = numberOfDrops * 2)
numberOfDrops_Total=$(echo "$numberOfDrops*2" | bc)

# Saving adjusted number of drops in an array for further calculations
numberOfDrops_array1[$array_index]=$numberOfDrops # array_index is initialized and incremented in genesis.sh

#------------------------- V E R I F I C A T I O N - - - - - - A N D - - - - - - T E S T S ----------------------#

# Verifying LWC clouds with adjusted drop numbers
# -----------------------------------------------
reCalcLWC=$(echo "scale=20;($numberOfDrops*4*$constPie*((($DropSize*10^(-6))^3)+(($colDropSize*10^(-6))^3))*$constDensityWater)/(3*($domainSize^3)*$constDensityAir)" | bc) # Derivation of this formula detailed in notes dated 9 August 2019

# Saving the re-calculated values of LWC in an array for further testing
reCalcLWC_array1[$array_index]=$reCalcLWC

# Determining statistics of the adjusted number of drops
# ------------------------------------------------------

# Extracting values of maximum and minimum number of drops
# N.B: numberOfDrops_temp1 is initialized in genesis.sh
#if (( $(echo "$numberOfDrops_temp1>$numberOfDrops" | bc -l) ))
#then
#	numberOfDrops_max=$numberOfDrops_temp1
#	numberOfDrops_min=$numberOfDrops
#elif (( $(echo "$numberOfDrops>$numberOfDrops_temp1" | bc -l) ))
#then
#	numberOfDrops_max=$numberOfDrops
#	numberOfDrops_min=$numberOfDrops_temp1
#fi
#numberOfDrops_temp1=$numberOfDrops

# Sum of drops -> Used to calculate average number of drops, std and rsd in genesis.sh
numberOfDrops_sum=$(echo "$numberOfDrops_sum+$numberOfDrops" | bc -l)

# Determining the statistics of LWC in clouds
# -------------------------------------------
#if (( $(echo "$reCalcLWC__temp1>$realCalcLWC" | bc -l) ))
#then
#	reCalcLWC_max=$reCalcLWC_temp1
#	reCalcLWC_min=$reCalcLWC
#elif (( $(echo "$reCalcLWC>$reCalcLWC_temp1" | bc -l) ))
#then
#	reCalcLWC_max=$reCalcLWC
#	reCalcLWC_min=$reCalcLWC_temp1
#fi
#reCalcLWC_temp1=$reCalcLWC

# Sum of Re-calculated LWC -> Used to compute average, std and rsd in genesis.sh
reCalcLWC_sum=$(echo "$reCalcLWC_sum+$reCalcLWC" | bc -l)
