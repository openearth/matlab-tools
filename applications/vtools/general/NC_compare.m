%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20320 $
%$Date: 2025-09-15 08:29:13 +0200 (Mon, 15 Sep 2025) $
%$Author: chavarri $
%$Id: floris_to_fm_read_funin.m 20320 2025-09-15 06:29:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/floris_to_fm/floris_to_fm_read_funin.m $
%
%NC_COMPARE Compare two NetCDF files
% Returns true if all variables and data are identical

function is_equal = NC_compare(file1, file2)

    % Get file info
    info1 = ncinfo(file1);
    info2 = ncinfo(file2);

    % Check number of variables
    if numel(info1.Variables) ~= numel(info2.Variables)
        is_equal = false;
        return
    end

    % Check variable names
    names1 = {info1.Variables.Name};
    names2 = {info2.Variables.Name};
    if ~isequal(sort(names1), sort(names2))
        is_equal = false;
        return
    end

    % Compare data for each variable
    is_equal = true;
    for k = 1:numel(info1.Variables)
        var_name = info1.Variables(k).Name;
        data1 = ncread(file1, var_name);
        data2 = ncread(file2, var_name);

        % Use isequaln to treat NaNs as equal
        if ~isequaln(data1, data2)
            is_equal = false;
            return
        end
    end
end