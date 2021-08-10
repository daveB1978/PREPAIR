function sig2=PREPAIR_remove_TR(Fs, Fs2,dtTR,sig)

% Function to remove the 1/TR frequencies
% INPUT:
% Fs : slice-TR sampled rate
% Fs2 : vol-TR sampled rate
% dtTR : slice-TR sampled time
% sig: slice-TR sampled mag or phase

% OUTPUT:
% sig2: slice-TR sampled mag or phase

ind=ceil(Fs/2);
sig2=sig;


[p,f,~,~]=PREPAIR_fourier(dtTR,detrend(sig2));

for n=1:ind*2
    od = find(abs(f-n*Fs2)<0.001);
    p(od)= p(od)/1000000;
    od = find(abs(f-(Fs-n*Fs2))<0.001);
    p(od)= p(od)/1000000;
end

    sig2=real(ifft(p));

