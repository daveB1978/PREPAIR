%% Script to run PREPAIR on EPI data single subject
addpath(genpath('afni_matlab'))

clear variables

%% Input parameters
prepair = [];
prepair.TR  = 0.7; % TR in seconds
prepair.MB  = 8; % Multiband factor
prepair.sliceOrder = 'asc'; % slice acquisition order. Only ascending is currently available 
prepair.indir = ''; % directory where the input fMRI data
prepair.Mc = 2; % Number of cardiac regressors
prepair.Mr = 2; % NUmber of respiration regressors
prepair.polort = 1; % baseline model for GLM. If AFNI is installed, set it to 1 (will use 3dDeconvolve). If not, set to 0 (baseline will be set to 1)
prepair.waitbarBoolean = 1; % Toggle for Progress bar. 0 = "off", 1 = "on"

prepair.mag_file = ''; % Name of the magnitude file
prepair.phase_file = ''; % name of the phase file
prepair.mask_file = ''; % Provide additionally a mask. Leave blank if no masking is needed

prepair = PREPAIR_main(prepair);





