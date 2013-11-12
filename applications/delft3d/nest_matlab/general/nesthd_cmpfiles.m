function nesthd_cmpfiles(files,varargin)

opt.Filename = '';
if ~isempty(varargin)
    opt = setproperty(opt,varargin);
end

if ~isempty(opt,Filename)
    fid = fopen(opt.Filename,'a');
end

% cmpfiles : compare file in cell array files with original fles (extension .org)

for itest = 1:length(files)
    if ~isempty(files{itest})
        if exist([files{itest} '.org'],'file')

           line_n = nesthd_reatxt( files{itest}        );
           line_o = nesthd_reatxt([files{itest} '.org']);

           identical = true;
           if length(line_n) == length(line_o);
               for iline = 1: length(line_n)
                   identical = strcmp(line_n{iline},line_o{iline});
                   if ~identical;break;end;
               end
           else
               identical = false;
           end

           if identical
               string = ['Identical     : ' files{itest}];
           else
               string = ['NOT Identical : ' files{itest}];
           end
        else
           string = ['New testcase  : ' files{itest}];
           movefile(files{itest},[files{itest} '.org']);
        end

        if ~isempty(opt.Filename)
            fprintf(fid,'%s',string);
        else
            disp(string);
        end
    end
end

if ~isempty(opt.Filename)
    fclose (fid);
end
