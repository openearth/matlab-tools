function KMLmerge_files
%
% Mergers all KML files in a certain directory
%

%%
path = uigetdir;
delete(fullfile(path,'merge.kml'));
files = dir(fullfile(path,'*.kml'));

fid0=fopen(fullfile(path,'merge.kml'),'w');
OPT_header = struct(...
    'name',path);
fprintf(fid0,'%s',KML_header(OPT_header));

for ii = 1:length(files)
    contents = [];
    fid = fopen(fullfile(path,files(ii).name));
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        contents = [contents tline];
    end
    fclose(fid);
    
    cutoff = strfind(contents,'Document');
    contents = ['<Folder>' contents(cutoff(1)+9:cutoff(2)-3) '</Folder>'];
    
    fprintf(fid0,'%s',contents);
end

% FOOTER
fprintf(fid0,'%s',KML_footer);
% close KML
fclose(fid0);