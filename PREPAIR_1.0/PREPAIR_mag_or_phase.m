function prepair=PREPAIR_mag_or_phase(prepair)
% Function to choose between physiological signals derived from mag and
% phase. 
% For respiration, default is phase

% INPUT:
% prepair = prepair structure
% mag = 4D mag data


mag = prepair.mag;
x = prepair.x;
y = prepair.y;
z = prepair.N;

if prepair.waitbarBoolean
    wait = waitbar(0,'Choosing PREPAIR time series ...'); % initialize waitbar
end

if prepair.waitbarBoolean
    waitbar(0/2,wait) % increment the waitbar
end
% magR=PREPAIR_test_correction(prepair,mag,prepair.Cmag, prepair.Rmag);
% if prepair.waitbarBoolean
%     waitbar(1/4,wait) % increment the waitbar
% end
magC=PREPAIR_test_correction(prepair,mag,prepair.Cmag, prepair.Rphase);
if prepair.waitbarBoolean
    waitbar(1/2,wait) % increment the waitbar
end
% phaseR=PREPAIR_test_correction(prepair,mag,prepair.Cphase, prepair.Rmag);
% if prepair.waitbarBoolean
%     waitbar(3/4,wait) % increment the waitbar
% end
phaseC=PREPAIR_test_correction(prepair,mag,prepair.Cphase, prepair.Rphase);

if prepair.waitbarBoolean
    waitbar(2/2,wait) % increment the waitbar
end

% Rvar_mag=(var(mag,0,4)-var(magR,0,4))./var(mag,0,4);
% Rvar_phase=(var(mag,0,4)-var(phaseR,0,4))./var(mag,0,4);
% 
% Rvar_mag = reshape(Rvar_mag,x*y*z,1);
% Rvar_mag(isnan(Rvar_mag))=0;
% Rvar_mag(Rvar_mag==1) = 0;
% Rvar_mag = Rvar_mag(Rvar_mag~=0);
% Rmag = median(rmoutliers(Rvar_mag));
% 
% Rvar_phase = reshape(Rvar_phase,x*y*z,1);
% Rvar_phase(isnan(Rvar_phase))=0;
% Rvar_phase(Rvar_phase==1) = 0;
% Rvar_phase = Rvar_phase(Rvar_phase~=0);
% Rphase = median(rmoutliers(Rvar_phase));
% 


Cvar_mag=(var(mag,0,4)-var(magC,0,4))./var(mag,0,4);
Cvar_phase=(var(mag,0,4)-var(phaseC,0,4))./var(mag,0,4);

Cvar_mag = reshape(Cvar_mag,x*y*z,1);
Cvar_mag(isnan(Cvar_mag))=0;
Cvar_mag(~isfinite(Cvar_mag)) = 0;
Cvar_mag(Cvar_mag==1) = 0;
Cvar_mag = Cvar_mag(Cvar_mag~=0);
Cmag = median(rmoutliers(Cvar_mag));

Cvar_phase = reshape(Cvar_phase,x*y*z,1);
Cvar_phase(isnan(Cvar_phase))=0;
Cvar_phase(~isfinite(Cvar_phase)) = 0;
Cvar_phase(Cvar_phase==1) = 0;
Cvar_phase = Cvar_phase(Cvar_phase~=0);
Cphase = median(rmoutliers(Cvar_phase));

 %mm=max([Cmag Cphase Rmag Rphase]);
 mm=max([Cmag Cphase]);
% 
% if Rmag==mm
%     prepair.Creg = prepair.Cmag;
%     prepair.Rreg = prepair.Rmag;
%     Creg = prepair.Cmag;
%     Rreg = prepair.Rmag;
%     prepair.C = 'mag';
%     prepair.R = 'mag';
% elseif Cmag==mm
%     prepair.Creg = prepair.Cmag;
%     prepair.Rreg = prepair.Rphase;
%     Creg = prepair.Cmag;
%     Rreg = prepair.Rphase;
%     prepair.C = 'mag';
%     prepair.R = 'phase';
% elseif Rphase==mm
%     prepair.Creg = prepair.Cphase;
%     prepair.Rreg = prepair.Rmag;
%     Creg = prepair.Cphase;
%     Rreg = prepair.Rmag;
%     prepair.C = 'phase';
%     prepair.R = 'mag';
% elseif Cphase==mm
%     prepair.Creg = prepair.Cphase;
%     prepair.Rreg = prepair.Rphase;
%     Creg = prepair.Cphase;
%     Rreg = prepair.Rphase;
%     prepair.C = 'phase';
%     prepair.R = 'phase';
% end

if Cmag==mm
    prepair.Creg = prepair.Cmag;
    prepair.Rreg = prepair.Rphase;
    Creg = prepair.Cmag;
    Rreg = prepair.Rphase;
    prepair.C = 'mag';
    prepair.R = 'phase';

elseif Cphase==mm
    prepair.Creg = prepair.Cphase;
    prepair.Rreg = prepair.Rphase;
    Creg = prepair.Cphase;
    Rreg = prepair.Rphase;
    prepair.C = 'phase';
    prepair.R = 'phase';
end
    
 save time_PREPAIR.mat Creg Rreg
 system(['mv time_PREPAIR.mat ' prepair.outdir '/']);

clear phaseR phaseC


if prepair.waitbarBoolean
    close(wait);
end
