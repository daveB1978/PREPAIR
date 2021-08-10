%% Script to run PREPAIR on EPI data single subject, apply the PREPAIR regressors for correction and diplays spectrogram of uncorrected vs corrected magnitude
addpath(genpath('afni_matlab'))
% Make sure chronux is downloaded! 
% Add path to chronux toolbox 
addpath(genpath('chronux'))

clear variables

%% Input parameters
prepair = [];
prepair.TR  = 1.02; % TR in seconds
prepair.MB  = 4; % Multiband factor
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

prepair.mag_file = 'magS4TR1020.nii'; % Name of the magnitude file
prepair.phase_file = 'phaseS4TR1020.nii'; % name of the phase file
prepair.mask_file = 'maskS4TR1020.nii'; % Provide additionally a mask. Leave blank if no masking is needed

prepair = PREPAIR_main(prepair);

%% Generate spectrograms
movingwin = [45 4];
params.Fs = 1/prepair.dtTR;
params.tapers = [2 3];
prepair.waitbarBoolean = 0; % Toggle for Progress bar. 0 = "off", 1 = "on"

[Smag,~, ~,~,~] = PREPAIR_derive_signal(prepair,prepair.phase,prepair.mask,prepair.mag,prepair.acqSlice);
Smag = Smag';
sigTR  = PREPAIR_volTRtosliceTR(Smag,prepair.vol,prepair.pos,prepair.MB,prepair.NR,prepair.N,prepair.slice);
[spec_original, stime, sfreq] = mtspecgramc(sigTR, movingwin, params);

[Sprep,~, ~,~,~] = PREPAIR_derive_signal(prepair,prepair.phase,prepair.mask,prepair.ima_corr,prepair.acqSlice);
Sprep = Sprep';
sigTR_PREPAIR  = PREPAIR_volTRtosliceTR(Sprep,prepair.vol,prepair.pos,prepair.MB,prepair.NR,prepair.N,prepair.slice);
[spec_original_PREPAIR, stime_PREPAIR, sfreq_PREPAIR] = mtspecgramc(sigTR_PREPAIR, movingwin, params);
od=find(sfreq<0.3);

c_min=min([min(min(10*log10(spec_original(:,od)))) min(min(10*log10(spec_original_PREPAIR(:,od))))]);
c_max=max([max(max(10*log10(spec_original(:,od)))) max(max(10*log10(spec_original_PREPAIR(:,od))))]);


figure('Position',[10,10,1000,500]);
subplot('Position',[0.045 0.15 0.45 0.6])

od=find(sfreq<2);

set(gca, 'FontName', 'TimesNew Roman')
hold on
imagesc(stime, sfreq(od), 10*log10(spec_original(:,od))')
hold off
set(gca,'YDir','normal')
colormap('jet')
colorbar
caxis([c_min c_max])
xlim([stime(1) stime(end)])
ylim([sfreq(1) sfreq(od(end))])
ylabel('Freq (Hz)')
xlabel('Time (s)')
title('Uncorrected','FontSize',18)

subplot('Position',[0.55 0.15 0.45 0.6])
od=find(sfreq_PREPAIR<2);
set(gca, 'FontName', 'TimesNew Roman')
hold on
imagesc(stime_PREPAIR, sfreq_PREPAIR(od), 10*log10(spec_original_PREPAIR(:,od))')
hold off
set(gca,'YDir','normal')
colormap('jet')
colorbar
caxis([c_min c_max])
xlim([stime_PREPAIR(1) stime_PREPAIR(end)])
ylim([sfreq_PREPAIR(1) sfreq_PREPAIR(od(end))])
ylabel('Freq (Hz)')
xlabel('Time (s)')
title('PREPAIR','FontSize',18)
text(-260,2.6, 'Spectrogram of the magnitude data before / after correction', 'Fontsize',20)

%% Plot power spectra before / after correction
fRR=PREPAIR_main_peak(prepair.dtTR,prepair.Rreg);
fCC=PREPAIR_main_peak(prepair.dtTR,prepair.Creg);

[~,~,pPREPAIR,f]=PREPAIR_fourier(prepair.dtTR,(sigTR_PREPAIR));
[~,~,pu,ff]=PREPAIR_fourier(prepair.dtTR,(sigTR));
od=find(f>0.17&f<=1.8);
f = f(od);
ppu = pu(od);
ppPREPAIR = pPREPAIR(od);
odR = find(abs(fRR-f)<0.001);
odC1 = find(abs(fCC-f)<0.001);
odC2 = find(abs(2*fCC-f)<0.001);
ppu=smooth(ppu,15);
ppPREPAIR=smooth(ppPREPAIR,15);

cc = max([max(ppu) max(ppPREPAIR)]);
cc_min = min([min(ppu) min(ppPREPAIR)]);

figure;
plot(f,10*log10(ppPREPAIR), 'color',rgb('Red'),'LineWidth',3);hold on;plot(f,10*log10(ppu),'k--', 'LineWidth',3);hold off

ax.FontSize=12;
ylim([10*log10(cc_min*0.9) 10*log10(cc*1.1)])
a=get(gca,'YTickLabel');

set(gca, 'YTickLabel',a,'fontsize',11)
a=get(gca,'XTickLabel');
set(gca, 'XTickLabel',a,'fontsize',11)
%xticks([0 0.5 1 1.5])
bpm=2.5/60;
toto=ylim;

x2=[fRR-bpm fRR+bpm fRR+bpm fRR-bpm];
y2=[toto(1) toto(1) toto(2) toto(2)];
hold on
patch(x2,y2,'black','FaceAlpha',0.15)
hold on
bpm=6.5/60;
x2=[fCC-bpm fCC+bpm fCC+bpm fCC-bpm];
patch(x2,y2,'black','FaceAlpha',0.15)
if 2*fCC<1.8
    hold on
    x2=[2*fCC-bpm 2*fCC+bpm 2*fCC+bpm 2*fCC-bpm];
    patch(x2,y2,'black','FaceAlpha',0.15)
    
end
hold off
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
legend('PREPAIR','Uncorrected','Location','best');
title ('Power spectra before / after correction')
% hL=legend({'PREPAIR','Uncorrected'},'Orientation','vertical','Fontsize',16,'Box','off');
% newPosition = [0.4 -0.015 0.2 0.10];
% newUnits = 'pixels';
% set(hL,'Position', newPosition);%,'Units', newUnits);
% 

