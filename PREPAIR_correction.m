function [ima_corr,t_c, t_r] =  PREPAIR_correction(prepair)
% Function for magnitude image correction using PREPAIR time series
% INPUT:
% mag = 4D magnitude data
% prepair = prepair structure
% c_ and r_ = PREPAIR cardiac and respiratory time series


x = prepair.x;
y = prepair.y;
z = prepair.N;
t = prepair.vol;
Mr = prepair. Mr;
Mc = prepair. Mc;
mask = prepair.mask;
mag = prepair.mag;
c_ = prepair.Creg;
r_ = prepair.Rreg;

% t-values
t_r = zeros(x,y,z,2*Mr);
t_c = zeros(x,y,z,2*Mc);
ima_corr = zeros(x,y,z,t);

c_ = c_/std(c_);
r_ = r_/std(r_);
[~, RESP, CARD] = PREPAIR_Retro_AFNI(prepair, c_, r_, Mr, Mc);

NR = prepair.NR;
if prepair.polort == 0
    Ap = ones(t,1);
else
    Ap = prepair.polort;%ones(t,1);%prepair.polort;
end

if prepair.waitbarBoolean
    wait = waitbar(0,'Correcting magnitude data ...'); % initialize waitbar
end

for k=1:z
    if prepair.waitbarBoolean
        waitbar((k-1)/z,wait) % increment the waitbar
    end
    if mod(k,NR)
        l = mod(k,NR);
    else
        l=NR;
    end
  
    Ar = [squeeze(RESP.phz_slc_reg(:,1:2*Mr,l)) Ap];
    Ac = [squeeze(CARD.phz_slc_reg(:,1:2*Mc,l)) Ap];
    Arc = [squeeze(RESP.phz_slc_reg(:,1:2*Mr,l)) squeeze(CARD.phz_slc_reg(:,1:2*Mc,l)) Ap];
    
    for i=1:x
        for j=1:y
            if mask(i,j,k)==1
                
                vox_mag=((squeeze(mag(i,j,k,:))));
                SD = std(vox_mag);
                vox_mag = vox_mag/SD;
                 
                [pr,std_r_err] = lscov(Ar,vox_mag);
                [pc,std_c_err] = lscov(Ac,vox_mag);
                [prc,~] = lscov(Arc,vox_mag);
                

                pr(2*Mr+1:end) = 0;
                pc(2*Mc+1:end) = 0;
                prc(2*(Mr+Mc)+1:end) = 0;
                ima_corr(i,j,k,:) = (vox_mag - (Arc*prc))*SD;
 
               % t-values
                
                t_r(i,j,k,:) = pr(1:2*Mr)./std_r_err(1:2*Mr);
                t_c(i,j,k,:) = pc(1:2*Mc)./std_c_err(1:2*Mc);
                
    
            end
            
        end
    end
    
end

if prepair.waitbarBoolean
    waitbar(k/z,wait) % increment the waitbar
end

t_r(isnan(t_r)) = 0;
t_r(~isfinite(t_r)) = 0;

t_c(isnan(t_c)) = 0;
t_c(~isfinite(t_c)) = 0;

t_r=sqrt(sum(t_r.^2,4));
rmask=zeros(x,y,z);
rmask(find(t_r>2.3)) = 1;
t_r = t_r.*rmask;

t_c=sqrt(sum(t_c.^2,4));
rmask=zeros(x,y,z);
rmask(find(t_c>2.3)) = 1;
t_c = t_c.*rmask;

if prepair.waitbarBoolean
    close(wait);
end


