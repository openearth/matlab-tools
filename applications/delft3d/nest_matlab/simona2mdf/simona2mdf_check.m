function simona2mdf_check

% check : performs a number of test conversions to check if ewverything went okay

filwaq ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp.fou';
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp'    ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4'    ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\siminp.dcsmv6'                                          ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\siminp.zunov4'}                                         ;
filmdf ={'d:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-scaloost-fijn-exvd-v1\mdf_fou\scaloost_fou.mdf'      ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-scaloost-fijn-exvd-v1\mdf\scaloost.mdf'              ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\simona-kustzuid-2004-v4\mdf\kzv4.mdf'                       ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\mdf_csm\dcsmv6.mdf'                                     ;
         'd:\open_earth_test\matlab\applications\delft3d\nest_matlab\simona\A80\mdf_zuno\zunov4.mdf'}                                   ;

%for itest = 1: length(filwaq)
    for itest = 3:3
    
    [path_mdf,name_mdf,~] = fileparts(filmdf{itest});
    if ~isdir(path_mdf);mkdir(path_mdf);end
    
    %
    % Convert
    %
    
    simona2mdf(filwaq{itest},filmdf{itest});

    %
    % Generate the list of files to compare
    %
    
    files = [];
    iifile = 0;
    contents = dir([path_mdf filesep name_mdf '*']);
    for ifile = 1: length(contents)
        index = strfind (contents(ifile).name,'org');
        if isempty (index)
            iifile = iifile + 1;         
            files{iifile}    = [path_mdf filesep contents(ifile).name];
        end
    end
    
    %
    % Finally: compare 
    %
    
    nesthd_cmpfiles(files);
end
