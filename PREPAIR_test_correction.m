function ima_corr =  PREPAIR_test_correction(prepair,mag, c_, r_)
% Function to test the correct the magnitude image with either combination
% of mag and phase time series

% INPUT:
% prepair = prepair structure
% mag = 4D magnitude data
% c_ = cardiac time series
% r_e = respiratory time series


x = prepair.x;
y = prepair.y;
z = prepair.N;
t = prepair.vol;
Mr = prepair. Mr;
Mc = prepair. Mc;
M=Mr+Mc;
mask = prepair.mask;

ima_corr = zeros(x,y,z,t);

c_ = c_/std(c_);
r_ = r_/std(r_);
% Compute physio regressors
[~, RESP, CARD] = PREPAIR_Retro_AFNI(prepair, c_, r_, Mr, Mc);

NR = prepair.NR;
if prepair.polort == 0
    Ap = ones(t,1);
else
    Ap = prepair.polort;%ones(t,1);%prepair.polort;
end
%Ap = prepair.polort;

for k=1:z
    if mod(k,NR)
        l = mod(k,NR);
    else
        l=NR;
    end
    A = [squeeze(RESP.phz_slc_reg(:,1:2*Mr,l)) squeeze(CARD.phz_slc_reg(:,1:2*Mc,l))  Ap];


    for i=1:x
        for j=1:y
            if mask(i,j,k)==1
                
                vox_mag=((squeeze(mag(i,j,k,:))));                 
                [p,~] = lscov(A,vox_mag);
                p(2*M+1:end) = 0;                                
                ima_corr(i,j,k,:) = (vox_mag - (A*p));
              
            end
            
        end
    end
    
end
