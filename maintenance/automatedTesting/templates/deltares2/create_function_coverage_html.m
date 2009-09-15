%% Fill template

tpl = dir(fullfile(templdir,'*.mtpl'));

for ifiles = 1:length(files)
    fid = fopen(fullfile(obj.targetdir,'html',files(ifiles).name));
    str = fread(fid,'*char')';
    fclose(fid);
    
    str = strrep(str,'src="','src="html/');
    
    fid = fopen(fullfile(obj.targetdir,'html',files(ifiles).name),'w');
    fprintf(fid,'%s',str);
    fclose(fid);
end