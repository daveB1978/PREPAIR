function [ima_corr,t_c, t_r] =  PREPAIR_correction(prepair)
% Function for magnitude image correction using PREPAIR time series

% INPUT:
% mag = 4D magnitude data
% prepair = prepair structure
% c_ and r_ = PREPAIR cardiac and respiratory time series

% OUTPUT
% ima_corr = corrected magnitude image
% t_c, t_r = cardiac and respiratory regressors t_values


x = prepair.x;
y = prepair.y;
z = prepair.N;
t = prepair.vol;
Mr = prepair. Mr;
Mc = prepair. Mc;
mask = prepair.mask;
mag = prepair.mag;
NR = prepair.NR;
c_ = prepair.Creg;
r_ = prepair.Rreg;


% t-values
t_r = zeros(x,y,z,2*Mr);
t_c = zeros(x,y,z,2*Mc);
ima_corr = zeros(x,y,z,t);

c_ = c_/std(c_);
r_ = r_/std(r_);


[~, RESP, CARD] = PREPAIR_Retro_AFNI(prepair, c_, r_, Mr, Mc);

if prepair.polort == 0
    Ap = ones(t,1);
else
    Ap = prepair.polort_;
end

if prepair.waitbarBoolean
    wait = waitbar(0,'Correcting magnitude data ...'); % initialize waitbar
end

for k=1:z

    Arc = [squeeze(CARD.phz_slc_reg(:,1:2*Mc,z)) squeeze(RESP.phz_slc_reg(:,1:2*Mr,z)) Ap];

    for i=1:x
        for j=1:y
            if mask(i,j,k)==1
                
                vox_mag=((squeeze(mag(i,j,k,:))));
                SD = std(vox_mag);
                vox_mag = vox_mag/SD;
                 
                [prc,std_err] = lscov(Arc,vox_mag);

                prc(2*(Mr+Mc)+1:end) = 0;
                ima_corr(i,j,k,:) = (vox_mag - (Arc*prc))*SD;
 
               % t-values
                
               t_c(i,j,k,:) = prc(1:2*Mc)./std_err(1:2*Mc);
               t_r(i,j,k,:) = prc(2*Mc+1:2*(Mr+Mc))./std_err(2*Mc+1:2*(Mr+Mc));

    
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


