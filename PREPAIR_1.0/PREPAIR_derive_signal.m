function [sig_mag, sig_phase, slice2keep,slice2,acqSlice2] = PREPAIR_derive_signal(prepair,phase,mask,mag,acqSlice)

% Function which derives two vol-TR sampled signal from i) the magnitude
% and ii) phase.
%
% INPUT:
% prepair  : prepair structure
% phase    : 4D unwrapped phase time series
% mask     : 3D mask
% mag      : 4D uncorrected mag time series
% acqSlice : Slice acquisition order
% 
% OUTPUT:
% sig_mag    : vol-TR slices time series from magnitude
% sig_phase  : vol-TR slices time series from phase
% slice2keep : slice which passed the threashold of 0.2*per
% slice2     : logical array based on slice2keep
% acqSlice2  : new slice acquisition order

[Ni,Nj,Nk,Nt]=size(phase);
voxM4=mag;
voxM3=phase;
masc=mask;
masc2=zeros(Ni,Nj,Nk);

if prepair.waitbarBoolean
    wait = waitbar(0,'Deriving the respiratory and cardiac PREPAIR time series ...'); % initialize waitbar
end

if prepair.waitbarBoolean
    waitbar(0/2,wait) % increment the waitbar
end
% Choose per as the grand maximum = 98th percentile of the data
per = percentile(mag(mag>0),98);
for k=1:Nk
    for i=1:Ni
        for j=1:Nj
            if masc(i,j,k) ==1
                % voxels with average magnitude > 0.2*per are kept for
                % later
                masc2(i,j,k)=mean(squeeze(mag(i,j,k,:)))>0.2*per;
                
            end
        end
    end
end

if prepair.waitbarBoolean
    waitbar(1/2,wait) % increment the waitbar
end

%%%Count active voxels per slice
for k=1:Nk
    count(k) = 0;
    for i=1:Ni
        for j=1:Nj
            
            if masc2(i,j,k) ==1
                count(k) = count(k) +1;
                
            end
        end
    end
    
end


unSig_mag = zeros(Nk,Nt);
sig_mag = zeros(Nk,Nt);

unSig_phase = zeros(Nk,Nt);
sig_phase = zeros(Nk,Nt);

voxM5=voxM4.*masc2;
voxM3 = voxM3.*masc2;

if prepair.waitbarBoolean
    waitbar(2/2,wait) % increment the waitbar
end

% Average over all time series within each slice 
for k=1:Nk
    
    for t=1:Nt
        
        vv=reshape(squeeze(voxM4(:,:,k,t)),Ni*Nj,1);
        % Only average time series of active voxels (i.e. mag>0)
        unSig_mag(k,t) = mean(vv);
        temp1=reshape(squeeze(voxM5(:,:,k,t)),Ni*Nj,1);
        temp2=reshape(squeeze(voxM3(:,:,k,t)),Ni*Nj,1);
        
        % weights based on magnitude
        w=squeeze(temp1)/sum(squeeze(temp1));
        % weighted mean of the phase (rather than the mean)
        unSig_phase(k,t) = sum(w.*squeeze(temp2))/sum(w);
        
        
        
    end
end
unSig_mag=double(unSig_mag);
unSig_phase=double(unSig_phase);

% Remove 3rd polynomials trends in each slice + devide by MAD to remove non-periodic signal like sudden motion, etc... 
for k=1:Nk
      p = polyfit(1:numel(unSig_mag(k,:)),unSig_mag(k,:),3);     
      sig_mag(k,:) = unSig_mag(k,:) - polyval(p, (1:numel(unSig_mag(k,:))));
      sig_mag(k,:) = sig_mag(k,:) / mad(sig_mag(k,:));

 
      p = polyfit(1:numel(unSig_phase(k,:)),unSig_phase(k,:),3);
      sig_phase(k,:) = unSig_phase(k,:) - polyval(p, (1:numel(unSig_phase(k,:))));
      sig_phase(k,:) = sig_phase(k,:)/mad(sig_phase(k,:));
      
end

% Find slices with enough active voxels
slice2keep = find(~isnan(sig_phase(:,1)));
slice2=~isnan(sig_phase(:,1));

 found = 0;
 %%% Now reorder slices according to slice acquisition
for k=1:Nk
    for p=1:length(slice2keep)
        if acqSlice(k) ==slice2keep(p)
            found = found+1;
            acqSlice2(found) = acqSlice(k);
            break
        end
    end
end
if prepair.waitbarBoolean
    close(wait);
end

