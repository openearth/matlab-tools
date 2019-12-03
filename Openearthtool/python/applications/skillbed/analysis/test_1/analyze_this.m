function analyze_this(info, dirs)

fid = fopen(fullfile(dirs.output, 'revision.txt'),'w');
fprintf(fid,'Current Revision: %d',info.revision);
fclose(fid);