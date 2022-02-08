function sig2=PREPAIR_mag_remove_sidebands(Fs, Fs2,dtTR,sig,fRR, fCC, drift_phase)

ind=floor(Fs/2);
sig2=sig;

[p,f,~,~]=PREPAIR_fourier(dtTR,detrend(sig2));
pp=p;
f_low2 = find(f<=fRR);
f_low3 = find(f>=(Fs-fRR));

f_scan = f(f<=0.01);

side =1;

while side==1
    side =0;
    
    for n=1:ind
        of_R = find(abs(n*Fs2-fRR-fCC)<0.001 | abs(n*Fs2+fRR-fCC)<0.001);
        if length(of_R)> 0
            
            locs = n*Fs2+[-fRR fRR];
            if locs(1)<Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) < Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            
            locs = Fs - n*Fs2+[fRR -fRR];
            if locs(1)>Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) > Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            
            od = find(abs(f-fRR)<0.001);
            p(od)=0;
            od = find(abs(f-(Fs-fRR))<0.001);
            p(od) = 0;
            side=1;
            
        end
        
    end
    
    
    for n=1:ind
        of_scan = find(abs(n*Fs2-f_scan-fCC)<0.001 | abs(n*Fs2+f_scan-fCC)<0.001);
        if length(of_scan)> 0
            
            locs = n*Fs2+[-f_scan(of_scan) f_scan(of_scan)];
            if locs(1)<Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) < Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            
            locs = Fs - n*Fs2+[f_scan(of_scan) -f_scan(of_scan)];
            if locs(1)>Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) > Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            side=1;
            
        end
        
        of_drift = find(abs(n*Fs2-drift_phase-fCC)<0.001 | abs(n*Fs2+drift_phase-fCC)<0.001);
        
        if length(of_drift)> 0
            
            locs = n*Fs2+[-drift_phase drift_phase];
            if locs(1)<Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) < Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            
            locs = Fs - n*Fs2+[drift_phase -drift_phase];
            if locs(1)>Fs/2
                od=find(abs(f-locs(1))<0.001);
                p(od) = 0;
            end
            if locs(2) > Fs/2
                od=find(abs(f-locs(2))<0.001);
                p(od) = 0;
            end
            side=1;
        end
        %
        
        
    end
    
    sig2=real(ifft(p));
    cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sig2);
    fCC=PREPAIR_main_peak(dtTR,cardFT_temp);
    
    f_scan = f(f<=0.01);
    
    
end

% Restore power of frequencies below fRR
p(f_low2) = pp(f_low2);
p(f_low3) = pp(f_low3);
sig2=real(ifft(p));

