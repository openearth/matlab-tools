function simona2mdf_check

% check : performs a number of test conversions to check if ewverything went okay

% filwaq ={'..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp.fou'; 
%          '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp'    ;
%          '..\test\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4'    ;
%          '..\test\simona\A80\siminp.dcsmv6'                                          ;
%          '..\test\simona\A80\siminp.zunov4'}                                         ;
% filmdf = {'..\test\simona\simona-scaloost-fijn-exvd-v1\mdf_fou\scaloost_fou.mdf'      ;
%          '..\test\simona\simona-scaloost-fijn-exvd-v1\mdf\scaloost.mdf'              ;
%          '..\test\simona\simona-kustzuid-2004-v4\mdf\kzv4.mdf'                       ;
%          '..\test\simona\A80\mdf_csm\dcsmv6.mdf'                                     ;
%          '..\test\simona\A80\mdf_zuno\zunov4.mdf'}                                   ; 

filwaq = {'..\test\simona\A80\siminp.zunov4'};
filmdf = {'..\test\simona\A80\mdf_zuno\zunov4.mdf'};

for itest = 1: length(filwaq);
    [path_mdf,name_mdf,~] = fileparts(filmdf{itest});
    if ~isdir(path_mdf);mkdir(path_mdf);end
    simona2mdf(filwaq{itest},filmdf{itest});
    contents = dir([path_mdf filesep name_mdf '*']);
    for ifile = 1: length(contents)
        index = strfind (contents(ifile).name,'org');
        if isempty (index)
            files{ifile}    = [path_mdf filesep contents(ifile).name];
        end
    end
    nesthd_cmpfiles(files);
end
