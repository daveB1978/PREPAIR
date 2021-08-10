%% Script to run PREPAIR on EPI data single subject and diplays spectrogram of the physiological noise time series
addpath(genpath('afni_matlab'))
% Make sure chronux is downloaded! 
% Add path to chronux toolbox 
addpath(genpath('chronux'))

clear variables

%% Input parameters
prepair = [];
prepair.TR  = 2; % TR in seconds
prepair.MB  = 1; % Multiband factor
prepair.sliceOrder = 'asc'; % slice acquisition order. Only ascending is currently available 
prepair.indir = ' '; % directory where the input fMRI data
prepair.Mc = 2; % Number of cardiac regressors
prepair.Mr = 2; % NUmber of respiration regressors
prepair.polort = 1; % baseline model for GLM. If AFNI is installed, set it to 1 (will use 3dDeconvolve). If not, set to 0 (baseline will be set to 1)
prepair.waitbarBoolean = 1; % Toggle for Progress bar. 0 = "off", 1 = "on"

% Optional PMU file (without extension) for comparison with PMU data;leave
% blank if no PMU is needed
%prepair.phys = strcat('/ceph/mri.meduniwien.ac.at/projects/radiology/acqdata/data/DB_sorting_spot/3T_paper/19780113DVBN_202105311000/Physio/Physio_20210531_104007_b4da8c88-848e-48be-bd9e-5885e6685b0c');
prepair.phys = '';

prepair.mag_file = 'magS4TR2000.nii'; %'magS4TR2000.nii'% Name of the magnitude file
prepair.phase_file = 'phaseS4TR2000.nii'; % name of the phase file
prepair.mask_file = 'maskS4TR2000.nii'; % Provide additionally a mask. Leave blank if no masking is needed

load([prepair.indir '/PMUS4TR2000.mat']);
load([prepair.indir '/PESTICAS4TR2000.mat']);


%% 1) Create outdir folder (indir/PREPAIR)
prepair.outdir = [prepair.indir 'PREPAIR/'];
if ~isfolder(prepair.outdir)
    command=['mkdir ' prepair.indir 'PREPAIR/'];
    system(command);
end

%% 2) Load EPI magnitude and unwrapped phase data
prepair = PREPAIR_READ_fMRI(prepair);


%% 3) Derive magnitude and phase waveforms
prepair=PREPAIR_physio_waveforms(prepair);


%prepair = PREPAIR_main(prepair);

%% Generate spectrograms
movingwin = [45 4];
params.Fs = 1/prepair.dtTR;
params.tapers = [2 3];

[Smag,~, ~,~,~] = PREPAIR_derive_signal(prepair,prepair.phase,prepair.mask,prepair.mag,prepair.acqSlice);
Smag = Smag';
sigTR  = PREPAIR_volTRtosliceTR(Smag,prepair.vol,prepair.pos,prepair.MB,prepair.NR,prepair.N,prepair.slice);
[spec_original, stime, sfreq] = mtspecgramc(sigTR, movingwin, params);

[cPMU, ctime, cfreq] = mtspecgramc(detrend(cardPMU), movingwin, params);
[rPMU, rtime, rfreq] = mtspecgramc(detrend(respPMU), movingwin, params);

[ppC_phase, ppCtime_phase, ppCfreq_phase] = mtspecgramc(detrend(prepair.Cphase), movingwin, params);
[ppC_mag, ppCtime_mag, ppCfreq_mag] = mtspecgramc(detrend(prepair.Cmag), movingwin, params);
[ppC_PESTICA, ppCtime_PESTICA, ppCfreq_PESTICA] = mtspecgramc(detrend(card_pestica), movingwin, params);

[ppR_phase, ppRtime_phase, ppRfreq_phase] = mtspecgramc(detrend(prepair.Rphase), movingwin, params);
[ppR_mag, ppRtime_mag, ppRfreq_mag] = mtspecgramc(detrend(prepair.Rmag), movingwin, params);
[ppR_PESTICA, ppRtime_PESTICA, ppRfreq_PESTICA] = mtspecgramc(detrend(resp_pestica), movingwin, params);

