function OK = inivalue_test
%inivalue_test test for inivalue
%
%See also: inivalue

MTestCategory.DataAccess;

url = 'https://repos.deltares.nl/repos/OpenEarthTools/trunk/';

% a url file is has *.ini format
iniFile = ([first_subdir(mfilename('fullpath'),-3) filesep 'OpenEarthTools Repository.url']);

% test reading one keyName
OK = strcmp(inivalue(iniFile,'InternetShortcut','URL'),url);

% test reading one sectionName
S     = inivalue(iniFile,'InternetShortcut');
OK(end+1) = strcmp(S.URL,url);
OK(end+1) = strcmp(S.IconFile,'https://repos.deltares.nl/favicon.ico');
OK(end+1) = strcmp(S.IconIndex,'1');

% test reading one fileName
S     = inivalue(iniFile);
OK(end+1) = strcmp(S.InternetShortcut.URL,url);
OK(end+1) = strcmp(S.InternetShortcut.IconFile,'https://repos.deltares.nl/favicon.ico');
OK(end+1) = strcmp(S.InternetShortcut.IconIndex,'1');

OK = all(OK);
