function Out=fm_file(cmd,NewFileData),
% FM_FILE file management of IDEAS
%          FM_FILE('get',NewFileData) % get File Data for active file
%          FM_FILE('set',NewFileData) % set File Data for active file

switch cmd,
case 'get',
  [Succes,Out]=md_filemem('usefile');
case 'set',
  Succes=md_filemem('newfileinfo',NewFileData);
end;

