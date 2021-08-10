function [F] = PREPAIR_main_peak(t,sig)

% Function to extract the fundamental frequency of the respiratory or
% cardiac signal

% INPUT: 
% t : sampling time (slice-TR)
% sig : respiratory or cardiac signal

% OUTPUT:
% F : respiratory or cardiac fundamental frequency

[p,f,pp,ff]=PREPAIR_fourier(t,sig);

[pks]=findpeaks(pp);
pks2=sort(pks,'descend');

for k=1:length(pks2)
    for j=1:length(pp)
        if pks2(k) == pp(j)
            id=j;
        end
    end
    loc(k) = ff(id);
    clear id
end
F=loc(1);