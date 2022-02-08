function [SN, RESP, CARD] = PREPAIR_Retro_AFNI(prepair,c_,r_, Mr, Mc)
% Function to initialize SN for deriving respiratory and cardiac regressors
% INPUT:
% prepair: prepair structure
% c_ and r_ = cardiac and respiratory time series
% Mc and Mr = number of cardiac and respiratory regressors

% OUTPUT:
% SN = SN structure
% RESP = resp regressors
% CARD = card regressors


outdir = prepair.outdir;

%dlmwrite([outdir '/respFT.dat'], r_);
%dlmwrite([outdir '/cardFT.dat'], c_);
dlmwrite(fullfile(prepair.outdir, '/respFT.dat'), r_);
dlmwrite(fullfile(prepair.outdir, '/cardFT.dat'), c_);

SN=[];
SN.Cardfile     = fullfile(prepair.outdir, '/cardFT.dat');
SN.Respfile     = fullfile(prepair.outdir, '/respFT.dat');
SN.ShowGraphs   = 0; 
SN.VolTR        = prepair.TR; 
SN.Nslices      = prepair.N; 
SN.SliceOffset  = prepair.timeSlice;
SN.SliceOrder   = 'Custom';
SN.PhysFS       = length(c_)/prepair.TR/prepair.vol; 
SN.Quiet=1; 
SN.Prefix= fullfile(prepair.outdir,'/RetroTS.PREPAIR'); 
SN.RVT_out      = 0;
% Number of regressors
SN.Rreg = Mr; 
SN.Creg = Mc; 
if SN.PhysFS/2<=3
    SN.RespCutoffFreq = 3-round(3-SN.PhysFS/2,2)-0.001;
    SN.CardCutoffFreq = 3-round(3-SN.PhysFS/2,2)-0.001;
end


[SN, RESP, CARD] = PREPAIR_RetroTS_ccf(SN);