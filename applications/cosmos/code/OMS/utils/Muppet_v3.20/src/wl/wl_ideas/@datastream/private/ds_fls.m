function [EntryOut,NowError]=ds_fls(EntryIn,FileData,FieldNr);
% DS_FLS is the data stream interface for fls-files
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
     'grid X-coordinates', ...
     'grid Y-coordinates', ...
     'bottom', ...
     '[MAP] waterdepth', ...
     '[MAP] waterlevel', ...
     '[MAP] velocity U', ...
     '[MAP] velocity V', ...
     '[MAP] velocity magnitude', ...
     '[MAP] time', ...
     '[INC] waterdepth', ...
     '[INC] waterlevel', ...
     '[INC] velocity U', ...
     '[INC] velocity V', ...
     '[INC] velocity magnitude', ...
     '[INC] time', ...
     '[BIN] waterdepth', ...
     '[BIN] waterlevel', ...
     '[BIN] velocity U', ...
     '[BIN] velocity V', ...
     '[BIN] velocity magnitude', ...
     '[BIN] time', ...
     '[HIS] waterdepth', ...
     '[HIS] waterlevel', ...
     '[HIS] velocity U', ...
     '[HIS] velocity V', ...
     '[HIS] velocity magnitude', ...
     '[HIS] time', ...
     '[CRS] discharge', ...
     '[CRS] time');
  if isempty(EntryOut.EntryName),
    EntryNr=ui_select({1,'dataset'},DataSets);
    if EntryNr>size(DataSets,1), % cancel
      return;
    end;
    EntryOut.EntryName=deblank(DataSets(EntryNr,:));
  end;
  
  % determine EntryParameters and Fields
  switch EntryOut.EntryName,
  case {'grid X-coordinates','grid Y-coordinates','bottom'},
    EntryOut.NumberOfFields=1;
    EntryOut.FieldSize=FileData.Size;
  otherwise,
    return;
  end;
  switch EntryOut.EntryName,
  case {'LIST1', ...
     'LIST2'},
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
  case 'grid X-coordinates',
    EntryOut=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
  case 'grid Y-coordinates',
    EntryOut=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)-(1:FileData.Size(2))*FileData.GridSize);
  case 'bottom',
    EntryOut=-FileData.Depth;
  otherwise,
    return;
  end;
  NowError=0;
end;