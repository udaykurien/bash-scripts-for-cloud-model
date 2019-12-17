#!/bin/bash

# This script backs up previous restart files, names new restart files and backs up copies of previously recorded data

# Renaming restart file, deptracating and preserving last restart file
# --------------------------------------------------------------------

# Count number of restart files and store them in variable counter
counterZk=$(ls -l Zk.in.ncf* | wc -l)
counterDrop=$(ls -l drop.in.ncf* | wc -l)

# Appending the count to obsolete restart files and naming the new restart files
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

