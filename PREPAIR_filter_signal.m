function sig_filt=PREPAIR_filter_signal(typ, Fs, sig)
% Function to pre-filter cardiac and respiratory signals from original slice-TR sig (mag or phase)

% INPUT:
% typ : 'RESP' or 'CARD'
% Fs : slice-TR sample rate
% sig : mag or phase slice-TR signal

% OUTPUT:
% sig_filt: respiratory or cardiac pre-filtered time series

dtTR = 1/Fs;

switch(typ)
    
    case('RESP')
        
        xr=[0.16 0.5];
        sig_filt = PREPAIR_centring(dtTR,sig, Fs, xr);
    
    case('CARD')
        a=0.7;
        b=min((Fs/2)-0.001,1.6);
        [b,a] = butter(3,[a b]/(Fs/2));
       sig_filt = filter(b,a,sig);
    case('oneHZ')
        [p,f,~,~]=PREPAIR_fourier(dtTR,sig);
        od=find(abs(1 -f)<0.001);
        p(od)=0;p(end-od+2)=0;
        sig_filt = real(ifft(p));
        
    case('strict_CARD')
        [b,a] = butter(4,[0.8 1.4]/(Fs/2));
        sig_filt = filter(b,a,sig);
end

