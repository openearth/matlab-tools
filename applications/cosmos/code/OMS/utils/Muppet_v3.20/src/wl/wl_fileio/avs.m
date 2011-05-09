function Out=avs(cmd,varargin),
% AVS File operations for AVS files.
%        FileData = avs('openinp','filename');
%           Reads an AVS .inp file.
%        FileData = avs('readinp',AVSinp,T,'GEOM');
%           Reads from an AVS .inp file the geometry data
%           at time T.
%        FileData = avs('readinp',AVSinp,T,Location,Variable);
%           Reads from an AVS .inp file variable 'Variable' at
%           the Location 'NODE' or 'CELL' at time T.
%        FileData = avs('cfxdmp2inp',CFXdmp,AVSinp);
%           Converts a CFX .dmp file to AVS .inp file.

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'openinp',
  Structure=Local_interpret_inp_file(varargin{:});
  Out=Structure;
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    elseif strcmp(Structure.Check,'NotOK'),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'readinp',
  Out=Local_read_inp_file(varargin{:});
case 'writeinp',
%  Structure=Local_write_inp_file(varargin{:});
case 'openfld',
  Structure=Local_interpret_fld_file(varargin{:});
  Out=Structure;
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    elseif strcmp(Structure.Check,'NotOK'),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'cfxdmp2inp',
  Structure=Local_convert_dmp2inp(varargin{:});
case 'patch2inp',
  Structure=Local_convert_dmp2inp_patch(varargin{:});
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function Structure=Local_interpret_fld_file(filename),
Structure.Check='NotOK';
%
% How to store geom data?
% CellArray: cell array containing for each cell type
% [ Point, Line, Triangle, Quadrilateral, Tetrahedral, Pyramid, Prism, Hexahedral ]
% a cellset.
% CellSet: matrix containing cell corners
% Unstructured Meshes can contain all types of cells
% Structured/Irregular/Curvilinear meshes implicitely contain one type of cell
%     (either points/lines, quadrilateral, hexahedral)
% Rectilinear meshes implicitely contain quadrilateral cells
% Uniform meshes implicitely contain quadrilateral cells
%
if nargin<1,
  [fn,fp]=uigetfile('*.fld');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;

fid=fopen(filename,'r');
Structure.FileName=filename;

Line=fgetl(fid);
if ~isequal(Line(1:5),'# AVS'),
  fclose(fid);
  fprintf(1,'Not an AVS field file');
  return;
end;

