function [Succes,FileInfo]=md_filemem(cmd,varargin),
% MD_FILEMEM store file information and update popupmenus and buttons
%
%   [Succes,FileInfo]=md_filemem('openfile');
%   [Succes,FileInfo]=md_filemem('openfile',FileType,FileName);
%   Succes=md_filemem('closefile');
%   FileNameList=md_filemem('listfiles');
%   [Succes,FileInfo]=md_filemem('usefile');
%   Succes=md_filemem('selectfile',Handle_FileList);
%   Succes=md_filemem('selectfile',Handle_FileClose);
%   Succes=md_filemem('addinterface',Handle_FileList,Handle_FileClose);
%   Succes=md_filemem('delinterface',Handle_FileList);
%   Succes=md_filemem('delinterface',Handle_FileClose);
%   Succes=md_filemem('newfileinfo',FileInfo);
%   [Succes,FileInfo]=md_filemem('getfileinfo',FileName);
%
%   See also FMI

persistent AbbrFileNameList FileNameList FileTypeList FileDataList SelectedFile Handle_FileClose Handle_FileList
mlock

if isempty(FileDataList),
  FileNameList=' ';
  AbbrFileNameList=' ';
  FileTypeList=' ';
  FileDataList={};
  SelectedFile=1;
end;

if isempty(Handle_FileList),
  Handle_FileList=[];
  Handle_FileClose=[];
else,
  Exist=ishandle(Handle_FileList) & ishandle(Handle_FileClose);
  Handle_FileList=Handle_FileList(Exist);
  Handle_FileClose=Handle_FileClose(Exist);
end;

if nargout>0,
  FileInfo=[];
  Succes=0;
end;

if nargin<1, return; end;

switch cmd,
case 'newfileinfo',

  %----------------------------------------------------------------
  % determine filename 
  if nargin>1, % md_filemem('newfileinfo',FileInfo) called
    FileName=varargin{1}.FileName;
  end;
  % is the file still open? Checking the selected filename ...
  NrInList=strmatch(FileName,FileNameList,'exact');
  if ~isempty(NrInList),
    % file is already open, select it
    FileDataList{NrInList}=varargin{1}.Data;
    Succes=1;
  else,
    % file is not open anymore, add it
    Succes=0;
  end;
  %----------------------------------------------------------------

case 'openfile',

  %----------------------------------------------------------------
  % determine filename 
  if nargin>1, % md_filemem('openfile','filetype','filename') called
    FileType=varargin{1};
    FileName=varargin{2};
  else, % md_filemem('openfile') called
    if isempty(FileDataList),
      [FileName,FileType]=ui_getfile;
    else,
      % start file open with currently selected file
      FileName=deblank(FileNameList(SelectedFile,:));
      FileType=deblank(FileTypeList(SelectedFile,:));
      [FileName,FileType]=ui_getfile(FileName,FileType);
    end;
    if isempty(FileName),
      return;
    end;
  end;

  % has the file already been opened? Checking the selected filename ...
  NrInList=strmatch(FileName,FileNameList,'exact');
  if ~isempty(NrInList),
    % file is already open, select it
    SelectedFile=NrInList;
    FileInfo.Data=FileDataList{NrInList};
    FileInfo.FileName=deblank(FileNameList(NrInList,:));
    FileInfo.FileType=deblank(FileTypeList(NrInList,:));

    set(Handle_FileList,'value',SelectedFile);

    Succes=1;

  else,
    % file is not yet open, add it to the list
  
    % define filedata
    FileInfo.Data=[]; % empty by default
    switch FileType,
    case {'MORSYS output file','nefis file','Delft3D-com','Delft3D-trim','Delft3D-tram','Delft3D-trah','Delft3D-trih','Delft3D-botm','Delft3D-trid','Delft3D-hwgxy'},
      FileInfo.Data=vs_use(FileName);
      if ~isempty(FileInfo.Data.FileName), % nefis file!
        FileName=[FileInfo.Data.FileName FileInfo.Data.DatExt];
        if strcmp(FileType,'nefis file'),
          FileType=vs_type(FileInfo.Data);
        elseif ~strcmp(FileType,vs_type(FileInfo.Data)),
          Str=sprintf('Specified file of incorrect nefis type.');
          uiwait(msgbox(Str,'modal'));
          return;
        end;
        if strcmp(FileType,'unknown'),
          Str=sprintf('Unknown nefis file.');
          uiwait(msgbox(Str,'modal'));
          return;
        end;
      else,
        Str=sprintf('This is not a nefis file');
        uiwait(msgbox(Str,'modal'));
        return;
      end;
    case 'TEKAL file',
      FileInfo.Data=tekal('open',FileName);
    case 'Delft3D grid file',
      FileInfo.Data=grdread(FileName);
    case 'Delft3D bottom file',
      FileInfo.Data=depread(FileName);
    case 'morf file',
      FileInfo.Data=morf('read',FileName);
    case 'FLS mdf file',
      FileInfo.Data=fls('read',FileName);
    case 'incremental file',
      FileInfo.Data=fls('open',FileName);
    case 'FLS output file',
      FlSep=max([1 max(findstr(FileName,filesep))+1]);
      Dot=min([length(FileName)-FlSep+1 max(findstr(FileName(FlSep:end),'.'))]);
      Ext=FileName((FlSep+Dot):end);
      switch upper(Ext),
      case 'INC',
        FileInfo.Data=fls('readinc',FileName);
        FileType='MDF incremental file';
      case 'HIS',
        FileInfo.Data=fls('readhis',FileName);
        FileType='MDF history file';
      case 'CRS',
        FileInfo.Data=fls('readcross',FileName);
        FileType='MDF cross-section file';
      case 'BIN',
        FileInfo.Data=fls('readbin',FileName);
        FileType='MDF binary history file';
      case 'AM*',
        FileInfo.Data=arcgrid('read',FileName);
        FileType='arcgrid file';
      end;
    case 'arcinfo file',
      if strcmp('E00',upper(FileName(max(1,end-2):end))),
        FileInfo.Data=arcinfo('opene00',FileName);
        FileType='ArcInfo E00 export file';
      else,
        FileInfo.Data=arcinfo('open',FileName);
        FileType='ArcInfo coverage';
      end;
    case 'arcgrid file',
      FileInfo.Data=arcgrid('read',FileName);
