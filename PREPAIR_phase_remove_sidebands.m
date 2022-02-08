function sig2=PREPAIR_phase_remove_sidebands(Fs, Fs2,dtTR,sig,fRR, drift)

ind=floor(Fs/2);
sig2=sig;

[p,f,~,~]=PREPAIR_fourier(dtTR,detrend(sig2));
pp=p;
p2=abs(p)/max(abs(p));
drift_temp = f(p2==max(p2));
drift_temp = drift_temp(1);
df = f(2) -f(1);
%f_drift = drift+[-df df];
f_drift = f(f>=drift-df-0.001 & f<=drift+df);
% Sidebands due to respiration (filter peaks with power > 0.7 located 10% around the fRR peaks)
f_resp=f(f>=0.95*fRR & f<=1.05*fRR);
SR=f_resp;%(ppp>0.7);


% sidebands due to low frequency (filter peaks with power > 0.7 located 10% around the f_low / f_scan peaks)
f_low = f(f<0.9*fRR);

if isempty(f_low)==0
    ff_low = zeros(1,length(f_low));
    for i=1:length(f_low)
        ff_low = f(f>=0.95*drift_temp & f<=1.05*drift_temp);
    end
end
S_low = ff_low;

for n=1:ind
    % Remove respiratory-related sidebands
    if isempty(SR)==0
        for j=1:length(SR)
            locs = Fs2+[-SR(j) SR(j)];
            for i=1:length(locs)
                if locs(i)<Fs/2
                    od = find(abs(f-locs(i))<0.001);
                    p(od) = 0;
                end
            end
            
            locs = Fs - n*Fs2+[SR(j) -SR(j)];
            for i=1:length(locs)
                if locs(i)>Fs/2
                    od = find(abs(f-locs(i))<0.001);
                    p(od) = 0;
                end
                
            end
        end
    end
    % Remove low frequency-related sidebands
    
    if isempty(S_low)==0
        for j=1:length(S_low)
            locs = n*Fs2+[-S_low(j) S_low(j)];
            
            for i=1:length(locs)
                if locs(i)<Fs/2
                    od = find(abs(f-locs(i))<0.001);
                    p(od) = 0;
                end
            end
            locs = Fs - n*Fs2+[S_low(j) -S_low(j)];
            for i=1:length(locs)
                if locs(i)>Fs/2
                    od = find(abs(f-locs(i))<0.001);
                    p(od) = 0;
                end
                
            end
        end
        
    end
    for j=1:length(f_drift)
        locs = n*Fs2+[-f_drift(j) f_drift(j)];
        
        for i=1:length(locs)
            if locs(i)<Fs/2
                od = find(abs(f-locs(i))<0.001);
                p(od) = 0;
            end
        end
        locs = Fs - n*Fs2+[f_drift(j) -f_drift(j)];
        for i=1:length(locs)
            if locs(i)>Fs/2
                od = find(abs(f-locs(i))<0.001);
                p(od) = 0;
            end
            
        end
    end
end


% Restore power of frequencies below fRR
p(find(f<=fRR)) = pp(find(f<=fRR));
p(find(f>=(Fs-fRR))) = pp(find(f>=(Fs-fRR)));

sig2=real(ifft(p));

