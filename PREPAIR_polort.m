function prepair=PREPAIR_polort(prepair)

mag_file = prepair.mag_file;

if prepair.waitbarBoolean
    wait = waitbar(0,'Baseline polynomial regressors ...'); % initialize waitbar
end
if prepair.waitbarBoolean
    waitbar(0/2,wait) % increment the waitbar
end
TR = prepair.TR;

if exist(fullfile(prepair.outdir, 'f+orig.HEAD'))
    command=['rm ' fullfile(prepair.outdir, 'f+orig.*')];
    system(command);
end

command=['3dcopy ' fullfile(prepair.indir, mag_file) ' ' fullfile(prepair.outdir, 'f+orig')];
system(command);
fid=fopen(fullfile(prepair.outdir, 'f+orig.HEAD'));
data   = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
data = reshape(data{1,:},1,[]);
tr=find(contains(data,'TAXIS_FLOATS')); 
tt=data(tr+2);
ttt=cell2mat(tt);

tata = str2num(ttt);
if tata(2) ~=TR
    od = strfind(ttt, num2str(tata(2)));
    titi=num2str(TR);
    ttt(od:od+length(titi)-1) = titi;
    toto={ttt};
    data(tr+2)=toto;
    temp=string(data);
    fid=fopen(fullfile(prepair.outdir, 'f+orig.HEAD'),'w');
    fprintf(fid,'%s\n',temp);
    fclose(fid);
end

if prepair.waitbarBoolean
    waitbar(1/2,wait) % increment the waitbar
end
command=['3dDeconvolve -polort A -input ' fullfile(prepair.outdir, 'f+orig -x1D_stop -x1D ') fullfile(prepair.outdir, 'polort -overwrite')];
system(command);
if prepair.waitbarBoolean
    waitbar(2/2,wait) % increment the waitbar
end
command=['1dcat ' fullfile(prepair.outdir, 'polort.xmat.1D > ') fullfile(prepair.outdir, 'clean_polort.xmat.1D')];
system(command);
prepair.polort_ = load(fullfile(prepair.outdir, 'clean_polort.xmat.1D'));
if prepair.waitbarBoolean
    close(wait);
end