%    case 'mike 21 file',
%      FileInfo.Data=mike21('read',FileName);
    case 'arcgrid file',
      FileInfo.Data=arcgrid('read',FileName);
    case 'AVS file',
      FlSep=max([1 max(findstr(FileName,filesep))+1]);
      Dot=min([length(FileName)-FlSep+1 max(findstr(FileName(FlSep:end),'.'))]);
      Ext=FileName((FlSep+Dot):end);
      switch upper(Ext),
      case 'INP',
        FileInfo.Data=avs('openinp',FileName);
        FileType='AVS input file';
      case 'FLD',
        FileInfo.Data=avs('openfld',FileName);
        FileType='AVS field file';
      end;
    case 'CFX file',
      FlSep=max([1 max(findstr(FileName,filesep))+1]);
      Dot=min([length(FileName)-FlSep+1 max(findstr(FileName(FlSep:end),'.'))]);
      Ext=FileName((FlSep+Dot):end);
      switch upper(Ext),
      case 'DMP',
        FileInfo.Data=cfx('opendmp',FileName);
        FileType='CFX dump file';
      case 'GEO',
        FileInfo.Data=cfx('opengeo',FileName);
        FileType='CFX geometry file';
      case 'FO',
        FileInfo.Data=cfx('openfo',FileName);
        FileType='CFX output file';
      end;
    otherwise,
      Str=sprintf(['How should a ',FileType,' be opened?']);
      uiwait(msgbox(Str,'modal'));
      return;
    end;
    FileInfo.FileName=FileName;
    FileInfo.FileType=FileType;

    % has the file already been opened? Checking the latest filename ...
    NrInList=strmatch(FileName,FileNameList,'exact');
    if ~isempty(NrInList),
      % file is already open, select it
      SelectedFile=NrInList;
      FileInfo.Data=FileDataList{NrInList};
      FileInfo.FileName=deblank(FileNameList(NrInList,:));
      FileInfo.FileType=deblank(FileTypeList(NrInList,:));

      set(Handle_FileList,'value',SelectedFile);

      Succes=1;

      return;
    end;

    % Did the subprogram succesfully read the datafile?
    if isempty(FileInfo.Data), % check also on CheckOK
      Str=['Reading ',FileName,' failed.'];
      uiwait(msgbox(Str,'modal'));
      return;
    end;

    if isempty(FileDataList),
      FileNameList=FileName;
      AbbrFileNameList=abbrevfn(FileName);
      FileTypeList=FileType;
      FileDataList{1}=FileInfo.Data;
    else,
      FileNameList=str2mat(FileNameList,FileName);
      AbbrFileNameList=str2mat(AbbrFileNameList,abbrevfn(FileName));
      FileTypeList=str2mat(FileTypeList,FileType);
      FileDataList{end+1}=FileInfo.Data;
    end;

    SelectedFile=length(FileDataList);

    set([Handle_FileList(:);Handle_FileClose(:)],'enable','on');
    set(Handle_FileList,'value',SelectedFile,'string',AbbrFileNameList);
  end;

  Succes=1;
  %----------------------------------------------------------------

