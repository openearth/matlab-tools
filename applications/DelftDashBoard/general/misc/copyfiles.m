function err=copyfiles(inpdir,outdir)
% Copies all files (and not the directories!) to new folder
err=[];
if ~isdir(inpdir)
    err=[inpdir ' not found!'];
    return
end
if ~isdir(outdir)
    err=[outdir ' not found!'];
    return
end

flist=dir([inpdir filesep '*']);
for i=1:length(flist)
    if ~isdir([inpdir filesep flist(i).name])
        copyfile([inpdir filesep flist(i).name],outdir);
    end
end
