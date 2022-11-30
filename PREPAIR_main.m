function prepair = PREPAIR_main(prepair)

%% 1) Create outdir folder (indir/PREPAIR)

prepair.outdir = fullfile(prepair.indir, 'PREPAIR'); 
if ~isfolder(prepair.outdir)
    command=['mkdir ' prepair.outdir];
    system(command);
end


%% 2) Load EPI magnitude and unwrapped phase data
prepair = PREPAIR_READ_fMRI(prepair);

if prepair.polort~=0
    prepair=PREPAIR_polort(prepair);
end

%% 3) Derive magnitude and phase waveforms
prepair=PREPAIR_physio_waveforms(prepair);


%% 4) Choose between magnitude or phase regressors
prepair = PREPAIR_mag_or_phase(prepair);


%% 5) Magnitude image correction

ima_corr = PREPAIR_correction(prepair);

if prepair.waitbarBoolean
    wait = waitbar(0,'Saving files ...'); % initialize waitbar
end
if prepair.waitbarBoolean
    waitbar(1/1,wait) % increment the waitbar
end
save_nii(make_nii(ima_corr),fullfile(prepair.outdir,'mag_corr.nii'))

prepair.ima_corr = ima_corr;

if prepair.waitbarBoolean
    close(wait);
end