case 'getfileinfo',

  %----------------------------------------------------------------
  % occurs the file in the list?
  NrInList=strmatch(varargin{1},FileNameList,'exact');
  if ~isempty(NrInList),
    % file is already open, select it
    FileInfo.Data=FileDataList{NrInList};
    FileInfo.FileName=deblank(FileNameList(NrInList,:));
    FileInfo.FileType=deblank(FileTypeList(NrInList,:));
    Succes=1;
  end;
  %----------------------------------------------------------------

case 'closefile',

  %----------------------------------------------------------------
  if nargin==1,
    CloseFiles=SelectedFile;
  else,
    CloseFiles=varargin{1};
  end;
  FileNotClose=setdiff(1:size(FileNameList,1),CloseFiles);
  FileNameList=deblank(FileNameList(FileNotClose,:));
  AbbrFileNameList=deblank(AbbrFileNameList(FileNotClose,:));
  FileTypeList=deblank(FileTypeList(FileNotClose,:));
  FileDataList=FileDataList(FileNotClose);
  SelectedFile=1;
  if isempty(FileNameList),
    AbbrFileNameList=' ';
    FileNameList=' '; % 'string' property of popupmenu is not allowed to be empty

    set([Handle_FileList;Handle_FileClose],'enable','off');
  end;

  set(Handle_FileList,'value',SelectedFile,'string',AbbrFileNameList);

  Succes=1;
  %----------------------------------------------------------------

case 'selectfile',

  %----------------------------------------------------------------
  if isequal(size(varargin{1}),[1 1]) & (round(varargin{1})==varargin{1}) & (varargin{1}>0) & (varargin{1}<length(FileDataList)),
    IndexNr=varargin{1};
  else,
    IndexNr=find(Handle_FileList==varargin{1});
    if isempty(IndexNr),
      IndexNr=find(Handle_FileClose==varargin{1});
    end;
  end;

  if ~isempty(IndexNr),
    SelectedFile=get(Handle_FileList(IndexNr),'value');
    set(Handle_FileList,'value',SelectedFile);
  end;

  Succes=1;
  %----------------------------------------------------------------

case 'listfiles',

  %----------------------------------------------------------------
  if nargout==0,
    for i=1:length(FileDataList),
      fprintf(1,'%s\n',deblank(FileNameList(i,:)));
    end;
  else,
    if isempty(FileDataList),
      Succes='';
    else,
      Succes=FileNameList;
    end;
  end;
  %----------------------------------------------------------------

case 'usefile',

  %----------------------------------------------------------------
  if ~isempty(FileDataList),
    FileInfo.FileName=deblank(FileNameList(SelectedFile,:));
    FileInfo.FileType=deblank(FileTypeList(SelectedFile,:));
    FileInfo.Data=FileDataList{SelectedFile};

    Succes=1;
  end;
  %----------------------------------------------------------------

case 'addinterface',

  %----------------------------------------------------------------
  if isempty(varargin{1}) | isempty(varargin{2}),
    return; 
  end;
  Handle_FileList =[Handle_FileList;  varargin{1}];
  Handle_FileClose=[Handle_FileClose; varargin{2}];

  set(Handle_FileList(end),'value',SelectedFile,'string',AbbrFileNameList);
  if isempty(FileDataList),
    set([Handle_FileList(end);Handle_FileClose(end)],'enable','off');
  else,
    set([Handle_FileList(end);Handle_FileClose(end)],'enable','on');
  end;

  Succes=1;
  %----------------------------------------------------------------

case 'delinterface',

  %----------------------------------------------------------------
  IndexNr=find(Handle_FileList==varargin{1});
  if isempty(IndexNr),
    IndexNr=find(Handle_FileClose==varargin{1});
  end;
  
  if ~isempty(IndexNr),
    set(Handle_FileList(IndexNr),'value',1,'string',' ');
    set([Handle_FileList(IndexNr);Handle_FileClose(IndexNr)],'enable','off');
    Handle_FileList(IndexNr)=[];
    Handle_FileClose(IndexNr)=[];

    Succes=1;
  end;
  %----------------------------------------------------------------

case {'?','inspection'},

  %----------------------------------------------------------------
  keyboard;

  if nargout>0,
    Succes=1;
  end;
  %----------------------------------------------------------------
end;
