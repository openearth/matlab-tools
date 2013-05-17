function nesthd_compare (file_ini)

% compare: compare nesthd results with the benchmark (org) files

Info = inifile('open',file_ini);


files{1}=inifile('get',Info,'Nesthd2','Hydrodynamic Boundary conditions');
files{2}=inifile('get',Info,'Nesthd2','Transport Boundary Conditions   ');

for itest = 1:length(files)
    if ~isempty(files{itest})
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
        disp(string);
    end
end

