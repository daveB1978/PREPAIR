function sig2=PREPAIR_remove_sidebands(Fs, Fs2,dtTR,sig,fRR, fCC,typ)

ind=floor(Fs/2);
sig2=sig;

[p,f,~,~]=PREPAIR_fourier(dtTR,detrend(sig2));
pp=p;
p2=abs(p)/max(abs(p));
f_low = f(f<fRR);
f_low2 = find(f<=fRR);
f_low3 = find(f>=(Fs-fRR));
p_low = p2(f<fRR);
p_low = p_low/max(p_low);
f_low = f_low(p_low>0.7);
switch(typ)
    case('mag')
        f_scan = f(f<0.01);
end
% of_R = find(abs(Fs2-fRR-fCC_phase)<0.001 | abs(Fs2+fRR-fCC_phase)<0.001);
% of_low = find(abs(Fs2-f_low-fCC_phase)<0.001 | abs(Fs2+f_low-fCC_phase)<0.001);

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
    
    switch(typ)
        case('phase')
            
            for n=1:ind
                of_low = find(abs(n*Fs2-f_low-fCC)<0.001 | abs(n*Fs2+f_low-fCC)<0.001);
                if length(of_low)>0
                    
                    locs = n*Fs2+[-f_low(of_low) f_low(of_low)];
                    if locs(1)<Fs/2
                        od=find(abs(f-locs(1))<0.001);
                        p(od) = 0;
                    end
                    if locs(2) < Fs/2
                        od=find(abs(f-locs(2))<0.001);
                        p(od) = 0;
                    end
                    
                    locs = Fs - n*Fs2+[f_low(of_low) -f_low(of_low)];
                    if locs(1)>Fs/2
                        od=find(abs(f-locs(1))<0.001);
                        p(od) = 0;
                    end
                    if locs(2) > Fs/2
                        od=find(abs(f-locs(2))<0.001);
                        p(od) = 0;
                    end
                    od = find(abs(f-f_low(of_low))<0.001);
                    p(od)=0;
                    od = find(abs(f-(Fs-f_low(of_low)))<0.001);
                    p(od) = 0;
                    side=1;
                    
                    
                end
                
            end
    end
    
    switch(typ)
        case('mag')
            
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
                
            end
    end
    
    sig2=real(ifft(p));
    cardFT_temp=PREPAIR_filter_signal('CARD',Fs,sig2);
    fCC=PREPAIR_main_peak(dtTR,cardFT_temp);
    [p,f,~,~]=PREPAIR_fourier(dtTR,detrend(sig2));
    p2=abs(p)/max(abs(p));
    f_low = f(f<fRR);
    p_low = p2(f<fRR);
    p_low = p_low/max(p_low);
    f_low = f_low(p_low>0.7);
    switch(typ)
        case('mag')
            f_scan = f(f<0.01);
    end
%     of_R = find(abs(Fs2-fRR-fCC)<0.001 | abs(Fs2+fRR-fCC)<0.001);
%     of_low = find(abs(Fs2-f_low-fCC)<0.001 | abs(Fs2+f_low-fCC)<0.001);
%     
end

% Restore power of frequencies below fRR
p(f_low2) = pp(f_low2);
p(f_low3) = pp(f_low3);
sig2=real(ifft(p));

