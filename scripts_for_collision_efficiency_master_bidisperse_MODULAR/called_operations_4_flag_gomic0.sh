#!/bin/bash

# This script preps for the next model run


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


