function [varargout] = compare_ncfiles (ncFile1,ncFile2)

%% Initialise
success   = true;
comments  = {};
thress    = 1.0e-8;

%%
info1 = ncinfo(ncFile1);
info2 = ncinfo(ncFile2);

info1_time = ncinfo(ncFile1, 'time');
info2_time = ncinfo(ncFile2, 'time');

if info1_time.Size == 1 || info2_time.Size == 1
    success = false;
    comments{end+1} = 'Only one timestep in history file';
end

if (success)
    setdiff({info1.Variables.Name},{info2.Variables.Name})';
    setdiff({info2.Variables.Name},{info1.Variables.Name})';

    vars = intersect({info2.Variables.Name},{info1.Variables.Name});

    for iV = 1:length(vars)
        val1 = nc_varget(ncFile1, vars{iV});
        val2 = nc_varget(ncFile2, vars{iV});
        dif  = val1 - val2;
        if max(max(max(max(abs(dif))))) > thress
            if success success = false; end
            [~,name,~]      = fileparts(ncFile1);
            comments{end+1} = ['Differeces exceed thresshold for case :' name ' , Variable : ' vars{iV}];
        end
    end
end

varargout{1} = success;
varargout{2} = comments;

end
