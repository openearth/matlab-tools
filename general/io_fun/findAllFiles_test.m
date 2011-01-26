function OK = findAllFiles_test
%FINDALLFILES_TEST test for findAllFiles
%
%See also: findAllFiles, opendap_catalog, dir, ls

MTestCategory.Unit;

directory = fileparts(mfilename('fullpath'));
[files, directories] = findallfiles(directory);

% check whether this m file is found
% as well as the directory this mfile resides in
OK = sum(strcmp(files,[directory,filesep,'findAllFiles.m'])) & ...
     sum(strcmp(directories,[directory]));

