function prepair = PREPAIR_physio_waveforms(prepair)

% Function to derive the physio waveforms from i) magnitude and ii) phase
%
% INPUT:
% outdir     : current working directory
% fileHeader : file Header of the magnitude data
% SliceOrder : slice acquisition order (current is only ascending)
% mag        : 4D uncorrected magnitude data
% phase      : 4D unwrapped phase data
% mask       : mask of only brain voxel
% TR         : Repetition time (in secons)
% MB         : Multiband factor
%

% OUTPUT:
% card_phase : cardiac time series derived with phase data
% resp_phase : respiratory time series derived with phase data
% card_mag   : cardiac time series derived with magnitude data
% resp_mag   : respiratory time series derived with magnitude data
% pos        : location of each slice with the multiband series
% timeTR     : time vector

TR = prepair.TR;
MB = prepair.MB;
N = prepair.N;
nVol = prepair.vol;
sliceOrder = prepair.sliceOrder;
outdir = prepair.outdir;
mask = prepair.mask;
mag = prepair.mag;
phase = prepair.phase;

% Reduced number of slices
NR = N/MB;

% sliceTR samplig time
dtTR = TR/NR;

% sliceTR sampling rate
Fs=1/dtTR;

% volumeTR sampling rate
Fs2=1/TR;

% Get slice order acquisition
acqSlice = PREPAIR_slice_order(N,MB, sliceOrder);

% Get slice timing
[timeTR, timeSlice, sliceVolTR] = PREPAIR_slice_timing(dtTR,nVol,NR,MB,sliceOrder,acqSlice,N,TR);

% Get average signals in magnitude slices (Smag), phase slices (Sphase),
% slices having sufficient signal (slice2keep and slice2), new slice order
% acquisition (acqSlice2)


[Smag,Sphase, slice2keep,slice2,acqSlice2] = PREPAIR_derive_signal(prepair,phase,mask,mag,acqSlice);

Smag = Smag';
Sphase = Sphase';

% Get the position of each slice in each serie of multiband (pos)
pos = PREPAIR_treat_multiband(N, MB, acqSlice, acqSlice2, slice2keep);

% Set a range of frequency (in bmp) around which to centre the guessed 1st
% harmonics of cardiac (c_bpm) and respiration (r_bpm)
c_bpm = 6.5;
r_bpm = 2.5;

% Attach all phase slices together taking into account their order of acquistion 

sigTR_phase = PREPAIR_volTRtosliceTR(Sphase,nVol,pos,MB,NR,N,slice2);
sigTR_phase = PREPAIR_remove_TR(Fs, Fs2,dtTR,sigTR_phase);

sigTR_mag = PREPAIR_volTRtosliceTR(Smag,nVol,pos,MB,NR,N,slice2);
sigTR_mag = PREPAIR_remove_TR(Fs, Fs2,dtTR,sigTR_mag);

% Remove the 1HZ pump-related frequency: should be commented if different
% frequency
sigTR_phase = PREPAIR_filter_signal('oneHZ',Fs, sigTR_phase);

% Remove the 1HZ pump-related frequency should be commented if different
% frequency
sigTR_mag = PREPAIR_filter_signal('oneHZ',Fs, sigTR_mag);

[~,~,p,f]=PREPAIR_fourier(dtTR,sigTR_mag);
drift_mag=f(p==max(p));


% prefilter sigTR_phase in the range of cardiac frequencies
cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sigTR_phase);
% Find the 1st harmonic
fCC_phase=PREPAIR_main_peak(dtTR,cardFT_temp);
% prefilter sigTR_phase in the range of respiratory frequencies
respFT_temp = PREPAIR_filter_signal('RESP',Fs,sigTR_phase);
% Find the harmonics
fRR_phase=PREPAIR_main_peak(dtTR,respFT_temp);
[~,~,p,f]=PREPAIR_fourier(dtTR,sigTR_phase);
drift_phase=f(f<0.9*fRR_phase & p==max(p(f<0.9*fRR_phase)));

% Correct sidebands only if fCC_phase is sideband-related
sigTR_phase = PREPAIR_phase_remove_sidebands2(Fs, Fs2,dtTR,sigTR_phase,fRR_phase, drift_mag);
% Refilter sigTR_phase
cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sigTR_phase);
% Find the new 1st harmonics
fCC_phase=PREPAIR_main_peak(dtTR,cardFT_temp);


% Filter the sigTR_phase in the range of xc which is centered around
% fCC_phase
xc = fCC_phase +[-c_bpm c_bpm]/60;
card_phase=PREPAIR_centring(dtTR,sigTR_phase,Fs,xc);

% Filter the sigTR_phase in the range of xr which is centered around
% fRR_phase
xr = fRR_phase +[-r_bpm r_bpm]/60;
resp_phase=PREPAIR_centring(dtTR,sigTR_phase,Fs,xr);

% prefilter sigTRmag in the range of cardiac frequencies
cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sigTR_mag);
% Find the 1st harmonic
fCC_mag=PREPAIR_main_peak(dtTR,cardFT_temp);
% prefilter sigTR_mag in the range of respiratory frequencies
respFT_temp = PREPAIR_filter_signal('RESP',Fs,sigTR_mag);
% Find the harmonics
fRR_mag=PREPAIR_main_peak(dtTR,respFT_temp);
% Correct sidebands only if fCC_phase is sideband-related
sigTR_mag = PREPAIR_mag_remove_sidebands(Fs, Fs2,dtTR,sigTR_mag,fRR_phase, fCC_mag,drift_phase);
% Refilter sigTRmag
cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sigTR_mag);
% Find the new 1st harmonics
fCC_mag=PREPAIR_main_peak(dtTR,cardFT_temp);

% Filter the sigTR_mag in the range of xc which is centered around
% fCC_phase
xc = fCC_mag +[-c_bpm c_bpm]/60;
card_mag=PREPAIR_centring(dtTR,sigTR_mag,Fs,xc);

% Filter the sigTR_mag in the range of xr which is centered around
% fRR_phase
xr = fRR_mag +[-r_bpm +r_bpm]/60;
resp_mag=PREPAIR_centring(dtTR,sigTR_mag,Fs,xr);

prepair.Rmag = resp_mag';
prepair.Rphase = resp_phase';
prepair.Cmag = card_mag';
prepair.Cphase = card_phase';
prepair.dtTR = dtTR;
prepair.pos = pos;
prepair.NR = NR;
prepair.acqSlice = acqSlice;
prepair.slice = slice2;
prepair.volTR = Fs2;
prepair.sliceTR = Fs;
prepair.timeTR = timeTR;
prepair.timeSlice = timeSlice;
prepair.sliceVolTR = sliceVolTR;

% save time_phase.mat card_phase resp_phase pos timeTR
% save time_mag.mat card_mag resp_mag pos timeTR
% system(['mv time_phase.mat ' outdir '/']);
% system(['mv time_mag.mat ' outdir '/']);

