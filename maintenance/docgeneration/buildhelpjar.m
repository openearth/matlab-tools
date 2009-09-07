function buildhelpjar(helploc)
%  BUILDHELPJAR Package documentation into a help.jar file.
%     BUILDHELPJAR packages the HTML documentation found in a help 
%     location into a help.jar file.  The unpackaged HTML files will 
%     be moved into a directory named 'backup'.  This function will 
%     not package XML files into the help.jar file.
% 
%     This function is not supported and could change at any time.
%
%     Example:
%     buildhelpjar(fullfile(matlabroot, 'toolbox/mytoolbox/help')) -
%     packages the documentation found in the directory 
%     MATLAB/TOOLBOX/MYTOOLBOX/HELP into a help.jar file.

% Move the existing files into the backup directory.
backup = fullfile(helploc, 'backup');
movefile(fullfile(helploc, '*'), backup);

% Make sure that XML files are not added to the help.jar file.
movefile(fullfile(backup, '/*.xml'), helploc);

% Package the contents of the backup directory into the help.jar file.
zip(fullfile(helploc, 'help'), fullfile(backup ,'/*'));
movefile(fullfile(helploc, '/help.zip'), fullfile(helploc, '/help.jar'));
end