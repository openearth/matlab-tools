function simona2mdu_check

% check : performs a number of test conversions to check if everything went okay

%filwaq ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4'};
%filmdu ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-kustzuid-2004-v4\mdu\kzv4.mdu'};

filwaq ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\siminp.dcsmv6'};
filmdu ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\dcsmv6.mdu'};

for itest = 1 : length(filwaq)

    [path_mdu,name_mdu,~] = fileparts(filmdu{itest});
    if ~isdir(path_mdu);mkdir(path_mdu);end

    %
    % Convert
    %

    simona2mdu(filwaq{itest},filmdu{itest});


    %
    % Generate the list of files to compare
    %

    files = [];
    iifile = 0;
    contents = dir([path_mdu filesep name_mdu '*']);
    for ifile = 1: length(contents)
        index = strfind (contents(ifile).name,'org');
        if isempty (index)
            iifile = iifile + 1;
            files{iifile}    = [path_mdu filesep contents(ifile).name];
        end
    end

    %
    % Finally: compare
    %

    nesthd_cmpfiles(files);
end
