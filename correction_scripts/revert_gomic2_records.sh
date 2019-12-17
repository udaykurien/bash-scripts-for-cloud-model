#!/bin/bash

# This script restores the model to its previous state. The restart files are left unchanged, but the recorded files are reverted to the last saved ones.

# Deleting current record files
rm -rv RUN_aerosol.*
rm -rv core.*

# Restore latest version of record files
# --------------------------------------

# Enter back up directory
cd BackUp
pwd

# Count number of record files
counterRUN=$(ls -l RUN_aerosol.coldat.* | wc -l)

# Copy the latest record files from the backup folder to the simulation folder
mv -v RUN_aerosol.coldat.old$counterRUN ../RUN_aerosol.coldat
mv -v RUN_aerosol.dispdat.old$counterRUN ../RUN_aerosol.dispdat
mv -v RUN_aerosol.dsd.old$counterRUN ../RUN_aerosol.dsd
mv -v RUN_aerosol.dsdlog.old$counterRUN ../RUN_aerosol.dsdlog
mv -v RUN_aerosol.eng.old$counterRUN ../RUN_aerosol.eng
mv -v RUN_aerosol.list.old$counterRUN ../RUN_aerosol.list
mv -v RUN_aerosol.nc.old$counterRUN ../RUN_aerosol.nc
mv -v RUN_aerosol.para.old$counterRUN ../RUN_aerosol.para
mv -v RUN_aerosol.spc.old$counterRUN ../RUN_aerosol.spc
mv -v RUN_aerosol.track.old$counterRUN ../RUN_aerosol.track
