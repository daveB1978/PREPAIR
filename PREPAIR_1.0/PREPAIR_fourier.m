function [y, f_, y_spec, freq_spec] = PREPAIR_fourier(t,x)
% Function to fourier-transform the time series x into the frequency space
% and the power spectrum
% INPUT
% t = sampling time
%
% OUPUT
% y = Fourier transform of x in the interval 0:FS (FS = sampling frequency)
% (array 1xN)
% y_shift = Frequency centered signal y (array 1xN)
% y_spec = Normalized Power spectrum of y (array 1x(N/2))

N = length(x);
FS = 1/t; % Sampling Frequency
f_=(0:N-1)*FS/N; 

y = fft(x,N);

P2=abs(y/N);
y_spec=P2(1:N/2+1);
y_spec(2:end-1) = 2*y_spec(2:end-1);

freq_spec = FS*(0:N/2)/N;

