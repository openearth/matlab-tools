function findreplace(file,otext,ntext,varargin)

%FINDREPLACE finds and replaces strings in a text file
%
% SYNTAX:
%
% findreplace(file,oldtext,newtext)

% Obtaining the file full path
[fpath,fname,fext] = fileparts(file);
if isempty(fpath)
    out_path = pwd;
elseif fpath(1)=='.'
    out_path = [pwd filesep fpath];
else
    out_path = fpath;
end

% Reading the file contents
k=1;
fid = fopen([out_path filesep fname fext],'r');
while 1
    line{k} = fgetl(fid);
    if ~ischar(line{k})
        break;
    end
    k=k+1;
end
fclose(fid);

%Number of lines
nlines = length(line)-1;
for i=1:nlines
    if iscell(otext)
        for j=1:length(otext)
            line{i}=strrep(line{i},otext{j},ntext{j});
        end
    else
        line{i}=strrep(line{i},otext,ntext);
    end
end

line = line(1:end-1);

fid2 = fopen([out_path filesep fname fext],'w');

for i=1:nlines
%    fprintf(fid2,[line{i} '\n']);
    fprintf(fid2,'%s\n',line{i});
end
fclose(fid2);
