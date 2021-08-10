function sig=PREPAIR_centring(dtTR,sigTR, Fs, x)
% Function to bandpass the mahnitude or cardiac signal
% INPUT:
% dtTR = slice-TR sampling time
% sigTR = slice-TR sampled magnitude or phase
% Fs = slice-TR sampling rate
% x = bandpass filter interval

[p,f,~,~]=PREPAIR_fourier(dtTR,sigTR);
pp =p;
od1=find(f<x(1));
od2=find(f>x(2) & f<Fs/2);

pp(od1) = 0.0;
pp(end-od1+1) = 0.0;
pp(od2) = 0.0;
pp(end-od2+1) = 0.0;

sig = real(ifft(pp));