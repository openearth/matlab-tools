function it=md_createitem(ax),

it=[];

if isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'IDEAS - main'),
  mfig=findobj(allchild(0),'flat','tag','IDEAS - main');
else,
  mfig=gcbf;
end;

axoptions=get(ax,'userdata');
itoptions=[];
itoptions.Editable=1;
itoptions.Name='[unknown item]';
itoptions.Animation=[];
itoptions.UserData=[];

% should a special object be created?
if ~isfield(axoptions,'Type'),
  addto(axoptions.Object);
  it=[]; % dummy argument
  return;
else,
  switch axoptions.Type,
  case 'LEGEND',
    it=md_legend(ax,'add',itoptions);
    if isempty(it),
      return;
    end;
    set(it,'tag',num2hex(it(1)));
  case 'OBJECT',
    % which file is selected
    [Succes,FileInfo]=md_filemem('usefile');
    if Succes,
      FileType=FileInfo.FileType;
      FileName=FileInfo.FileName;
      itoptions.ReproData.FileType=FileType;
      itoptions.ReproData.FileName=FileName;
      itoptions.ReproData.Type=axoptions.ObjectType;
  
      try,
        switch(FileType)
        case 'Delft3D-com',
          it=di_comfile(FileInfo,ax,itoptions);
        case 'Delft3D-trim',
          it=di_trimfile(FileInfo,ax,itoptions);
        case 'Delft3D-tram',
          it=di_tramfile(FileInfo,ax,itoptions);
        case 'Delft3D-botm',
          it=di_botmfile(FileInfo,ax,itoptions);
        case 'FLS mdf file',
          it=di_fls(FileInfo,ax,itoptions);
        case 'incremental file',
          it=di_inc(FileInfo,ax,itoptions);
        otherwise,
          uiwait(msgbox({['I cannot plot ',axoptions.ObjectType,' using'],['the ',itoptions.ReproData.FileType,' data.']},'modal'));
          return;
        end;
      catch,
        ui_message('error',lasterr);
        it=[];
      end;
      return;
    end;
  case 'annotation layer',
    it=md_annotation(ax,itoptions);
    if isempty(it),
      return;
    end;
    set(it,'tag',num2hex(it(1)));
  end;
end;
% which file is selected?
[Succes,FileInfo]=md_filemem('usefile');
if Succes,
  FileType=FileInfo.FileType;
  FileName=FileInfo.FileName;
  itoptions.ReproData.FileType=FileType;
  itoptions.ReproData.FileName=FileName;

  try,
  switch(FileType)
  case 'Delft3D-com',
    ItemsFromFile=di_comfile(FileInfo,ax);
  case 'Delft3D-trim',
    ItemsFromFile=di_trimfile(FileInfo,ax);
  case 'Delft3D-tram',
    ItemsFromFile=di_tramfile(FileInfo,ax);
  case 'Delft3D-botm',
    ItemsFromFile=di_botmfile(FileInfo,ax);
  case 'morf file',
    ItemsFromFile=di_morf(FileInfo,ax);
  case 'FLS mdf file',
    ItemsFromFile=di_fls(FileInfo,ax);
  case 'incremental file',
    ItemsFromFile=di_inc(FileInfo,ax);
  case 'arcinfo file',
    ItemsFromFile=di_arcinfo(FileInfo,ax);
  case 'arcgrid file',
    ItemsFromFile=di_arcgrid(FileInfo,ax);
  otherwise,
    uiwait(msgbox({'I don''t know what can be plotted using',['the ',FileType,' data.']},'modal'));
    ItemsFromFile='';
  end;
  catch,
    ui_message('error',lasterr);
    ItemsFromFile=[];
  end;
else,
  ItemsFromFile='';
end;

GeneralItems=ob_ideas(ax,'possible');

if isempty(ItemsFromFile),
  PossibleItems=GeneralItems;
else,
  PossibleItems=strvcat(ItemsFromFile,'-------',GeneralItems);
end;

itoptions.ReproData.Type=ui_type('object',PossibleItems);
GeneralItem=strmatch(itoptions.ReproData.Type,GeneralItems,'exact');
if isempty(itoptions.ReproData.Type), % cancel was pressed
  it=[];
  return;
elseif strcmp(itoptions.ReproData.Type,'-------'),
  it=[];
  return;
elseif GeneralItem, % general item selected
  it=ob_ideas(itoptions.ReproData.Type,ax);
else, % item from file selected
  itoptions.ReproData.Name=itoptions.ReproData.Type;
  switch(itoptions.ReproData.FileType), % create item
  case 'Delft3D-com',
    it=di_comfile(FileInfo,ax,itoptions);
  case 'Delft3D-trim',
    it=di_trimfile(FileInfo,ax,itoptions);
  case 'Delft3D-tram',
    it=di_tramfile(FileInfo,ax,itoptions);
  case 'Delft3D-botm',
    it=di_botmfile(FileInfo,ax,itoptions);
  case 'morf file',
    it=di_morf(FileInfo,ax,itoptions);
  case 'FLS mdf file',
    it=di_fls(FileInfo,ax,itoptions);
  case 'incremental file',
    it=di_inc(FileInfo,ax,itoptions);
  case 'arcinfo file',
    it=di_arcinfo(FileInfo,ax,itoptions);
  case 'arcgrid file',
    it=di_arcgrid(FileInfo,ax,itoptions);
  otherwise,
    uiwait(msgbox({'I don''t know what can be plotted using',['the ',itoptions.ReproData.FileType,' data.']},'modal'));
    it=[];
  end;
end;
%if ~isempty(it),
%  itoptions=get(it(1),'userdata');
%  if isfield(itoptions,'Name'),
%    CmdS.Name=itoptions.Name;
%  else,
%    CmdS.Name=get(it(1),'tag');
%  end;
%  CmdS.Handles=it;
%  CmdS.Info=get(it(1),'userdata');
%  ob_dummy(get(it(1),'parent'),CmdS);
%  it=[];
%end;