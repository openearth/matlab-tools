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
revnumb = '????';
if isappdata(0,'revisionnumber')
    revnumb = num2str(getappdata(0,'revisionnumber'));
else
    try
        [tf str] = system(['svn info ' fileparts(which('detran.m'))]);
        str = strread(str,'%s','delimiter',char(10));
        id = strncmp(str,'Revision:',8);
        if any(id)
            revnumb = strcat(str{id}(min(strfind(str{id},':'))+1:end));
        end
    catch me
        % don't mind
    end
end
strfrep(fullfile('bin','detran_about.txt'),'$revision',revnumb);
delete('complist');