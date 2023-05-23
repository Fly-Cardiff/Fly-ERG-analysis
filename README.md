# Fly-ERG-analysis
MATLAB script to analyse electroretinograms (ERG) from Drosophila

Smith and Peters Labs Cardiff University UKDRI
Originally written by Tim Johnston - adapted by Hannah Clarke 

The aim of this script is to pull out the individual aspects of the electroretinogram:
1) On transient 
2) Depolarisation 
3) Off transient 
4) Thalf baseline return 
5) baseline return 

This is written for a 5 second recording. So, this assumes recordings are in individual directories, each with txt file (Ch10_Vin+.TXT) with 50,000 data points (10,000 samples per second) representing voltage of the recording at each time point. In addition to this the user will need a txt file which is a list of all the filenames corresponding to the directories.

The general premise of the script is to use certain time points to pull out different features. We used: 
0-10000 = delay (no stimulus) 
10000 = stimulius onset 
10000-20000 = stimulus on (depolarisation stage)
20000 = stimulus off 
Until 50000 = return to baseline

A few aspects of the script will need to be changed to make it run (see comments)
1) path to directory of filenames file
2) path to current file
3) path "short path"
4) Change ylim - limits of your y coordinates for graphing
5) Last line - where to save things 
6) Change count for how long your filenames txt file is 

The output file will be 5 columns (row=n of files) with data corresponding to: 
1) on_transient_amplitude_milivolts
2) depolarisation_amplitude_milivolts at 1.5s
3) Off transient mv
4) Thalf baseline return s
5) Baseline return s (this will be 0 if baseline not reached) 
