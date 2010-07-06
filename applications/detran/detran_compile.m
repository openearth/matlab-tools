delete('bin\*');

%  add wlsettings and oesettings
wlsettings;
run('F:\Repositories\OeTools\oetsettings.m');

% add all detran routines
addpath('detran_engines');
fid=fopen('complist','wt');
fprintf(fid,'%s\n','-a');
fprintf(fid,'%s\n','detran.m');

% Add engines
flist=dir('detran_engines');
for i=1:length(flist)
        fname=flist(i).name;
        switch fname
                case{'.','..','.svn'}
                otherwise
                    fprintf(fid,'%s\n',fname);
        end
end 

% Add gui-routines
addpath('detran_gui');
flist=dir('detran_gui');
for i=1:length(flist)
        fname=flist(i).name;
        switch fname
                case{'.','..','.svn','detran_about.txt'}
                otherwise
                    fprintf(fid,'%s\n',fname);
        end
end 

fclose(fid);

mcc -m -d bin detran.m -B complist
dos(['copy ' which('detran_about.txt') ' bin']);
delete('complist');