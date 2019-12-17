#!/bin/bash

# Path to source folder
pathSourceBase="/home/ukurien/projects/def-yaumanko/ukurien/Clones_2"

# Path to destination folder
pathDestinationBase="/home/ukurien/projects/def-yaumanko/ukurien/completed_runs"

# Define specific paths
# Precise Path 1
R1=50
r1=50
edr1=0.005
precisePath1="$edr1/R$R1/R"$R1"r$r1"

# Precise Path 2
R2=50
r2=50
edr2=0.020
precisePath2="$edr2/R$R2/R"$R2"r$r2"

# Precise Path 3
R3=40
r3=40
edr3=0.010
precisePath3="$edr3/R$R3/R"$R3"r$r3"

# Precise Path 4
R4=40
r4=40
edr4=0.010
precisePath4="$edr4/R$R4/R"$R4"r$r4"

# Precise Path 5
R5=30
r5=30
edr5=0.010
precisePath5="$edr5/R$R5/R"$R5"r$r5"

# Precise Path 6
R6=30
r6=30
edr6=0.010
precisePath6="$edr6/R$R6/R"$R6"r$r6"

# Initiating loop to cycle through the paths
# ENSURE THAT LOOP ITERATOR MATCHES THE DIRECTORIES TO BE MOVED
for i in 1
do
	# Generate path to specific subfolder
	eval precisePathFinal=\$precisePath$i 
	
	# Add the folder corresponding to the flags
	for flags in gomic0 gomic1 gomic2ihydro0 gomic2ihydro1
	do
		# Generate path to copy from
		pathSourceFinal="$pathSourceBase/$precisePathFinal/$flags"
		echo "Source: $pathSourceFinal"

		# Generate path to copy to
		pathDestinationFinal="$pathDestinationBase/$precisePathFinal/$flags"
		echo "Destination: $pathDestinationFinal"

		if ! test -d $pathDestinationFinal
		then
			# Make destinatin directories
			mkdir -p $pathDestinationFinal

			# Move from Source to destination
			mv -iv $pathSourceFinal/* $pathDestinationFinal
		fi
	done
done

