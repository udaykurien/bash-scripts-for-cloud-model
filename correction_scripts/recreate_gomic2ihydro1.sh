#!/bin/bash

# Assign values to variables
sbatchNew="00-23:59:59"
nstopNew="2500000"
ihydro="1"
bigR=30
smallR=30
edr=0.050

# echo "Enter path to directory"
path2Dir="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2/$edr/R$bigR/R"$bigR"r$smallR"

cd $path2Dir

rm -rv gomic2ihydro$ihydro
mkdir gomic2ihydro$ihydro
cp -r gomic1/* gomic2ihydro$ihydro/

cd gomic2ihydro$ihydro
mv Zk.in.ncf Zk.in.ncf.old1
mv Zk4.out.ncf Zk.in.ncf
mv drop4.out.ncf drop.in.ncf
sed -i 's/gomic= 1/gomic= 2/g' param.inc
sed -i "s/ihydro   = 0/ihydro   = $ihydro/g" main.F90
sed -i "/#SBATCH --time=/ c #SBATCH --time=$sbatchNew" run_graham.sh
sed -i "148 c nstop    =$nstopNew" main.F90
sed -i "3s/#SBATCH --job-name=.*/#SBATCH --job-name="$ihydro"."$bigR""$smallR""$edr"/" run_graham.sh
