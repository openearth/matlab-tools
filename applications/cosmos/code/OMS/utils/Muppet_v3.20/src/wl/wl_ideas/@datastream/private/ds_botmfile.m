function [EntryOut,NowError]=ds_botmfile(EntryIn,FileData,FieldNr);
% DS_BOTMFILE is the data stream interface for a Delft3D-botm file
%
%      Three different calls to this function can be expected:
% 
%      1. [EntryOut,NowError]=DS_XXX(EntryIn,FileData)
%         To create a LoadField entry interactively or
%         as batch (given EntryName and EntryParameters)
%         based on data stored in FileData or the
%         associated file(s).
%      2. [EntryOut,NowError]=DS_XXX(EntryIn,FileData,'edit')
%         To edit a LoadField entry interactively based
%         on data stored in FileData or the associated file(s).
%      3. [FieldData,NowError]=DS_XXX(Entry,FileData,N)
%         To create and return field N of the LoadField entry based
%         on data stored in FileData or the associated file(s).

EntryOut=[];
NowError=1;
if (nargin==2) | ((nargin==3) & isequal('edit',FieldNr)), % cases 1 & 2
  Edit=(nargin==3);
  EntryOut=EntryIn;

  if Edit, uiwait(msgbox('Editing not yet implemented.','modal')); return; end;

  %  determine EntryName
  DataSets=strvcat( ...
     'morphologic grid X-coordinates', ...
     'morphologic grid Y-coordinates', ...
     'bottom', ...
     'X-dir. transport', ...
     'Y-dir. transport', ...
     'transport magnitude', ...
     'bottom time', ...
     'hydrodynamic grid X-coordinates', ...
     'hydrodynamic grid Y-coordinates');
  if isempty(EntryOut.EntryName),
    EntryNr=ui_select({1,'dataset'},DataSets);
    if EntryNr>size(DataSets,1), % cancel
      return;
    end;
    EntryOut.EntryName=deblank(DataSets(EntryNr,:));
  end;
  
  % determine EntryParameters and Fields
  switch EntryOut.EntryName,
  case {'morphologic grid X-coordinates','morphologic grid Y-coordinates'},
    EntryOut.NumberOfFields=1;
    GridInfo=vs_disp(FileData,'GRID','XCOR');
    EntryOut.FieldSize=GridInfo.SizeDim;
  case {'bottom','entrainment','X-dir. transport','Y-dir. transport','transport magnitude'}
    BottimInfo=vs_disp(FileData,'MAPBOTTIM',[]);
    TotalNFields=BottimInfo.SizeDim;
    EntryOut.NumberOfFields=TotalNFields;
    BottimInfo=vs_disp(FileData,'MAPBOTTIM','DP');
    EntryOut.FieldSize=BottimInfo.SizeDim;
  case 'bottom time',
    BottimInfo=vs_disp(FileData,'MAPBOTTIM',[]);
    TotalNFields=BottimInfo.SizeDim;
    EntryOut.NumberOfFields=TotalNFields;
    EntryOut.FieldSize=[1 1];
  case {'hydrodynamic grid X-coordinates','hydrodynamic grid Y-coordinates'},
    EntryOut.NumberOfFields=1;
    GridInfo=vs_disp(FileData,'TEMPOUT','XWAT');
    EntryOut.FieldSize=GridInfo.SizeDim;
  otherwise,
    return;
  end;
  switch EntryOut.EntryName,
  case {'bottom', ...
    'bottom time', ...
    'entrainment', ...
    'X-dir. transport', ...
    'Y-dir. transport', ...
    'transport magnitude'},
    if ~isfield(EntryOut.EntryParameters,'AnimateFields'),
      AniFlds=inputdlg('select fields for animation','Question',1,{['1:' num2str(EntryOut.NumberOfFields)]});
      if isempty(AniFlds),
        return;
      end;
      AniFlds=eval(AniFlds{1},'NaN');
      if isnumeric(AniFlds) & all(isfinite(AniFlds(:))) & all(AniFlds(:)==round(AniFlds(:))),
        EntryOut.EntryParameters.AnimateFields=min(EntryOut.NumberOfFields,max(1,AniFlds));
        EntryOut.NumberOfFields=length(EntryOut.EntryParameters.AnimateFields);
        NowError=0;
      end;
    else,
      EntryOut.NumberOfFields=length(EntryOut.EntryParameters.AnimateFields);
    end;
  otherwise,
    EntryOut.EntryParameters.AnimateFields=1;
    NowError=0;
  end;

elseif (nargin==3), % case 3
  FieldNr=EntryIn.EntryParameters.AnimateFields(FieldNr);
  switch EntryIn.EntryName,
  case 'morphologic grid X-coordinates',
    EntryOut=vs_get(FileData,'GRID',{1},'XCOR',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODB',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  case 'morphologic grid Y-coordinates',
    EntryOut=vs_get(FileData,'GRID',{1},'YCOR',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODB',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  case 'bottom',
    EntryOut=vs_get(FileData,'MAPBOTTIM',{FieldNr},'DP',{0 0},'quiet');
    EntryOut(EntryOut==-999)=NaN;
  case 'entrainment',
    EntryOut=vs_get(FileData,'MAPBOTTIM',{FieldNr},'EN',{0 0},'quiet');
  case 'X-dir. transport',
    EntryOut=vs_get(FileData,'MAPBOTTIM',{FieldNr},'TX',{0 0},'quiet');
  case 'Y-dir. transport',
    EntryOut=vs_get(FileData,'MAPBOTTIM',{FieldNr},'TY',{0 0},'quiet');
  case 'transport magnitude',
    Tx=vs_get(FileData,'MAPBOTTIM',{FieldNr},'TX',{0 0},'quiet');
    Ty=vs_get(FileData,'MAPBOTTIM',{FieldNr},'TY',{0 0},'quiet');
    EntryOut=sqrt(Tx.^2+Ty.^2);
  case 'bottom time',
    EntryOut=vs_get(FileData,'MAPBOTTIM',{FieldNr},'ITBODE',{1},'quiet');
  case 'hydrodynamic grid X-coordinates',
    EntryOut=vs_get(FileData,'TEMPOUT',{1},'XWAT',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODW',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  case 'hydrodynamic grid Y-coordinates',
    EntryOut=vs_get(FileData,'TEMPOUT',{1},'YWAT',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODW',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  otherwise,
    return;
  end;
  NowError=0;
end;
