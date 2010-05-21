%% Rename all src attributes
% To get this template to work we have to add "html/" parts to the image sources. Code is directly
% adopted at the main main page, which is not in the html dir).

files = dir(fullfile(obj.targetdir,'html','*.html'));

for ifiles = 1:length(files)
    fid = fopen(fullfile(obj.targetdir,'html',files(ifiles).name));
    str = fread(fid,'*char')';
    fclose(fid);
    
    str = strrep(str,'src="','src="html/');
    
    fid = fopen(fullfile(obj.targetdir,'html',files(ifiles).name),'w');
    fprintf(fid,'%s',str);
    fclose(fid);
end