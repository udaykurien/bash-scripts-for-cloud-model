#!/bin/bash			
				
# This script preps for the next model run
# It prepares gomic2ihydro0 and gomic2ihydro1 from gomic1

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