Loc=ftell(fid);
Line=fgetl(fid);
Structure.Label={};
Structure.Unit={};
Structure.NDim=-1;
Structure.NSpace=-1;
Structure.VecLen=-1;
Structure.NStep=1;
t=1;
while ischar(Line),
  if length(Line)>=2, % check for native field input
    if isequal(abs(Line(1:2)),[12 12]), % start of binary section
      Structure.BinSection=Loc+2;
      break;
    end;
  end;
  Fence=findstr(Line,'#');
  if ~isempty(Fence), % if comment on line, remove it
    Line=Line(1:(Fence(1)-1));
  end;
  if ~isempty(Line),
    Equal=findstr(Line,'=');
    if ~isempty(Equal), % Token=Value or coord i file=... or variable i file=...
      Token=lower(deblank2(Line(1:(Equal(1)-1))));
      Value=lower(deblank2(Line((Equal(1)+1):end)));
      switch Token,
      case 'ndim', % required
        Structure.NDim=str2num(Value);
        if ~isequal(size(Structure.NDim),[1 1]) | any(isnan(Structure.NDim)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'nspace', % required
        Structure.NSpace=str2num(Value);
        if ~isequal(size(Structure.NSpace),[1 1]) | any(isnan(Structure.NSpace)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'veclen', % required
        Structure.VecLen=str2num(Value);
        if ~isequal(size(Structure.VecLen),[1 1]) | any(isnan(Structure.VecLen)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'data', % required
        Structure.Data=lower(Value);
        DataTypes={'byte','integer','float','double','xdr_integer','xdr_float','xdr_double'};
        if isempty(strmatch(Structure.Data,DataTypes,'exact')),
          fprintf(1,['Unknown data type in line:\n' Line '\n']);
          return;
        end;
      case 'field', % required
        Structure.Field=lower(Value);
        FieldTypes={'uniform','rectilinear','irregular'}; % unstructured
        % uniform    : mind1, maxd1, mind2, maxd2, ...
        % rectilinear: d1coords vector, d2coords vector, ...
        % irregular  : d1coords for all points, d2coords for all points, ...
        % unstructured: coords for all points, cell defintions
        if isempty(strmatch(Structure.Field,FieldTypes,'exact')),
          fprintf(1,['Unknown field type in line:\n' Line '\n']);
          return;
        end;
      case 'nstep', % optional
        Structure.NStep=str2num(Value);
        if ~isequal(size(Structure.NStep),[1 1]) | any(isnan(Structure.NStep)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'min_ext', % optional
        Structure.MinExt=str2num(['[' Value ']']);
        if ~isequal(size(Structure.MinExt),[1 Structure.NSpace]) | any(isnan(Structure.MinExt)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'max_ext', % optional
        Structure.MaxExt=str2num(['[' Value ']']);
        if ~isequal(size(Structure.MaxExt),[1 Structure.NSpace]) | any(isnan(Structure.MaxExt)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'label', % optional
        T=tokens(Value);
        for i=1:length(T),
          Structure.Label{end+1}=T{i};
        end;
        if length(Structure.Label)>Structure.VecLen,
          fprintf(1,'Warning: Too many labels specified.\n');
        end;
      case 'unit', % optional
        T=tokens(Value);
        for i=1:length(T),
          Structure.Unit{end+1}=T{i};
        end;
        if length(Structure.Label)>Structure.VecLen,
          fprintf(1,'Warning: Too many unit labels specified.\n');
        end;
      case 'min_val', % optional
        Structure.MinVal=str2num(['[' Value ']']);
        if ~isequal(size(Structure.MinVal),[1 Structure.VecLen]) | any(isnan(Structure.MinVal)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      case 'max_val', % optional
        Structure.MaxVal=str2num(['[' Value ']']);
        if ~isequal(size(Structure.MaxVal),[1 Structure.VecLen]) | any(isnan(Structure.MaxVal)),
          fprintf(1,['Error interpreting:\n' Line '\n']);
          fclose(fid);
          return;
        end;
      otherwise,
        if strmatch('dim',Token), % dim1, dim2, ...
          i=str2num(Token(4:end));
          if isempty(i) | length(i)>1 | i>Structure.NDim,
            fprintf(1,['Unexpected dimension in line:\n' Line '\n']);
            fclose(fid);
            return;
          else,
            Structure.Size(i)=str2num(Value);
          end;
        else,
          T=tokens(Line);
          switch lower(T{1}),
          case 'coord',
            Nr=str2num(T{2});
            S=Interpret_fileline(Line,T(3:end));
            if ~isempty(S),
              Structure.Time(t).Coord(Nr)=S;
            else, % Interpret_fileline could not interpret line
              fclose(fid);
              return;
            end;
            if Nr>Structure.NSpace,
              fprintf(1,['Unexpected space coordinated in line:\n' Line '\n']);
              fclose(fid);
              return;
            end;
          case 'variable',
            Nr=str2num(T{2});
            S=Interpret_fileline(Line,T(3:end));
            if ~isempty(S),
              Structure.Time(t).Variable(Nr)=S;
            else, % Interpret_fileline could not interpret line
              fclose(fid);
              return;
            end;
            if Nr>Structure.VecLen,
              fprintf(1,['Unexpected variable number in line:\n' Line '\n']);
              fclose(fid);
              return;
            end;
          case 'time',
            if ~isempty(strmatch('value',T{2})), % value=TimeString
              S=deblank2(Line((min(findstr(Line,'='))+1):end));
            else,
              S=Interpret_fileline(Line,T(2:end));
            end;
            if ~isempty(S),
              Structure.Time(t).Value=S;
            else, % Interpret_fileline could not interpret line
              fclose(fid);
              return;
            end;
          otherwise,
            fprintf(1,['Unexpected line:\n' Line '\n']);
            fclose(fid);
            return;
          end;
        end;
      end;
    else,
      switch(Line),
      case 'EOT',
        t=t+1;
      case {'DO','ENDDO'},
      otherwise,
        if ~isempty(deblank(Line)),
          fprintf(1,['Unexpected line:\n' Line '\n']);
        end;
      end;
    end;
  end;
  Loc=ftell(fid);
  Line=fgetl(fid);
end;
%check Coord records, Variable records, Labels (default 'Channel i'), Units,
% Min/MaxExt, Min/MaxVal
fclose(fid);
Structure.Check='OK';


function S=Interpret_fileline(Line,T),
i=1;
% can be e.g. file=filename, file= filename, file =filename, file = filename
% on Win95 system filename can contain spaces!? This possibilility is ignored.
if strmatch('file',lower(T{i})), % filename
  if isempty(findstr(T{i},'=')), % no =
    i=i+1;
  end;
  AfterEq=deblank(T{i}((min(findstr(T{i},'='))+1):end));
  if isempty(AfterEq), % no filename
    i=i+1;
    AfterEq=T{i};
  end;
  S.FileName=AfterEq;
else, % no filename?
  fprintf(1,['FileName not found in line:\n' Line '\n']);
  S=[];
  return;
end;
i=i+1;
if strmatch('filetype',lower(T{i})), % filetype
  if isempty(findstr(T{i},'=')), % no =
    i=i+1;
  end;
  AfterEq=deblank(T{i}((min(findstr(T{i},'='))+1):end));
  if isempty(AfterEq), % no filename
    i=i+1;
    AfterEq=T{i};
  end;
  S.FileType=AfterEq; % ascii, binary, unformatted
  FileTypes={'ascii','binary','unformatted'};
  if isempty(strmatch(S.FileType,FileTypes,'exact')),
    fprintf(1,['Unknown file type in line:\n' Line '\n']);
  end;
else, % no filetype?
  fprintf(1,['FileType not found in line:\n' Line '\n']);
  S=[];
  return;
end;
i=i+1;
if strmatch('skip',lower(T{i})), % skip
  if isempty(findstr(T{i},'=')), % no =
    i=i+1;
  end;
  AfterEq=deblank(T{i}((min(findstr(T{i},'='))+1):end));
  if isempty(AfterEq), % no filename
    i=i+1;
    AfterEq=T{i};
  end;
  S.Skip=str2num(AfterEq);
  if ~isequal(size(S.Skip),[1 1]) | any(isnan(S.Skip)),
    fprintf(1,['Invalid value for skip:\n' Line '\n']);
    S=[];
    return;
  end;
else, % no skip?
  S.Skip=0;
end;
i=i+1;
if strmatch('offset',lower(T{i})), % offset
  if isempty(findstr(T{i},'=')), % no =
    i=i+1;
  end;
  AfterEq=deblank(T{i}((min(findstr(T{i},'='))+1):end));
  if isempty(AfterEq), % no filename
    i=i+1;
    AfterEq=T{i};
  end;
  S.Offset=str2num(AfterEq);
  if ~isequal(size(S.Offset),[1 1]) | any(isnan(S.Offset)),
    fprintf(1,['Invalid value for offset:\n' Line '\n']);
    S=[];
    return;
  end;
else, % no offset?
  S.Offset=0;
end;
i=i+1;
if strmatch('stride',lower(T{i})), % stride
  if isempty(findstr(T{i},'=')), % no =
    i=i+1;
  end;
  AfterEq=deblank(T{i}((min(findstr(T{i},'='))+1):end));
  if isempty(AfterEq), % no filename
    i=i+1;
    AfterEq=T{i};
  end;
  S.Stride=str2num(AfterEq);
  if ~isequal(size(S.Stride),[1 1]) | any(isnan(S.Stride)),
    fprintf(1,['Invalid value for stride:\n' Line '\n']);
    S=[];
    return;
  end;
else, % no stride?
  S.Stride=1;
end;
i=i+1;
% close option ignored

function Structure=Local_interpret_inp_file(filename),
Structure.Check='NotOK';

if nargin<1,
  [fn,fp]=uigetfile('*.inp');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;

fid=fopen(filename,'r');
Structure.FileName=filename;

M=fread(fid,1,'char');
if feof(fid),
elseif M==5, % binary 3.0
  Structure.Type='BINARY 3.0';
  Structure=Local_interpret_inp_bin30_file(fid,Structure);
elseif M==7, % binary 3.5
  Structure.Type='BINARY 3.5';
  Structure=Local_interpret_inp_bin35_file(fid,Structure);
else, % ascii
  Structure.Type='ASCII';
  fseek(fid,0,-1);
  Structure=Local_interpret_inp_ascii_file(fid,Structure);
end;
fclose(fid);


function Data=Local_read_inp_file(S,i,Loc,Field),
Data=[];
fid=fopen(S.FileName,'r');
switch S.Type,
case 'ASCII',
  switch Loc,
  case 'GEOM',
    if S.Step(i).NumNodes==0, % cycletype=data
      i=1;
    end;
    fseek(fid,S.Step(i).GeomStart,-1);
    Data=Local_read_geom(fid,S.Step(i).NumNodes,S.Step(i).NumCells);
  case 'NODE',
    if S.Step(i).NumNodeData==0, % cycletype=geom
      i=1;
    end;
    if S.Step(i).NumNodes==0, % cycletype=data
      j=1;
    else,
      j=i;
    end;
    if S.Step(i).NumNodeData==0,
      error('No node data found.');
    else,
      fseek(fid,S.Step(i).NodeDataStart,-1);
      DataNr=strmatch(Field,{S.Step(i).NodeData.Label},'exact');
      if ~isequal(size(DataNr),[1 1]),
        error('Specified variable name not found or not unique.');
      end;
      X=Local_read_data(fid,S.Step(j).NumNodes,S.Step(i).NumNodeData);
      DataIndices=sum(S.Step(i).NodeData(1:(DataNr-1)).Dim)+1:S.Step(i).NodeData(DataNr).Dim;
      Data=transpose(X(DataIndices,:));
    end;
  case 'CELL',
    if S.Step(i).NumCellData==0, % cycletype=geom
      i=1;
    end;
    if S.Step(i).NumCells==0, % cycletype=data
      j=1;
    else,
      j=i;
    end;
    if S.Step(i).NumCellData==0,
      error('No cell data found.');
    else,
      fseek(fid,S.Step(i).CellDataStart,-1);
      DataNr=strmatch(Field,{S.Step(i).CellData.Label},'exact');
      if ~isequal(size(DataNr),[1 1]),
        error('Specified variable name not found or not unique.');
      end;
      X=Local_read_data(fid,S.Step(j).NumCells,S.Step(i).NumCellData);
      DataIndices=sum(S.Step(i).CellData(1:(DataNr-1)).Dim)+1:S.Step(i).CellData(DataNr).Dim;
      Data=transpose(X(DataIndices,:));
    end;
  case 'MODEL',
    if S.Step(i).NumModelData==0, % cycletype=geom
      i=1;
    end;
    if S.Step(i).NumModelData==0,
      error('No model data found.');
    else,
      fseek(fid,S.Step(i).ModelDataStart,-1);
      DataNr=strmatch(Field,{S.Step(i).ModelData.Label},'exact');
      if ~isequal(size(DataNr),[1 1]),
        error('Specified variable name not found or not unique.');
      end;
      X=Local_read_data(fid,1,S.Step(i).NumModelData);
      DataIndices=sum(S.Step(i).ModelData(1:(DataNr-1)).Dim)+1:S.Step(i).ModelData(DataNr).Dim;
      Data=transpose(X(DataIndices,:));
    end;
  otherwise,
    error('Invalid fourth argument. It should be GEOM, NODE, CELL, or MODEL.');
  end;
case 'BINARY 3.0',
case 'BINARY 3.5',
otherwise,
  fclose(fid);
  error('Unknown INP-file type');
end;
fclose(fid);


function S=Local_interpret_inp_bin30_file(fid,Sin),
S=Sin;
%fread ((char *)&magic, sizeof(char), 1, fp);
%	
%fread ((char *)model->node_data_labels, sizeof(char), 100, fp);
%fread ((char *)model->cell_data_labels, sizeof(char), 100, fp);
%fread ((char *)model->model_data_labels, sizeof(char), 100, fp);
%fread ((char *)model->node_data_units, sizeof(char), 100, fp);
%fread ((char *)model->cell_data_units, sizeof(char), 100, fp);
%fread ((char *)model->model_data_units, sizeof(char), 100, fp);
%
%fread ((char *)(&model->num_nodes), sizeof(int), 1, fp);
%fread ((char *)(&model->num_cells), sizeof(int), 1, fp);
%fread ((char *)(&model->num_node_data), sizeof(int), 1, fp);
%fread ((char *)(&model->num_cell_data), sizeof(int), 1, fp);
%fread ((char *)(&model->num_model_data), sizeof(int), 1, fp);
%	
%fread ((char *)model->node_active_list, sizeof(int), 20, fp);
%fread ((char *)model->cell_active_list, sizeof(int), 20, fp);
%fread ((char *)model->model_active_list, sizeof(int), 20, fp);
%
%fread ((char *)(&model->num_node_comp), sizeof(int), 1, fp);
%fread ((char *)model->node_comp_list, sizeof(int), 20, fp);
%fread ((char *)(&model->num_cell_comp), sizeof(int), 1, fp);
%fread ((char *)model->cell_comp_list, sizeof(int), 20, fp);
%fread ((char *)(&model->num_model_comp), sizeof(int), 1, fp);
%fread ((char *)model->model_comp_list, sizeof(int), 20, fp);
%fread ((char *)(&model->num_nlist_nodes), sizeof(int), 1, fp);
%
%fread  ((char *)cells, sizeof(Ctype), num_cells, fp);
% where Ctype = 
%
%fread  ((char *)cell_nlists, sizeof(int), num_nlist_nodes, fp);
%
%fread ((char *)xc, sizeof(float), num_nodes, fp);
%fread ((char *)xc, sizeof(float), num_nodes, fp);
%fread ((char *)xc, sizeof(float), num_nodes, fp);
%
%if (num_node_data)
%  fread ((char *)min_node_data, sizeof(float), num_node_data, fp);
%  fread ((char *)max_node_data, sizeof(float), num_node_data, fp);
%  fread ((char *)node_data, sizeof(float),num_node_data * num_nodes, fp);
%end;
%
%if (num_cell_data)
%  fread ((char *)min_cell_data, sizeof(float), num_cell_data, fp);
%  fread ((char *)max_cell_data, sizeof(float), num_cell_data, fp);
%  fread ((char *)cell_data, sizeof(float),num_cell_data * num_cells, fp);
%end;
%
%if (num_model_data)
%  fread ((char *)min_model_data, sizeof(float), num_model_data,fp);
%  fread ((char *)max_model_data, sizeof(float), num_model_data,fp);
%  fread ((char *)model_data, sizeof(float), num_model_data, fp);
%end;
%
%S.Check='OK';


function S=Local_interpret_inp_bin35_file(fid,Sin),
S=Sin;
S.NumNodes=fread(fid,1,'int32');
S.NumCells=fread(fid,1,'int32');
S.NumNodeData=fread(fid,1,'int32');
S.NumCellData=fread(fid,1,'int32');
S.NumModelData=fread(fid,1,'int32');
S.NumListNodes=fread(fid,1,'int32');

S.PCell=fread(fid,[4 S.NumCells],'int32'); % id mat n cell-type
S.CellNLists=fread(fid,S.NumListNodes,'int32');

S.Coordinates=fread(fid,[S.NumNodes 3],'float32');

Label_len=1024;
if S.NumNodeData>0,
  S.Node.Labels=fread(fid,Label_len,'char');
  S.Node.Units=fread(fid,Label_len,'char');
  S.Node.NumComp=fread(fid,1,'int32');
  S.Node.CompList=fread(fid,S.NumNodeData,'int32');
  S.Node.MinData=fread(fid,S.NumNodeData,'float32');
  S.Node.MaxData=fread(fid,S.NumNodeData,'float32');
  S.Node.Data=fread(fid,S.NumNodeData*S.NumNodes,'float32');
  S.Node.ActiveData=fread(fid,S.NumNodeData,'int32');
end;

if S.NumCellData>0,
  S.Cell.Labels=fread(fid,Label_len,'char');
  S.Cell.Units=fread(fid,Label_len,'char');
  S.Cell.NumComp=fread(fid,1,'int32');
  S.Cell.CompList=fread(fid,S.NumCellData,'int32');
  S.Cell.MinData=fread(fid,S.NumCellData,'float32');
  S.Cell.MaxData=fread(fid,S.NumCellData,'float32');
  S.Cell.Data=fread(fid,S.NumCellData*S.NumCells,'float32');
  S.Cell.ActiveData=fread(fid,S.NumCellData,'int32');
end;

if S.NumModelData>0,
  S.Model.Labels=fread(fid,Label_len,'char');
  S.Model.Units=fread(fid,Label_len,'char');
  S.Model.NumComp=fread(fid,1,'int32');
  S.Model.CompList=fread(fid,S.NumModelData,'int32');
  S.Model.MinData=fread(fid,S.NumModelData,'float32');
  S.Model.MaxData=fread(fid,S.NumModelData,'float32');
  S.Model.Data=fread(fid,S.NumModelData,'float32');
  S.Model.ActiveData=fread(fid,S.NumModelData,'int32');
end;

S.Check='OK';


function S=Local_interpret_inp_ascii_file(fid,Sin),
S=Sin;

Line=fgetl(fid);

% skip comments

while strcmp(Line(1),'#'),
  Line=fgetl(fid);
end;

% read model properties

X=sscanf(Line,'%i');
switch length(X),
case 5, % single step (old)
  S.Step(1).NumNodes=X(1);
  S.Step(1).NumCells=X(2);

  S.Step(1).NumNodeData=X(3);
  S.Step(1).NumCellData=X(4);
  S.Step(1).NumModelData=X(5);

  % skip geom

  S.Step(1).GeomStart=ftell(fid);
  Local_skip_geom(fid,S.Step(1).NumNodes,S.Step(1).NumCells);

  % skip data
  if S.Step(1).NumNodeData>0,
    [S.Step(1).NodeData,S.Step(1).NodeDataStart]=Local_skip_data(fid,S.Step(1).NumNodes);
  else,
    S.Step(1).NodeData=[];
    S.Step(1).NodeDataStart=0;
  end;
  if S.Step(1).NumCellData>0,
    [S.Step(1).CellData,S.Step(1).CellDataStart]=Local_skip_data(fid,S.Step(1).NumCells);
  else,
    S.Step(1).CellData=[];
    S.Step(1).CellDataStart=0;
  end;
  if S.Step(1).NumModelData>0,
    [S.Step(1).ModelData,S.Step(1).ModelDataStart]=Local_skip_data(fid,1);
  else,
    S.Step(1).ModelData=[];
    S.Step(1).ModelDataStart=0;
  end;
    
case 1, % multi step (new)
  NumSteps=X;
  CycleType=lower(deblank(fgetl(fid))); % cycle_type: data, geom, data_geom
  for i=1:NumSteps,

    % read step header

    X=fscanf(fid,'%s',1); % step%i
    if ~strcmp(X,sprintf(['step%i'],i)),
      fprintf(1,'Expected to find step%i.',i);
      break;
    end;
    Line=fgetl(fid); % read remainder of line containing step name
    S.Step(i).Name=sscanf(Line,'%s',1);

    if i==1,

      % skip geom

      Line=fgetl(fid);
      X=sscanf(Line,'%i',2);
      S.Step(i).NumNodes=X(1);
      S.Step(i).NumCells=X(2);
      S.Step(i).GeomStart=ftell(fid);
      Local_skip_geom(fid,S.Step(i).NumNodes,S.Step(i).NumCells);

      % skip data

      Line=fgetl(fid);
      X=sscanf(Line,'%i',2);
      S.Step(i).NumNodeData=X(1);
      S.Step(i).NumCellData=X(2);
      if S.Step(i).NumNodeData>0,
        [S.Step(i).NodeData,S.Step(i).NodeDataStart]=Local_skip_data(fid,S.Step(i).NumNodes);
      else,
        S.Step(i).NodeData=[];
        S.Step(i).NodeDataStart=0;
      end;
      if S.Step(i).NumCellData>0,
        [S.Step(i).CellData,S.Step(i).CellDataStart]=Local_skip_data(fid,S.Step(i).NumCells);
      else,
        S.Step(i).CellData=[];
        S.Step(i).CellDataStart=0;
      end;
    else,
      switch CycleType,
      case 'data',
  
        % skip data
  
        Line=fgetl(fid);
        X=sscanf(Line,'%i',2);
        S.Step(i).NumNodeData=X(1);
        S.Step(i).NumCellData=X(2);
        if S.Step(i).NumNodeData>0,
          [S.Step(i).NodeData,S.Step(i).NodeDataStart]=Local_skip_data(fid,S.Step(i).NumNodes);
        else,
          S.Step(i).NodeData=[];
          S.Step(i).NodeDataStart=0;
        end;
        if S.Step(i).NumCellData>0,
          [S.Step(i).CellData,S.Step(i).CellDataStart]=Local_skip_data(fid,S.Step(i).NumCells);
        else,
          S.Step(i).CellData=[];
          S.Step(i).CellDataStart=0;
        end;
  
      case 'geom',
  
        % skip geom
  
        Line=fgetl(fid);
        X=sscanf(Line,'%i',2);
        S.Step(i).NumNodes=X(1);
        S.Step(i).NumCells=X(2);
        S.Step(i).GeomStart=ftell(fid);
        Local_skip_geom(fid,S.Step(i).NumNodes,S.Step(i).NumCells);
  
      case 'data_geom',
  
        % skip geom
  
        Line=fgetl(fid);
        X=sscanf(Line,'%i',2);
        S.Step(i).NumNodes=X(1);
        S.Step(i).NumCells=X(2);
        S.Step(i).GeomStart=ftell(fid);
        Local_skip_geom(fid,S.Step(i).NumNodes,S.Step(i).NumCells);
  
        % skip data
  
        Line=fgetl(fid);
        X=sscanf(Line,'%i',2);
        S.Step(i).NumNodeData=X(1);
        S.Step(i).NumCellData=X(2);
        if S.Step(i).NumNodeData>0,
          [S.Step(i).NodeData,S.Step(i).NodeDataStart]=Local_skip_data(fid,S.Step(i).NumNodes);
        else,
          S.Step(i).NodeData=[];
          S.Step(i).NodeDataStart=0;
        end;
        if S.Step(i).NumCellData>0,
          [S.Step(i).CellData,S.Step(i).CellDataStart]=Local_skip_data(fid,S.Step(i).NumCells);
        else,
          S.Step(i).CellData=[];
          S.Step(i).CellDataStart=0;
        end;

      otherwise,
        Str=['Unknown cycle type: ',CycleType,'.'];
        error(Str);
      end;

      S.Step(i).ModelData=[];
      S.Step(i).ModelDataStart=0;
    end;
    
  end;
end;

S.Check='OK';


function Fld=Local_read_geom(fid,NumNodes,NumCells),

X=fscanf(fid,'%f',[4 NumNodes]); % id x y z
[Y,I]=sort(X(1,:));
Fld.Coords=transpose(X(2:4,I));
Line=fgetl(fid); % read EOL

for c=1:NumCells,
  Line=fgetl(fid);
  TypeStr=find((abs(Line)<48 | abs(Line)>57) & abs(Line)~=32);
  Fld.Cell(c).id=sscanf(Line(1:(TypeStr(1)-1)),'%i',2); % id mat
  Fld.Cell(c).TypeStr=Line(TypeStr); % 'pt','line','tri','quad','tet','pyr','prism','hex'
  Fld.Cell(c).Corners=sscanf(Line((TypeStr(end)+1):end),'%i'); % corner node ids
end;


function Local_skip_geom(fid,NumNodes,NumCells),

for i=1:NumNodes+NumCells, % skip Node and Cell geometry
  Line=fgetl(fid);
end;


function Data=Local_read_data(fid,NumLocs,NumVars),

X=fscanf(fid,'%f',[NumVars+1 NumLocs]);
Data=X(2:end,:);
%MinData=min(Data,[],2);
%MaxData=max(Data,[],2);


function [Fld,Offset]=Local_skip_data(fid,NumLocs),
NumComp=fscanf(fid,'%i',1);
CompList=fscanf(fid,'%i',NumComp);
Line=fgetl(fid); % read EOL

for i=1:NumComp, % read labels and 
  Line=fgetl(fid);
  sep=findstr(Line,',');
  Fld(i).Label=deblank(Line(1:(sep(1)-1)));
  Fld(i).Unit=deblank(Line((sep(1)+1):end));
  Fld(i).Dim=CompList(i);
end;

Offset=ftell(fid);
for i=1:NumLocs,
  Line=fgetl(fid);
end;


function Structure=Local_write_inp_file,


function Structure=Local_convert_dmp2inp(CFXdmp,AVSinp),
Structure.Check='NotOK';

if nargin<1,
  [fn,fp]=uigetfile('*.dmp');
  if ~ischar(fn),
    return;
  end;
  CFXdmp=[fp fn];
end;

if ischar(CFXdmp),
  CFXdmp=cfx('opendmp',CFXdmp);
  if isempty(CFXdmp),
    error('Unable to open CFX dmp file.');
    return;
  end;
end;

if nargin<2,
  [fn,fp]=uigetfile('*.inp');
  if ~ischar(fn),
    return;
  end;
  AVSinp=[fp fn];
end;

fid=fopen(AVSinp,'w','ieee-be');

%WriteTimes=1:length(CFXdmp.Time);
WriteTimes=input(sprintf('%i time steps in the file\nTime steps to be saved: ',length(CFXdmp.Time)));
if isempty(WriteTimes),
  fclose(fid);
  return;
end;
if CFXdmp.NumPhases>1,
  phase=input(sprintf('%i phases in the file\nSave phase: ',CFXdmp.NumPhases));
  if isempty(phase),
    fclose(fid);
    return;
  elseif ~isequal(size(phase),[1 1]),
    phase=phase(1);
  end;
else,
  phase=1;
end;
% write number of time steps
% length(WriteTimes)
fprintf(fid,'%d\n',length(WriteTimes));

% write label 'data_geom'
% 'data_geom'
MovingGrid=length(CFXdmp.XEntry)>1;
if MovingGrid,
  fprintf(fid,'data_geom\n');
else,
  fprintf(fid,'data\n');
end;

% save geometry
SaveGeom=1;
FirstTime=1;

fprintf(1,'Writing step ...\n');

% for every time step in the DMP file
for it=1:length(WriteTimes),
  t=WriteTimes(it);

  fprintf(1,' %i',t);

  % write 'step%i' and timestepname
  % ['step' sprintf('%i',t)]   num2str(CFXdmp.Time(t))
  fprintf(fid,'%s %s\n',['step' sprintf('%i',it)],num2str(CFXdmp.Time(t)));

  if SaveGeom,

    fprintf(1,' geom');

    % read geometry

    switch CFXdmp.Options.Coordinates,
    case 'Cartesian',
      X=cfx('readdmp',CFXdmp,'X COORDINATES',1,t);
      Y=cfx('readdmp',CFXdmp,'Y COORDINATES',1,t);
      Z=cfx('readdmp',CFXdmp,'Z COORDINATES',1,t);
    case 'Cylindrical',
      X=cfx('readdmp',CFXdmp,'X COORDINATES',1,t);
      Radius=cfx('readdmp',CFXdmp,'Y COORDINATES',1,t);
      Theta=cfx('readdmp',CFXdmp,'Z COORDINATES',1,t);
      for b=1:length(X),
        Y{b}=Radius{b}.*cos(Theta{b});
        Z{b}=Radius{b}.*sin(Theta{b});
      end;
    end;
    
    % for every block remove the outer cells
    
    NActPnt=0;
    NActCell=0;
    for b=1:length(X),
    
      PntOffset{b}=NActPnt;
      CellOffset{b}=NActCell;
    
      X{b}=X{b}(2:end-1,2:end-1,2:end-1);
      Y{b}=Y{b}(2:end-1,2:end-1,2:end-1);
      Z{b}=Z{b}(2:end-1,2:end-1,2:end-1);
      I{b}=reshape(1:prod(size(X{b})),size(X{b}));
      I{b}=I{b}(1:end-1,1:end-1,1:end-1);
      I{b}=transpose(I{b}(:)+PntOffset{b});
      Sz{b}=size(X{b});
    
      NActPnt=NActPnt+prod(size(X{b}));
      NActCell=NActCell+prod(size(X{b})-1);
    
      X{b}=transpose(X{b}(:));
      Y{b}=transpose(Y{b}(:));
      Z{b}=transpose(Z{b}(:));
    end;
    
    % write NumberOfActivePoints and NumberOfActiveCells
    % NActPnt NActCell
    fprintf(fid,'%i %i\n',NActPnt,NActCell);
  
    % for every block
    for b=1:length(X),
      % for every active point in the block
      % for p=1:prod(size(X{b})),
        % write %i x y z
        % [PntOffset{b}+(1:prod(size(X{b}))); X{b}; Y{b}; Z{b}]
        fprintf(fid,'%i %f %f %f\n',[PntOffset{b}+(1:prod(size(X{b}))); X{b}; Y{b}; Z{b}]);
      % end;
    end;
  
    % for every block
    for b=1:length(X),
      % for every active cell
      % for c=1:prod(size(X{b})-1),
        % write %i group%i type corners
        % [CellOff{b}+(1:prod(size(X{b})-1)); ones(1,prod(size(X{b})-1); 'HEX'; I{b}; I{b}+1; I{b}+Sz{b}(1); I{b}+Sz{b}(1)+1; I{b}+prod(Sz{b}(1:2)); ]
        fprintf(fid,'%i %i %c%c%c %i %i %i %i %i %i %i %i\n', ...
           [CellOffset{b}+(1:length(I{b})); ...
            ones(1,length(I{b})); ...
            transpose('hex')*ones(1,length(I{b})); ...
            I{b}; ...
            I{b}+1; ...
            I{b}+Sz{b}(1)+1; ...
            I{b}+Sz{b}(1); ...
            I{b}+prod(Sz{b}(1:2)); ...
            I{b}+prod(Sz{b}(1:2))+1; ...
            I{b}+prod(Sz{b}(1:2))+Sz{b}(1)+1; ...
            I{b}+prod(Sz{b}(1:2))+Sz{b}(1)]);
      % end;
    end;
    if ~MovingGrid,
      SaveGeom=0;
    end;
  end;

  if FirstTime,

    fprintf(1,' ijk');

    % write NumberOfVariablesPerPoint and NumberOfVariablesPerCell
    % 3 CFXdmp.NumVars
    fprintf(fid,'%i %i\n',3,CFXdmp.NumVars);

    % write NumberOfVariableGroupsPerPoint and for every group its number of variables
    % 3 1 1 1
    fprintf(fid,' %i',[3 1 1 1]);
    fprintf(fid,'\n');

    % for every variable group
    fprintf(fid,'I coordinate , [-]\n');
    fprintf(fid,'J coordinate , [-]\n');
    fprintf(fid,'K coordinate , [-]\n');

    % create and write vars
    ITOT=0;
    JTOT=0;
    KTOT=0;
    % for every block
    for b=1:length(X),
      % for every active cell
      % write %i and all the variables at the vertices
      TEMP=zeros(4,prod(size(X{b})));
      TEMP(1,:)=PntOffset{b}+(1:prod(size(X{b})));
      [IJK{1}{b} IJK{2}{b} IJK{3}{b}]=ndgrid(ITOT+(1:Sz{b}(1)), ...
                                             JTOT+(1:Sz{b}(2)), ...
                                             KTOT+(1:Sz{b}(3)));
      ITOT=ITOT+Sz{b}(1);
      JTOT=JTOT+Sz{b}(2);
      KTOT=KTOT+Sz{b}(3);
      TEMP(2,:)=transpose(IJK{1}{b}(:));
      TEMP(3,:)=transpose(IJK{2}{b}(:));
      TEMP(4,:)=transpose(IJK{3}{b}(:));
      fprintf(fid,'%i %i %i %i\n',TEMP);
    end;

    FirstTime=0;
  else,
    % write NumberOfVariablesPerPoint and NumberOfVariablesPerCell
    % 0 CFXdmp.NumVars
    fprintf(fid,'%i %i\n',0,CFXdmp.NumVars);
  end;

  fprintf(1,' data');

  % write NumberOfVariableGroupsPerCell and for every group its number of variables
  % CFXdmp.NumVars ones(1,CFXdmp.NumVars)
  fprintf(fid,' %i',[CFXdmp.NumVars ones(1,CFXdmp.NumVars)]);
  fprintf(fid,'\n');

  % for every variable group
  for vg=1:CFXdmp.NumVars,
    % write group name and group unit
    % CFXdmp.Variable(vg).Name ', [unknown]' 
    fprintf(fid,'%s , [unknown]\n',CFXdmp.Variable(vg).Name);
  end;

  % read vars
  for vg=1:CFXdmp.NumVars,
    Var{vg}=cfx('readdmp',CFXdmp,vg,phase,t);
  end;

  fprintf(1,' block');

  % for every block
  for b=1:length(X),
    fprintf(1,' %i',b);

    % write %i and all the variables corners
    % [CellsetOff{b}+(1:prod(size(X{b})-1)); Var{:}{b}(:)]
    TEMP=zeros(1+CFXdmp.NumVars,length(I{b}));
    TEMP(1,:)=CellOffset{b}+(1:length(I{b}));
    for vg=1:CFXdmp.NumVars,
      TEMP2=Var{vg}{b}(2:end-1,2:end-1,2:end-1);
      TEMP(1+vg,:)=transpose(TEMP2(:));
    end;
    fprintf(fid,['%i',repmat(' %f',[1 CFXdmp.NumVars]),'\n'],TEMP);
  end;

  fprintf(1,'\n');

end;

fprintf(1,'\n');

% finished writing and close
fclose(fid);
Structure.Check='OK';


function Structure=Local_convert_dmp2inp_patch(CFXdmp,AVSinp),
Structure.Check='NotOK';

if nargin<1,
  [fn,fp]=uigetfile('*.dmp');
  if ~ischar(fn),
    return;
  end;
  CFXdmp=[fp fn];
end;

if ischar(CFXdmp),
  CFXdmp=cfx('opendmp',CFXdmp);
  if isempty(CFXdmp),
    error('Unable to open CFX dmp file.');
    return;
  end;
end;

if nargin<2,
  [fn,fp]=uigetfile('*.inp');
  if ~ischar(fn),
    return;
  end;
  AVSinp=[fp fn];
end;

fid=fopen(AVSinp,'w','ieee-be');

%WriteTimes=1:length(CFXdmp.Time);
WriteTimes=input(sprintf('%i time steps in the file\nTime steps to be saved: ',length(CFXdmp.Time)));
if isempty(WriteTimes),
  fclose(fid);
  return;
end;
if CFXdmp.NumPhases>1,
  phase=input(sprintf('%i phases in the file\nSave phase: ',CFXdmp.NumPhases));
  if isempty(phase),
    fclose(fid);
    return;
  elseif ~isequal(size(phase),[1 1]),
    phase=phase(1);
  end;
else,
  phase=1;
end;
% write number of time steps
% length(WriteTimes)
fprintf(fid,'%d\n',length(WriteTimes));
% which patches?
WritePatches=1:CFXdmp.NumPatches;
% don't include glue patches
WritePatches(strmatch('BLKBDY',{CFXdmp.Patch(WritePatches).Type},'exact'))=[];

% write label 'data_geom'
% 'data_geom'
MovingGrid=length(CFXdmp.XEntry)>1;
if MovingGrid,
  fprintf(fid,'data_geom\n');
else,
  fprintf(fid,'data\n');
end;

% save geometry
SaveGeom=1;
FirstTime=1;

fprintf(1,'Writing step ...\n');

% for every time step in the DMP file
for it=1:length(WriteTimes),
  t=WriteTimes(it);

  fprintf(1,' %i',t);

  % write 'step%i' and timestepname
  % ['step' sprintf('%i',t)]   num2str(CFXdmp.Time(t))
  fprintf(fid,'%s %s\n',['step' sprintf('%i',it)],num2str(CFXdmp.Time(t)));

  if SaveGeom,

    fprintf(1,' geom');

    % read geometry

    switch CFXdmp.Options.Coordinates,
    case 'Cartesian',
      X=cfx('readdmp',CFXdmp,'X COORDINATES','PATCH',WritePatches,1,t);
      Y=cfx('readdmp',CFXdmp,'Y COORDINATES','PATCH',WritePatches,1,t);
      Z=cfx('readdmp',CFXdmp,'Z COORDINATES','PATCH',WritePatches,1,t);
    case 'Cylindrical',
      X=cfx('readdmp',CFXdmp,'X COORDINATES','PATCH',WritePatches,1,t);
      Radius=cfx('readdmp',CFXdmp,'Y COORDINATES','PATCH',WritePatches,1,t);
      Theta=cfx('readdmp',CFXdmp,'Z COORDINATES','PATCH',WritePatches,1,t);
      for b=1:length(X),
        Y{b}=Radius{b}.*cos(Theta{b});
        Z{b}=Radius{b}.*sin(Theta{b});
      end;
    end;
    
    % for every patch remove the outer cells
    
    NActPnt=0;
    NActCell=0;
    for b=1:length(X),
    
      PntOffset{b}=NActPnt;
      CellOffset{b}=NActCell;
    
%      X{b}=X{b}(2:end-1,2:end-1);
%      Y{b}=Y{b}(2:end-1,2:end-1);
%      Z{b}=Z{b}(2:end-1,2:end-1);
      I{b}=reshape(1:prod(size(X{b})),size(X{b}));
      I{b}=I{b}(1:end-1,1:end-1);
      I{b}=transpose(I{b}(:)+PntOffset{b});
      Sz{b}=size(X{b});
    
      NActPnt=NActPnt+prod(size(X{b}));
      NActCell=NActCell+prod(size(X{b})-1);
    
      X{b}=transpose(X{b}(:));
      Y{b}=transpose(Y{b}(:));
      Z{b}=transpose(Z{b}(:));
    end;
    
    % write NumberOfActivePoints and NumberOfActiveCells
    % NActPnt NActCell
    fprintf(fid,'%i %i\n',NActPnt,NActCell);
  
    % for every patch
    for b=1:length(X),
      % for every active point in the patch
      % for p=1:prod(size(X{b})),
        % write %i x y z
        % [PntOffset{b}+(1:prod(size(X{b}))); X{b}; Y{b}; Z{b}]
        fprintf(fid,'%i %f %f %f\n',[PntOffset{b}+(1:prod(size(X{b}))); X{b}; Y{b}; Z{b}]);
      % end;
    end;
  
    % for every block
    for b=1:length(X),
      % for every active cell
      % for c=1:prod(size(X{b})-1),
        % write %i group%i type corners
        % [CellOff{b}+(1:prod(size(X{b})-1)); ones(1,prod(size(X{b})-1); 'HEX'; I{b}; I{b}+1; I{b}+Sz{b}(1); I{b}+Sz{b}(1)+1; I{b}+prod(Sz{b}(1:2)); ]
        fprintf(fid,'%i %i %c%c%c%c %i %i %i %i\n', ...
           [CellOffset{b}+(1:length(I{b})); ...
            ones(1,length(I{b})); ...
            transpose('quad')*ones(1,length(I{b})); ...
            I{b}; ...
            I{b}+1; ...
            I{b}+Sz{b}(1)+1; ...
            I{b}+Sz{b}(1)]);
      % end;
    end;
    if ~MovingGrid,
      SaveGeom=0;
    end;
  end;

  if FirstTime,

    fprintf(1,' ijk');

    % patch name
    PatchNames=unique({CFXdmp.Patch(WritePatches).Name});

    % write NumberOfVariablesPerPoint and NumberOfVariablesPerCell
    % 3+length(PatchNames) CFXdmp.NumVars
    fprintf(fid,'%i %i\n',3+length(PatchNames),CFXdmp.NumVars);

    % write NumberOfVariableGroupsPerPoint and for every group its number of variables
    % 3+length(PatchNames) 1 1 1 1 1 ...
    fprintf(fid,' %i',[3+length(PatchNames) ones(1,3+length(PatchNames))]);
    fprintf(fid,'\n');

    % for every variable group
    fprintf(fid,'I coordinate , [-]\n');
    fprintf(fid,'J coordinate , [-]\n');
    fprintf(fid,'K coordinate , [-]\n');
    for i=1:length(PatchNames),
      fprintf(fid,[PatchNames{i} ' , [-]\n']);
    end;

    % create and write vars
    ITOT=0;
    JTOT=0;
    KTOT=0;
    % for every patch
    FormatString=['%i',repmat(' %i',[1 3+length(PatchNames)]),'\n'];
    for b=1:length(X),
      % for every active cell
      % write %i and all the variables at the vertices
      TEMP=zeros(4+length(PatchNames),prod(size(X{b})));
      TEMP(1,:)=PntOffset{b}+(1:prod(size(X{b})));
%      [IJK{1}{b} IJK{2}{b} IJK{3}{b}]=ndgrid(ITOT+(1:Sz{b}(1)), ...
%                                             JTOT+(1:Sz{b}(2)), ...
%                                             KTOT+(1:Sz{b}(3)));
%      ITOT=ITOT+Sz{b}(1);
%      JTOT=JTOT+Sz{b}(2);
%      KTOT=KTOT+Sz{b}(3);
%      TEMP(2,:)=transpose(IJK{1}{b}(:));
%      TEMP(3,:)=transpose(IJK{2}{b}(:));
%      TEMP(4,:)=transpose(IJK{3}{b}(:));
      for i=1:length(PatchNames),
        if strcmp(PatchNames{i},CFXdmp.Patch(b).Name),
          TEMP(4+i,:)=1;
        end;
      end;
      fprintf(fid,FormatString,TEMP);
    end;

    FirstTime=0;
  else,
    % write NumberOfVariablesPerPoint and NumberOfVariablesPerCell
    % 0 CFXdmp.NumVars
    fprintf(fid,'%i %i\n',0,CFXdmp.NumVars);
  end;

  fprintf(1,' data');

  % write NumberOfVariableGroupsPerCell and for every group its number of variables
  % CFXdmp.NumVars ones(1,CFXdmp.NumVars)
  fprintf(fid,' %i',[CFXdmp.NumVars ones(1,CFXdmp.NumVars)]);
  fprintf(fid,'\n');

  % for every variable group
  for vg=1:CFXdmp.NumVars,
    % write group name and group unit
    % CFXdmp.Variable(vg).Name ', [unknown]' 
    fprintf(fid,'%s , [unknown]\n',CFXdmp.Variable(vg).Name);
  end;

  % read vars
  for vg=1:CFXdmp.NumVars,
    Var{vg}=cfx('readdmp',CFXdmp,vg,'patch',WritePatches,phase,t);
  end;

  fprintf(1,' patch');

  % for every patch
  FormatString=['%i',repmat(' %f',[1 CFXdmp.NumVars]),'\n'];
  for b=1:length(X),
    fprintf(1,' %i',b);

    % write %i and all the variables corners
    % [CellsetOff{b}+(1:prod(size(X{b})-1)); Var{:}{b}(:)]
    TEMP=zeros(1+CFXdmp.NumVars,length(I{b}));
    TEMP(1,:)=CellOffset{b}+(1:length(I{b}));
    for vg=1:CFXdmp.NumVars,
%      TEMP2=Var{vg}{b}(2:end-1,2:end-1,2:end-1);
      TEMP2=Var{vg}{b};
      TEMP(1+vg,:)=transpose(TEMP2(:));
    end;
    fprintf(fid,FormatString,TEMP);
  end;

  fprintf(1,'\n');

end;

fprintf(1,'\n');

% finished writing and close
fclose(fid);
Structure.Check='OK';


function Structure=Local_convert_dmp2fld(CFXdmp,AVSfld),
Structure.Check='NotOK';

if nargin<1,
  [fn,fp]=uigetfile('*.dmp');
  if ~ischar(fn),
    return;
  end;
  CFXdmp=[fp fn];
end;

if ischar(CFXdmp),
  CFXdmp=cfx('opendmp',CFXdmp);
  if isempty(CFXdmp),
    error('Unable to open CFX dmp file.');
    return;
  end;
end;

if nargin<2,
  [fn,fp]=uigetfile('*.fld');
  if ~ischar(fn),
    return;
  end;
  AVSfld=[fp fn];
end;

%WriteTimes=1:length(CFXdmp.Time);
WriteTimes=input(sprintf('%i time steps in the file\nTime steps to be saved: ',length(CFXdmp.Time)));
if isempty(WriteTimes),
  return;
end;

if strcmp(CFXdmp.Options.Coordinates,'Cylindrical'),
  fprintf(1,'Warning: cylindrical coordinates!');
end;

X=cfx('readdmp',CFXdmp,'X COORDINATES',1,1);

%for each block
B=1;
for b=1:length(B),

  fprintf(1,'Writing block %i:\n',b);

  fid=fopen(AVSfld,'w','ieee-be');
  
  % write number of time steps
  % length(WriteTimes)
  fprintf(fid,'# AVS Field file generated by Matlab\n');
  fprintf(fid,'ndim=3\n');
  for d=1:3,
    fprintf(fid,'dim%i=%i\n',d,size(X{b},d)-1);
  end;
  fprintf(fid,'nspace=3\n');
  fprintf(fid,'veclen=%i\n',CFXdmp.NumVars);
  fprintf(fid,'data=float\n');
  fprintf(fid,'field=irregular\n');
  fprintf(fid,'nstep=%i\n',length(WriteTimes));
  fprintf(fid,'DO\n');
  MovingGrid=length(CFXdmp.XEntry)>1;
  
  % save geometry
  SaveGeom=1;
  
  fprintf(1,'Writing step ...');
  
  % for every time step in the DMP file
  for t=WriteTimes,
  
    fprintf(fid,'time value = %s:%s\n',['step' sprintf('%i',t)],num2str(CFXdmp.Time(t)));
  
    if SaveGeom,
  
      % compute cell centers and save them to a seperate file
      SecFN='coords';
      fprintf(fid,'coord 1 file=%s filetype=binary skip=%i\n',SecFN,0);
      fprintf(fid,'coord 2 file=%s filetype=binary skip=%i\n',SecFN,0);
      fprintf(fid,'coord 3 file=%s filetype=binary skip=%i\n',SecFN,0);

      SaveGeom=0;
    end;
  
    % save links to variable data
    for vg=1:CFXdmp.NumVars,
      fprintf(fid,'variable %i file=%s filetype=binary skip=%i\n',vg,CFXdmp.FileName, ...
              CFXdmp.Entry(CFXdmp.Variable(vg).CellData(1,t)).Loc);
    end;
  
    fprintf(fid,'EOT\n');
  end;
  
  fprintf(fid,'ENDDO\n');
  
  % finished writing and close
  fclose(fid);
end;

Structure.Check='OK';


function T=tokens(Str);
Spaces=findstr([' ' Str ' '],' ');
Cuts=[Spaces(find(diff(Spaces)>1)) length(Str)+1];
for i=1:length(Cuts)-1,
 T{i}=deblank(Str(Cuts(i):(Cuts(i+1)-1)));
end;

function Str=deblank2(StrIn);
Str=deblank(StrIn);
Str=Str(min(find(~isspace(Str))):end);
