function prepair=PREPAIR_mag_or_phase(prepair)
% Function to choose between physiological signals derived from mag and
% phase. 
% For respiration, default is phase

% INPUT:
% prepair = prepair structure
% mag = 4D mag data


if prepair.waitbarBoolean
    wait = waitbar(0,'Choosing PREPAIR time series ...'); % initialize waitbar
end

if prepair.waitbarBoolean
    waitbar(0/2,wait) % increment the waitbar
end

    mag = prepair.mag;
    CmagM=PREPAIR_test_correction(prepair,mag,prepair.Cmag, prepair.Rmag);
    CmagP=PREPAIR_test_correction(prepair,mag,prepair.Cmag, prepair.Rphase);

    if prepair.waitbarBoolean
    waitbar(1/2,wait) % increment the waitbar
end


    CphaseM=PREPAIR_test_correction(prepair,mag,prepair.Cphase, prepair.Rmag);
    CphaseP=PREPAIR_test_correction(prepair,mag,prepair.Cphase, prepair.Rphase);

if prepair.waitbarBoolean
    waitbar(2/2,wait) % increment the waitbar
end


mm=max([CmagM CmagP CphaseP CphaseM]);

if CmagM==mm
    prepair.Creg = prepair.Cmag;
    prepair.C = 'mag';
    prepair.Creg_num = 0;
    
    prepair.Rreg = prepair.Rmag;
    prepair.R = 'mag';
    prepair.Rreg_num = 0;


elseif CmagP==mm
    prepair.Creg = prepair.Cmag;
    prepair.C = 'mag';
    prepair.Creg_num = 0;
    
    prepair.Rreg = prepair.Rphase;
    prepair.R = 'phase';
    prepair.Rreg_num = 1;
   
elseif CphaseM==mm
    
    prepair.Creg = prepair.Cphase;
    prepair.C = 'phase';
    prepair.Creg_num = 1;
    
    prepair.Rreg = prepair.Rmag;
    prepair.R = 'mag';
    prepair.Rreg_num = 0;

    
elseif CphaseP==mm
   
    prepair.Creg = prepair.Cphase;
    prepair.C = 'phase';
    prepair.Creg_num = 1;
    
    prepair.Rreg = prepair.Rphase;
    prepair.R = 'phase';
    prepair.Rreg_num = 1;
  
end

prepair.Rreg = prepair.Rphase;
prepair.R = 'phase';
prepair.Rreg_num = 1;


if prepair.waitbarBoolean
    close(wait);
end
