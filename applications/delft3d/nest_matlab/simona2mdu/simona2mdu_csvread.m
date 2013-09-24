function [out] = simona2mdu_csvread(filename,varargin)
%
% simona2mdu_csvread: reads coma seperated value file, also strings are returned
% 

opt.skiplines = '';
opt = setproperty(opt,varargin); 

irow = 0;
fid = fopen(filename);

while ~feof(fid)
    line = strtrim(fgetl(fid));
    if ~isempty(line) && ~ismember(line(1),opt.skiplines)
        irow = irow + 1;
        index = strfind(line,',');
        index = [0 index length(line) + 1];
        for icol = 1:length(index) - 1
            out{irow,icol} = line(index(icol) + 1:index(icol + 1) - 1);
            if ~isempty(str2num(out{irow,icol}))
                out{irow,icol} = str2num(out{irow,icol});
            end
        end
    end
 end