cc=zeros(length(ctime),1);
rr=zeros(length(rtime),1);
pC_phase=zeros(length(ppCtime_phase),1);
pC_mag=zeros(length(ppCtime_mag),1);
pC_PESTICA=zeros(length(ppCtime_PESTICA),1);
pR_phase=zeros(length(ppRtime_phase),1);
pR_mag=zeros(length(ppRtime_mag),1);
pR_PESTICA=zeros(length(ppRtime_PESTICA),1);

for k=1:length(ctime)
    od=find(cPMU(k,:)==max(cPMU(k,:)));
    cc(k)=cfreq(od);
end

for k=1:length(rtime)
    od=find(rPMU(k,:)==max(rPMU(k,:)));
    rr(k)=rfreq(od);
end

for k=1:length(ppCtime_phase)
    od=find(ppC_phase(k,:)==max(ppC_phase(k,:)));
    pC_phase(k)=ppCfreq_phase(od);
end

for k=1:length(ppCtime_mag)
    od=find(ppC_mag(k,:)==max(ppC_mag(k,:)));
    pC_mag(k)=ppCfreq_mag(od);
end

for k=1:length(ppCtime_PESTICA)
    od=find(ppC_PESTICA(k,:)==max(ppC_PESTICA(k,:)));
    pC_PESTICA(k)=ppCfreq_PESTICA(od);
end

for k=1:length(ppRtime_phase)
    od=find(ppR_phase(k,:)==max(ppR_phase(k,:)));
    pR_phase(k)=ppRfreq_phase(od);
end

for k=1:length(ppRtime_mag)
    od=find(ppR_mag(k,:)==max(ppR_mag(k,:)));
    pR_mag(k)=ppRfreq_mag(od);
end

for k=1:length(ppRtime_PESTICA)
    od=find(ppR_PESTICA(k,:)==max(ppR_PESTICA(k,:)));
    pR_PESTICA(k)=ppRfreq_PESTICA(od);
end



od=find(sfreq<4);
c_min=min([min(min(10*log10(spec_original(:,od))))]); 
c_max=max([max(max(10*log10(spec_original(:,od))))]); 


figure;subplot('Position',[0.12 0.2 0.8 0.7])
od=find(sfreq<1.6 & sfreq>0.4);

imagesc(stime, sfreq(od), 10*log10(spec_original(:,od))');
hold on; plot(ctime,cc, 'k', 'LineWidth',4); hold off; hold on; 
c=rgb('red');
plot(ppCtime_phase,pC_phase,'-.','Color',c', 'LineWidth',3);hold off;
hold on;plot(ppCtime_mag,pC_mag,'m-.', 'LineWidth',2);hold off
c = rgb('Blue'); 
hold on;plot(ppCtime_PESTICA,pC_PESTICA,'-.','Color',c, 'LineWidth',3);hold off
colormap('jet')
set(gca,'YDir','normal')
caxis([c_min c_max])
xlim([stime(1) stime(end)])
ylim([sfreq(od(1)) sfreq(od(end))])
title('Spectrogram of the physiological time series')
yticks([0.4 0.6 0.8 1.0 1.2 1.4 1.6]);
yticklabels({'0.4', '0.6', '0.8', '1.0', '1.2', '1.4','1.6'});

ylabel('Frequency (Hz)')
a=get(gca,'YTickLabel');
set(gca, 'YTickLabel',a,'fontsize',12)
xlabel('Time (s)')
a=get(gca,'XTickLabel');
set(gca, 'XTickLabel',a,'fontsize',12)
  hL=legend({'PMU' 'PREPAIR-phase' 'PREPAIR-magnitude' 'PESTICA'},'Orientation','horizontal','FontSize',11,'Box','off');
  newPosition = [0.4 0.00 0.2 0.1];
  newUnits = 'pixels';
  set(hL,'Position', newPosition);
