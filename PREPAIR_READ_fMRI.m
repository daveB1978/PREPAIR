function prepair = PREPAIR_READ_fMRI(prepair)

mag_file = prepair.mag_file;
phase_file = prepair.phase_file;
mask_file = prepair.mask_file;


if prepair.waitbarBoolean
    wait = waitbar(0,'Reading the fMRI data ...'); % initialize waitbar
end
if prepair.waitbarBoolean
    waitbar(0/2,wait) % increment the waitbar
end

mag = load_untouch_nii([prepair.indir mag_file]);
prepair.pixdim=mag.hdr.dime.pixdim;

if prepair.waitbarBoolean
    waitbar(1/2,wait) % increment the waitbar
end
phase = load_untouch_nii([prepair.indir phase_file]);


mag=double(mag.img);
phase=double(phase.img);
[x,y,z,t] = size(mag);


if prepair.waitbarBoolean
    waitbar(2/2,wait) % increment the waitbar
end
if isempty(mask_file)
    prepair.mask=double(ones(x,y,z));
else
    mask=load_untouch_nii([prepair.indir '/' mask_file]);
    prepair.mask=double(mask.img);
end

prepair.mag=mag;
prepair.phase=phase;
prepair.x = x;
prepair.y = y;
prepair.N   = z; 
prepair.vol = t; 

if prepair.waitbarBoolean
    close(wait);
end
