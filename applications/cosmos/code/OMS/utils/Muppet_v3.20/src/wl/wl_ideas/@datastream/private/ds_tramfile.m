function [EntryOut,NowError]=ds_tramfile(EntryIn,FileData,FieldNr);
% DS_TRAMFILE is the data stream interface for a Delft3D-tram file
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
     'hydrodynamic grid X-coordinates', ...
     'hydrodynamic grid Y-coordinates', ...
     'average bedload transport xi-direction', ...
     'average bedload transport eta-direction', ...
     'average bedload transport', ...
     'average suspended transport xi-direction', ...
     'average suspended transport eta-direction', ...
     'average suspended transport', ...
     'average total sediment transport xi-direction', ...
     'average total sediment transport eta-direction', ...
     'average total sediment transport');
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
  case {'hydrodynamic grid X-coordinates','hydrodynamic grid Y-coordinates'},
    EntryOut.NumberOfFields=1;
    GridInfo=vs_disp(FileData,'TEMPOUT','XWAT');
    EntryOut.FieldSize=GridInfo.SizeDim;
  case  {'average bedload transport xi-direction','average bedload transport eta-direction','average bedload transport', ...
         'average suspended transport xi-direction','average suspended transport eta-direction','average suspended transport', ...
         'average total sediment transport xi-direction','average total sediment transport eta-direction','average total sediment transport'},
    MAPATRANInfo=vs_disp(FileData,'MAPATRAN',[]);
    TotalNFields=MAPATRANInfo.SizeDim;
    EntryOut.NumberOfFields=TotalNFields;
    TransInfo=vs_disp(FileData,'MAPATRAN','TTXA');
    EntryOut.FieldSize=TransInfo.SizeDim;
  otherwise,
    return;
  end;
  switch EntryOut.EntryName,
  case {'average bedload transport xi-direction', ...
     'average bedload transport eta-direction', ...
     'average bedload transport', ...
     'average suspended transport xi-direction', ...
     'average suspended transport eta-direction', ...
     'average suspended transport', ...
     'average total sediment transport xi-direction', ...
     'average total sediment transport eta-direction', ...
     'average total sediment transport'},
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
  case 'hydrodynamic grid X-coordinates',
    EntryOut=vs_get(FileData,'TEMPOUT',{1},'XWAT',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODW',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  case 'hydrodynamic grid Y-coordinates',
    EntryOut=vs_get(FileData,'TEMPOUT',{1},'YWAT',{0 0},'quiet');
    Active=vs_get(FileData,'TEMPOUT',{1},'CODW',{0 0},'quiet');
    EntryOut(Active<0)=NaN;
  case 'average bedload transport xi-direction',
    EntryOut=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXA',{0 0},'quiet');
  case 'average bedload transport eta-direction',
    EntryOut=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYA',{0 0},'quiet');
  case 'average bedload transport',
    TX=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXA',{0 0},'quiet');
    TY=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYA',{0 0},'quiet');
    EntryOut=sqrt(TX.^2+TY.^2);
  case 'average suspended transport xi-direction',
    EntryOut=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXSA',{0 0},'quiet');
  case 'average suspended transport eta-direction',
    EntryOut=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYSA',{0 0},'quiet');
  case 'average suspended transport',
    TX=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXSA',{0 0},'quiet');
    TY=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYSA',{0 0},'quiet');
    EntryOut=sqrt(TX.^2+TY.^2);
  case 'average total sediment transport xi-direction',
    TXb=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXA',{0 0},'quiet');
    TXs=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXSA',{0 0},'quiet');
    EntryOut=TXb+TXs;
  case 'average total sediment transport eta-direction',
    TYb=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYA',{0 0},'quiet');
    TYs=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYSA',{0 0},'quiet');
    EntryOut=TYb+TYs;
  case 'average total sediment transport',
    TXb=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXA',{0 0},'quiet');
    TXs=vs_get(FileData,'MAPATRAN',{FieldNr},'TTXSA',{0 0},'quiet');
    TYb=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYA',{0 0},'quiet');
    TYs=vs_get(FileData,'MAPATRAN',{FieldNr},'TTYSA',{0 0},'quiet');
    EntryOut=sqrt((TXb+TXs).^2+(TYb+TYs).^2);
  otherwise,
    return;
  end;
  NowError=0;
end;