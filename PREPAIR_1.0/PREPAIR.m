%% Script to run PREPAIR on EPI data single subject
addpath(genpath('afni_matlab'))

clear variables

%% Input parameters
prepair = [];
prepair.TR  = 0.7; % TR in seconds
prepair.MB  = 8; % Multiband factor
prepair.sliceOrder = 'asc'; % slice acquisition order. Only ascending is currently available 
prepair.indir = '/ceph/mri.meduniwien.ac.at/projects/radiology/fmri/data/david/data/AllBrain/3T/Paper_example_1/'; % directory where the input fMRI data
prepair.Mc = 2; % Number of cardiac regressors
prepair.Mr = 2; % NUmber of respiration regressors
prepair.polort = 1; % baseline model for GLM. If AFNI is installed, set it to 1 (will use 3dDeconvolve). If not, set to 0 (baseline will be set to 1)
prepair.waitbarBoolean = 1; % Toggle for Progress bar. 0 = "off", 1 = "on"

% Optional PMU file (without extension) for comparison with PMU data;leave
% blank if no PMU is needed
%prepair.phys = strcat('/ceph/mri.meduniwien.ac.at/projects/radiology/acqdata/data/DB_sorting_spot/3T_paper/19780113DVBN_202105311000/Physio/Physio_20210531_104007_b4da8c88-848e-48be-bd9e-5885e6685b0c');
prepair.phys = '';

prepair.mag_file = 'magS10TR700.nii'; % Name of the magnitude file
prepair.phase_file = 'phaseS10TR700.nii'; % name of the phase file
prepair.mask_file = 'maskS10TR700.nii'; % Provide additionally a mask. Leave blank if no masking is needed

prepair = PREPAIR_main(prepair);

% %% 2) Create outdir folder (indir/PREPAIR)
% prepair.outdir = [prepair.indir 'PREPAIR2/'];
% if ~isfolder(prepair.outdir)
%     command=['mkdir ' prepair.indir 'PREPAIR2/'];
%     system(command);
% end
% 
% %% 3) Load EPI magnitude and unwrapped phase data
% [mag,phase,mask, prepair] = PREPAIR_READ_fMRI(prepair);
% 
% % mag   = load_untouch_nii([prepair.indir mag_file]);
% % prepair.pixdim=mag.hdr.dime.pixdim;
% % phase = load_untouch_nii([prepair.indir phase_file]);
% % mag=double(mag.img);
% % phase=double(phase.img);
% % [x,y,z,t] = size(mag);
% % prepair.x = x;
% % prepair.y = y;
% % prepair.N   = z; 
% % prepair.vol = t; 
% % 
% % if isempty(mask)
% %     prepair.mask=double(ones(x,y,z));
% % else
% %     mask=load_untouch_nii([prepair.indir '/' mask]);
% %     prepair.mask=double(mask.img);
% % end
% if prepair.polort~=0
%     prepair=PREPAIR_polort(mag_file,prepair);
% end
% 
% %% 4) Derive magnitude and phase waveforms
% prepair=PREPAIR_physio_waveforms(mag,phase,prepair);
% 
% %% 5) Optional resp and card waveforms from PMU
% if ~isempty(prepair.phys)
%     prepair=PREPAIR_compare_PMU(prepair);
% end
% 
% %% 6) Choose between magnitude or phase regressors
% prepair = PREPAIR_mag_or_phase(prepair,mag);
% 
% %% 7) Magnitude image correction
% ima_corr = PREPAIR_correction(mag, prepair, prepair.Creg, prepair.Rreg);
% centre_and_save_nii(make_nii(ima_corr),[prepair.outdir '/mag_corr.nii'],prepair.pixdim)






