function t_ =  PREPAIR_test_correction(prepair,mag, c_, r_)
% Function to test the correct the magnitude image with either combination
% of mag and phase time series

% INPUT:
% prepair = prepair structure
% mag = 4D magnitude data
% c_ = cardiac time series
% r_ = respiratory time series

% OUTPUT:
% t_ : t_value


x = prepair.x;
y = prepair.y;
z = prepair.N;
t = prepair.vol;
Mr = prepair.Mr;
Mc = prepair.Mc;
mask = prepair.mask;

[~, RESP, CARD] = PREPAIR_Retro_AFNI(prepair, c_, r_, Mr, Mc);

        M = Mr+Mc;
t_ = zeros(x,y,z,2*M);

if prepair.polort == 0
    Ap = ones(t,1);
else
    Ap = prepair.polort_;
end

for k=1:z
   
    A = [squeeze(CARD.phz_slc_reg(:,1:2*Mc,k)) squeeze(RESP.phz_slc_reg(:,1:2*Mr,k)) Ap];  

    for i=1:x
        for j=1:y
            if mask(i,j,k)==1
                
                vox_mag=((squeeze(mag(i,j,k,:))));
                                              
                [p,std_err] = lscov(A,vox_mag);
                                
                p(2*M+1:end) = 0;
                
                t_(i,j,k,:) = p(1:2*M)./std_err(1:2*M);
                                
                
            end
            
        end
    end
    
end

t_=sqrt(sum(t_.^2,4));
t_ = t_(t_>0);
t_=mean(t_(~isnan(t_)));
