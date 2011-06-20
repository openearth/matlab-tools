function Out=arcinfo(cmd,varargin);
% ARCINFO File operations for an arcinfo directory structure.
%        InfoData = arcinfo('open',filename);
%           reads data from the info directory.
%
%        CoverData  = arcinfo('read',InfoData);
%          reads arc coverage data.
%
%        ItemHandle = arcinfo('plot',InfoData);
%          reads and plots arc coverage data.

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'open',
  Structure=Local_open_arcinfo(varargin{:});
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    elseif strcmp(Structure.Check,'NotOK'),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'opene00',
  Structure=Local_open_e00_file(varargin{:});
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    elseif strcmp(Structure.Check,'NotOK'),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'reade00',
  TempOut=Local_read_e00_file(varargin{:});
  if nargout>0,
    Out=TempOut;
  end;
case 'read',
  TempOut=Local_read_arcinfo(varargin{:});
  if nargout>0,
    Out=TempOut;
  end;
case 'plot',
  TempOut=Local_plot_arcinfo(varargin{:});
  if nargout>0,
    Out=TempOut;
  end;
otherwise,
  if ischar(cmd),
    Str=['unknown command: ',cmd];
  else,
    Str='No command string specified.';
  end;
  uiwait(msgbox(Str,'modal'));
end;


function Structure=Local_open_arcinfo(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('arc.dir');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r','ieee-be');

Structure.Type='arcinfo';
Structure.File=filename(1:(end-12));

BackupCD=cd;
cd([Structure.File 'info']);

Name=deblank(char(fread(fid,[1 32],'char')));
CoverNames={};
while ~isempty(Name),
  Dot=findstr('.',Name);
  CoverName=Name(1:(Dot-1));
  cvr=strmatch(CoverName,CoverNames,'exact');
  if isempty(cvr),
    CoverNames{end+1}=CoverName;
    cvr=length(CoverNames);
    Structure.Cover(cvr).Name=CoverName;
    Structure.Cover(cvr).DatabaseNames={};
  end;
  DatabaseName=deblank(Name((Dot+1):end));
  db=strmatch(DatabaseName,Structure.Cover(cvr).DatabaseNames,'exact');
  if isempty(db),
    Structure.Cover(cvr).DatabaseNames{end+1}=DatabaseName;
    db=length(Structure.Cover(cvr).DatabaseNames);
    Structure.Cover(cvr).Database(db).Name=DatabaseName;
  end;
  Structure.Cover(cvr).Database(db).InfoName=deblank(char(fread(fid,[1 8],'char')));
  Structure.Cover(cvr).Database(db).NFields=fread(fid,1,'int16');
  Structure.Cover(cvr).Database(db).NBytePerRecord=fread(fid,1,'int16');
%  Structure.Cover(cvr).Database(db).Str1=char(fread(fid,[1 16],'char'));
%  Structure.Cover(cvr).Database(db).X1=fread(fid,2,'int16'); % [132;0]
  fseek(fid,20,0);
  Structure.Cover(cvr).Database(db).NRecords=fread(fid,1,'int32');
%  Structure.Cover(cvr).Database(db).X2=fread(fid,5,'int16');
  fseek(fid,10,0);
  Structure.Cover(cvr).Database(db).FileType=fread(fid,1,'int16'); % 22616 'XX' (ADF) or 8224 '  ' (REL: LINKS) ?
%  Structure.Cover(cvr).Database(db).X3=fread(fid,119,'int16');
%  Structure.Cover(cvr).Database(db).Str2=char(fread(fid,[1 8],'char'));
%  Structure.Cover(cvr).Database(db).X4=fread(fid,4,'int16');
  fseek(fid,119*2+8+4*2,0);
  Structure.Cover(cvr).Database(db).Color1=fread(fid,4,'uint8'); % Color line? 00 RR GG BB
  Structure.Cover(cvr).Database(db).Color2=fread(fid,4,'uint8'); % Color fill? 00 RR GG BB
%  Structure.Cover(cvr).Database(db).X5=fread(fid,20,'int16');
  fseek(fid,19*2,0);
  Name=char(fread(fid,[1 32],'char'));
end;
fclose(fid);

Empty=logical(zeros(length(Structure.Cover),1));
for cvr=1:length(Structure.Cover),
  Empty(cvr)=isempty(Structure.Cover(cvr).Name);
end;
Structure.Cover(Empty)=[];

for cvr=1:length(Structure.Cover),
  for db=1:length(Structure.Cover(cvr).Database),
    fid=fopen([Structure.File 'info' filesep Structure.Cover(cvr).Database(db).InfoName '.dat'],'rt');
    if fid<0,
      fid=fopen([Structure.File 'info' filesep lower(Structure.Cover(cvr).Database(db).InfoName) '.dat'],'rt');
    end;
    if fid<0, % file does not exist?
    else,
      Structure.Cover(cvr).Database(db).FileName=PlatformPath(deblank(fgetl(fid)));
      fclose(fid);
  
      fid=fopen([Structure.File 'info' filesep Structure.Cover(cvr).Database(db).InfoName '.nit'],'r','ieee-be');
      if fid<0,
        fid=fopen([Structure.File 'info' filesep lower(Structure.Cover(cvr).Database(db).InfoName) '.nit'],'r','ieee-be');
      end;
      for f=1:Structure.Cover(cvr).Database(db).NFields,
        Structure.Cover(cvr).Database(db).Field(f).Name=deblank(char(fread(fid,[1 16],'char')));
        Structure.Cover(cvr).Database(db).Field(f).NBytes=fread(fid,1,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).X1=fread(fid,1,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).FieldOffset=fread(fid,1,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).X2=fread(fid,2,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).V1=fread(fid,1,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).V2=fread(fid,1,'int16');
        fseek(fid,12,0);
        Structure.Cover(cvr).Database(db).Field(f).Type=fread(fid,1,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).X3=fread(fid,5,'int16');
  %      Structure.Cover(cvr).Database(db).Field(f).Str1=char(fread(fid,[1 16],'char'));
  %      Structure.Cover(cvr).Database(db).Field(f).X4=fread(fid,43,'int16');
        fseek(fid,112,0);
      end;
      fclose(fid);
    end;
  end;
end;
CNames={Structure.Cover.Name};
[CNames,Sorted]=sort(CNames);
Structure.Cover=Structure.Cover(Sorted);
cd(BackupCD);
Structure.Check='OK';


function Out=Local_read_arcinfo(Structure),
Out=[];
%%%%%%%%%%%%%%%%%
BackupCD=cd;
cd([Structure.File 'info']);

cover=1;
db=1;
      intfig=figure(...
            'units','normalized', ...
            'position',[.5 .5 .1 .1], ...
            'menu','none', ...
            'units','pixels', ...
            'integerhandle','off', ...
            'numbertitle','off', ...
            'name','Select ...', ...
            'userdata',0, ...
            'closerequestfcn',' ');
      pos=get(intfig,'position');
      pos(3)=340;
      pos(4)=200;
      pos(1)=pos(1)-pos(3)/2;
      pos(2)=pos(2)-pos(4)/2;
      set(intfig,'position',pos);
      bgc=get(intfig,'color');
      CoverNames={Structure.Cover.Name};
      l(1)=uicontrol('style','popupmenu', ...
            'string',CoverNames, ...
            'parent',intfig, ...
            'value',cover, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[10 160 150 20], ...
            'callback','uiresume(gcf)');
      l(2)=uicontrol('style','pushbutton', ...
            'string','Cancel', ...
            'parent',intfig, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[10 10 150 20], ...
            'tag','Cancel', ...
            'callback','set(gcbf,''userdata'',2); uiresume(gcf)');

      db=strmatch('BND',Structure.Cover(cover).DatabaseNames);
      [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cover).Database(db).FileName);
      Files=dir(FilePath);
      Files=strvcat(Files.name);
      Files=upper(Files(:,1:3));

      l(3)=uicontrol('style','popupmenu', ...
            'string',Files, ...
            'parent',intfig, ...
            'value',db, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[170 160 150 20], ...
            'callback','');
      l(4)=uicontrol('style','pushbutton', ...
            'string','Load', ...
            'parent',intfig, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[170 10 150 20], ...
            'tag','Load', ...
            'callback','set(gcbf,''userdata'',1); uiresume(gcf)');
      gelm_font(l);

done=0;
while ~done,
  uiwait(intfig);
  switch get(intfig,'userdata'),
  case 1, % Load
    cover=get(l(1),'value');
    db=get(l(3),'value');
    file=get(l(3),'string');
    file=deblank(file(db,:));
    delete(intfig);
    done=1;
  case 2, % Cancel
    delete(intfig);
    cd(BackupCD);
    return;
  otherwise, % 0, uiresume by selection of cover
    cover=get(l(1),'value');

    db=strmatch('BND',Structure.Cover(cover).DatabaseNames);
    [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cover).Database(db).FileName);
    Files=dir(FilePath);
    Files=strvcat(Files.name);
    Files=upper(Files(:,1:3));
    set(l(3),'value',1,'string',Files);
  end;
end;
%%%%%%%%%%%%%%%%%

cvr=cover;
%%%%%%%%%%%%%
switch file,
case 'BND',
  % COVERAGE MIN/MAX COORDINATES: XMIN YMIN XMAX YMAX
  db=strmatch(file,Structure.Cover(cover).DatabaseNames);
  BND=LocalReadDatabase(Structure.Cover(cvr).Database(db).FileName, ...
                        Structure.Cover(cvr).Database(db).NRecords, ...
                        Structure.Cover(cvr).Database(db).Field);
  Out=BND;
case 'TIC',
  % TICKMARK COORDINATES
  db=strmatch(file,Structure.Cover(cover).DatabaseNames);
  TIC=LocalReadDatabase(Structure.Cover(cvr).Database(db).FileName, ...
                        Structure.Cover(cvr).Database(db).NRecords, ...
                        Structure.Cover(cvr).Database(db).Field);
  Out=TIC;
case 'AAT',
  % ARC ATTRIBUTE TABLE
  db=strmatch(file,Structure.Cover(cover).DatabaseNames);
  AAT=LocalReadDatabase(Structure.Cover(cvr).Database(db).FileName, ...
                        Structure.Cover(cvr).Database(db).NRecords, ...
                        Structure.Cover(cvr).Database(db).Field);
  Out=AAT;
case 'PAT',
  % POINT/POLYGON ATTRIBUTE TABLE
  db=strmatch(file,Structure.Cover(cover).DatabaseNames);
  PAT=LocalReadDatabase(Structure.Cover(cvr).Database(db).FileName, ...
                        Structure.Cover(cvr).Database(db).NRecords, ...
                        Structure.Cover(cvr).Database(db).Field);
  Out=PAT;
case 'ARC',
  % contains arc coordinates and topology
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['arc' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  AllRead=0;
  a=1;
  while ~feof(fid) & (ftell(fid)~=FileSize),
    ARC(a).arc_=fread(fid,1,'int32');
    ARC(a).Nwords=fread(fid,1,'int32');
    ARC(a).arc_id=fread(fid,1,'int32');
    ARC(a).arc_link=fread(fid,4,'int32');
    % ARC(a).arc_link = 0 0 0 0, if no arc topology was created
    % ARC(a).arc_link = FromNode ToNode -1 -1, if arc topology was created but no polygon topology was created
    % ARC(a).arc_link = FromNode ToNode LeftPoly RightPoly, if arc and polygon topologies were created
    ARC(a).Npoints=fread(fid,1,'int32');
    ARC(a).Point=fread(fid,[2 ARC(a).Npoints],'float32');
    a=a+1;
  end;
  currax=gca;
  for a=1:length(ARC),
    line(ARC(a).Point(1,:),ARC(a).Point(2,:));
  end;
%  ARCs=find(row([ARC.arc_link],1)==1); % example node
%  ARCs=[ARCs find(row([ARC.arc_link],2)==1)];
  ARCs=find(row([ARC.arc_link],3)==2); % example poly
  ARCs=[ARCs find(row([ARC.arc_link],4)==2)];
  for a=ARCs,
    line(ARC(a).Point(1,:),ARC(a).Point(2,:),'color','r');
  end;
  fclose(fid);
  Out=ARC;
case 'ARX',
  % arx contains indexes into arc file: start word address and number of words used -4
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['arx' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  ARX=transpose(fread(fid,[2 inf],'int32'));
  fclose(fid);
  Out=ARX;
case 'CNX',
  % cnx contains indexes into cnt file: start word address and number of words used -4
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['cnx' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  CNX=transpose(fread(fid,[2 inf],'int32'));
  fclose(fid);
  Out=CNX;
case 'CNT',
  % contains polygon centroid and label IDs: poly_, Polygon Centroid Coordinates, Number of Labels, Label_IDs
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['cnt' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  AllRead=0;
  c=1;
  while ~feof(fid) & (ftell(fid)~=FileSize),
    CNT(c).ID=fread(fid,1,'int32');
    CNT(c).NWords=fread(fid,1,'int32');
    CNT(c).PolyCentroid=fread(fid,2,'float32');
    line(CNT(c).PolyCentroid(1),CNT(c).PolyCentroid(2));
    CNT(c).NLabels=fread(fid,1,'int32');
    CNT(c).LabelNr=fread(fid,[1 CNT(c).NLabels],'int32'); % index numbers for LAB access
    c=c+1;
  end;
  fclose(fid);
  Out=CNT;
case 'PAX',
  % pax contains indexes into pat file: start word address and number of words used -4
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['pax' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  PAX=transpose(fread(fid,[2 inf],'int32'));
  fclose(fid);
  Out=PAX;
case 'PAL',
  % contains polygon topology, i.e. min/max x/y coordinates of polygon, NArcs, arc IDs and FromNode and ToNode ID of the arcs
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['pal' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  N=1;
  while ~feof(fid) & (ftell(fid)~=FileSize),
    PAL(N).ID=fread(fid,1,'int32'); % poly_
    PAL(N).NWords=fread(fid,1,'int32');
    PAL(N).MinMax=fread(fid,4,'float32'); % bounding box
    PAL(N).NArcs=fread(fid,1,'int32'); % number of arcs that form the boundary of the polygon
    PAL(N).Arcs=fread(fid,[3 PAL(N).NArcs],'int32'); % arc IDs and From and To Node IDs
    line([PAL(N).MinMax(1) PAL(N).MinMax(3) PAL(N).MinMax(3) PAL(N).MinMax(1) PAL(N).MinMax(1)], ...
         [PAL(N).MinMax(2) PAL(N).MinMax(2) PAL(N).MinMax(4) PAL(N).MinMax(4) PAL(N).MinMax(2)]);
    N=N+1;
  end;
  fclose(fid);
  Out=PAL;
case 'LAB',
  % contains label point coordinates and topology: coverage ID, enclosing polygon, x/y coordinates
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['lab' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  N=1;
  while ~feof(fid) & (ftell(fid)~=FileSize),
    LAB(N).CoverID=fread(fid,1,'int32'); % ID of label
    LAB(N).PolyID=fread(fid,1,'int32');  % ID of enclosing polygon, 0 for point coverages
    LAB(N).Point=fread(fid,2,'float32'); % location of the label point
    fseek(fid,4*4,0); % skip the obsolete label box window
    N=N+1;
  end;
  Points=[LAB.Point];
  line(Points(1,:),Points(2,:),'marker','*','linestyle','none');
  fclose(fid);
  Out=LAB;
case 'LOG',
  fprintf(1,'Coverage history LOG file reading not supported.\n');
  Out=[];
case 'PRJ',
  fprintf(1,'Projection parameter file reading not supported.\n');
  % e.g. Projection UTM
  %      Zone 13
  %      Datum NAD27
  %      Zunits NO
  %      Units METERS
  %      Spheriod CLARKE1866
  %      Xshift 0.000000000
  %      Yshift 0.000000000
  %      Parameters
  Out=[];
case 'SIN',
  fprintf(1,'Spacial index file reading not supported.\n');
  Out=[];
case 'TOL',
  % contains 10 tolerances: Tolerance type, Tolerance value
  % Types: fuzzy, generalize (unused), node match (unused), dangle, tic match, other five undefined?
  db=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(db).FileName);
  FileName=fullfile(FilePath,['tol' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  for i=1:10,
    TOL(i).Type=fread(fid,2,'int32');
    TOL(i).Value=fread(fid,1,'float32');
  end;
  fclose(fid);
  Out=TOL;
otherwise,
end;
%%%%%%%%%%%%%
cd(BackupCD);


%%%%%%%%%%%%%
function Out=Local_plot_arcinfo(Structure,Axes),
if nargout>0,
  Out=[];
end;
H=[];
%%%%%%%%%%%%%%%%%
BackupCD=cd;
cd([Structure.File 'info']);

cover=1;
db=1;
      intfig=figure(...
            'units','normalized', ...
            'position',[.5 .5 .1 .1], ...
            'menu','none', ...
            'units','pixels', ...
            'integerhandle','off', ...
            'numbertitle','off', ...
            'name','Select ...', ...
            'userdata',0, ...
            'closerequestfcn',' ');
      pos=get(intfig,'position');
      pos(3)=340;
      pos(4)=200;
      pos(1)=pos(1)-pos(3)/2;
      pos(2)=pos(2)-pos(4)/2;
      set(intfig,'position',pos);
      bgc=get(intfig,'color');
      CoverNames={Structure.Cover.Name};
      l(1)=uicontrol('style','popupmenu', ...
            'string',CoverNames, ...
            'parent',intfig, ...
            'value',cover, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[10 160 150 20], ...
            'callback','uiresume(gcf)');
      l(2)=uicontrol('style','pushbutton', ...
            'string','Cancel', ...
            'parent',intfig, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[10 10 150 20], ...
            'tag','Cancel', ...
            'callback','set(gcbf,''userdata'',2); uiresume(gcf)');
      Databases=Structure.Cover(cover).DatabaseNames;
      Labels=db2label(Databases);
      l(3)=uicontrol('style','popupmenu', ...
            'string',Labels, ...
            'parent',intfig, ...
            'value',1, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[170 160 150 20], ...
            'callback','');
      l(4)=uicontrol('style','pushbutton', ...
            'string','Plot', ...
            'parent',intfig, ...
            'units','pixels', ...
            'backgroundcolor',bgc, ...
            'horizontalalignment','left', ...
            'position',[170 10 150 20], ...
            'tag','Plot', ...
            'callback','set(gcbf,''userdata'',1); uiresume(gcf)');
      gelm_font(l);

done=0;
while ~done,
  uiwait(intfig);
  switch get(intfig,'userdata'),
  case 1, % Load
    cover=get(l(1),'value');
    db=get(l(3),'value');
    delete(intfig);
    done=1;
  case 2, % Cancel
    delete(intfig);
    cd(BackupCD);
    return;
  otherwise, % 0, uiresume by selection of cover
    cover=get(l(1),'value');
      Databases=Structure.Cover(cover).DatabaseNames;
      Labels=db2label(Databases);
    set(l(3),'value',1, ...
      'string',Labels);
  end;
end;
%%%%%%%%%%%%%%%%%

cvr=cover;
Color=md_color([0 0 0]);
if nargin<2,
  Axes=gca;
end;

switch Labels{db},
case 'Boundary',
  TempDB=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  BND=LocalReadDatabase(Structure.Cover(cvr).Database(TempDB).FileName, ...
                        Structure.Cover(cvr).Database(TempDB).NRecords, ...
                        Structure.Cover(cvr).Database(TempDB).Field);
  H=line([BND{1} BND{1} BND{3} BND{3} BND{1}],[BND{2} BND{4} BND{4} BND{2} BND{2}],'color',Color,'parent',Axes);

case 'Tick marks',
  TempDB=strmatch('TIC',Structure.Cover(cvr).DatabaseNames);
  TIC=LocalReadDatabase(Structure.Cover(cvr).Database(TempDB).FileName, ...
                        Structure.Cover(cvr).Database(TempDB).NRecords, ...
                        Structure.Cover(cvr).Database(TempDB).Field);
  H=line(TIC{2},TIC{3},'color',Color,'marker','o','linestyle','none','parent',Axes);

case 'Lines',
  TempDB=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(TempDB).FileName);
  FileName=fullfile(FilePath,['arc' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  if fid<0,
    fprintf(1,'No arc file found.\n');
    cd(BackupCD);
    return;
  end;

  TempDB=strmatch('AAT',Structure.Cover(cvr).DatabaseNames);
  if isempty(TempDB),
    NArcs=0; % determine NArcs from arc file ...
    X=fread(fid,6,'int32');
    switch X(2),
    case -1,
      Frmt='float64';
      NByteFrmt=8;
    case 1,
      Frmt='float32';
      NByteFrmt=4;
    otherwise,
      error('Expected -1 or 1 as single/double precision indicator.');
    end;
    FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
    fread(fid,18,'int32');
    while ~feof(fid) & (ftell(fid)~=FileSize),
      NArcs=NArcs+1;
      fseek(fid,28,0);
      Npoints=fread(fid,1,'int32');
      fseek(fid,2*Npoints*NByteFrmt,0); % fread(fid,[2 Npoints],Frmt);
    end;
    fseek(fid,0,-1); % go back to start of file
  else,
    NArcs=Structure.Cover(cvr).Database(TempDB).NRecords;
  end;

  X=fread(fid,6,'int32');
  switch X(2),
  case -1,
    Frmt='float64';
    NByteFrmt=8;
  case 1,
    Frmt='float32';
    NByteFrmt=4;
  otherwise,
    error('Expected -1 or 1 as single/double precision indicator.');
  end;
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  NPoints=((FileSize-100-NArcs*32)/(2*NByteFrmt))+NArcs;
  ARC(2,NPoints)=0;
  OffsetPoint=0;
  for a=1:NArcs,
    fseek(fid,28,0);
    Npoints=fread(fid,1,'int32');
    ARC(:,OffsetPoint+(1:Npoints))=fread(fid,[2 Npoints],Frmt);
    OffsetPoint=OffsetPoint+Npoints+1;
    ARC(:,OffsetPoint)=NaN;
  end;
  H=line(ARC(1,:),ARC(2,:),'color',Color,'hittest','off','clipping','off','parent',Axes);
  fclose(fid);

case 'Patches',
  TempDB=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(TempDB).FileName);
  FileName=fullfile(FilePath,['arc' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  if fid<0,
    fprintf(1,'No arc file found.\n');
    cd(BackupCD);
    return;
  end;

  NArcs=0; % determine NArcs from arc file ...
  X=fread(fid,6,'int32');
  switch X(2),
  case -1,
    Frmt='float64';
    NByteFrmt=8;
  case 1,
    Frmt='float32';
    NByteFrmt=4;
  otherwise,
    error('Expected -1 or 1 as single/double precision indicator.');
  end;
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  TotalNPoints=0;
  while ~feof(fid) & (ftell(fid)~=FileSize),
    NArcs=NArcs+1;
    fseek(fid,28,0);
    NPoints=fread(fid,1,'int32');
    TotalNPoints=TotalNPoints+NPoints;
    fseek(fid,2*NPoints*NByteFrmt,0);
  end;
  fseek(fid,0,-1); % go back to start of file

  Offset(NArcs)=0;
  NPoints(NArcs)=0;
  Poly(2,NArcs)=0;
  Point(2,TotalNPoints)=0;
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  CurrentOffset=0; % bytes
  for a=1:NArcs,
    fseek(fid,20,0);
    Poly(:,a)=fread(fid,2,'int32');
    NPoints(a)=fread(fid,1,'int32');
    Offset(a)=CurrentOffset;
    Point(:,Offset(a)+(1:NPoints(a)))=fread(fid,[2 NPoints(a)],Frmt);
    CurrentOffset=CurrentOffset+NPoints(a);
  end;
  fclose(fid); % go back to start of file

  PolyVal=unique([Poly(1,:) Poly(2,:)]);
  OutsideTouch=or(Poly(1,:)==1,Poly(2,:)==1);
  for p=PolyVal(2:end), % exclude 1
    NeighbInf=xor(Poly(1,:)==p,Poly(2,:)==p);
    if any(OutsideTouch & NeighbInf), % patch should touch a boundary
%  NeighbInf=xor(Poly(1,:)~=1,Poly(2,:)~=1);
      TotalNPoints=sum(NPoints(NeighbInf));

      Arcs=1:NArcs;
      Arcs=Arcs(NeighbInf);
      OffsetPoint1=0;
      OffsetPoint2=TotalNPoints+1;
      TotalNPoints=TotalNPoints+3*length(Arcs)-2;
      X=zeros(2,TotalNPoints);
      for a=Arcs,
        X(:,OffsetPoint1+(1:NPoints(a)))=Point(:,Offset(a)+(1:NPoints(a)));
        if a==Arcs(1),
          X(:,OffsetPoint2)=X(:,1);
          X(:,OffsetPoint2+1)=X(:,OffsetPoint1+NPoints(a));
          OffsetPoint2=OffsetPoint2+1;
        elseif a<Arcs(end),
          X(:,OffsetPoint2+1)=X(:,OffsetPoint1+1);
          X(:,OffsetPoint2+2)=X(:,1);
          X(:,OffsetPoint2+3)=X(:,OffsetPoint1+NPoints(a));
          OffsetPoint2=OffsetPoint2+3;
        else,
          X(:,OffsetPoint2+1)=X(:,OffsetPoint1+1);
          X(:,OffsetPoint2+2)=X(:,1);
          OffsetPoint2=OffsetPoint2+2;
        end;
        OffsetPoint1=OffsetPoint1+NPoints(a);
      end;
%      H=patch(X(1,:),X(2,:),1,'edgecolor','none','facecolor',Color,'hittest','off','clipping','off');
      H=[H patch(X(1,:),X(2,:),1,'edgecolor','none','facecolor',Color,'hittest','off','clipping','off','userdata',p,'parent',Axes)];
    end;
  end;

case 'Label locations',
  % contains ID and three times the point
  TempDB=strmatch('BND',Structure.Cover(cvr).DatabaseNames);
  [FilePath,Bnd,Extens]=fileparts(Structure.Cover(cvr).Database(TempDB).FileName);
  FileName=fullfile(FilePath,['lab' Extens]);
  fid=fopen(FileName,'r','ieee-be');
  fread(fid,6,'int32');
  FileSize=2*fread(fid,1,'int32'); % FileSize stored in words
  fread(fid,18,'int32');
  NPoints=(FileSize-100)/32;
  Point(2,NPoints)=0;
  for p=1:NPoints,
    fseek(fid,8,0);
    Point(:,p)=fread(fid,2,'float32');
    fseek(fid,16,0);
  end;
  Color=Structure.Cover(cvr).Database(TempDB).Color1(2:4)/255;
  H=line(Point(1,:),Point(2,:),'markersize',6,'linestyle','none','color',Color,'hittest','off','clipping','off','parent',Axes);
  set(H,'marker','.');
  fclose(fid);

otherwise,
  fprintf('Plotting of %s not implemented.\n',Labels{db});

end;
%%%%%%%%%%%%%
set(Axes,'drawmode','fast','dataaspectratio',[1 1 1]);
cd(BackupCD);
if ~isempty(H),
  set(H(1),'tag',[deblank(Structure.Cover(cvr).Name) ' - ' deblank(Labels{db})]);
end;
if nargout>0,
  Out=H;
end;


function lbl=db2label(db);
lbl={};
for i=1:length(db),
  switch deblank(db{i}),
  case 'BND',
    lbl={lbl{:} 'Boundary'};
  case 'TIC',
    lbl={lbl{:} 'Tick marks'};
  case 'AAT',
    lbl={lbl{:} 'Lines'};
  case 'PAT',
    lbl={lbl{:} 'Lines' 'Patches'};
  case 'LAB',
    lbl={lbl{:} 'Label locations'};
  otherwise,
    fprintf('Don''t know what to plot based on %s\n',db{i});
  end;
end;


function FileNameOut=PlatformPath(FileNameIn),
switch filesep,
case '/',
  FileNameOut=strrep(FileNameIn,'\','/');
case '\',
  FileNameOut=strrep(FileNameIn,'/','\');
end;

function DB=LocalReadDatabase(FileName,NRecords,Field),
fid=fopen(FileName,'r','ieee-be');
NFields=length(Field);
DB{NFields}=0;
for f=1:NFields,
  switch Field(f).Type,
  case 5, % int32
    DB{f}=zeros(NRecords,1);
  case 6, % float32
    DB{f}=zeros(NRecords,1);
  case 2, % char
    DB{f}=char(32*ones(1,Field(f).NBytes));
    DB{f}(NRecords,1)=' ';
  otherwise, % unknown
    DB{f}=zeros(1,Field(f).NBytes);
    DB{f}(NRecords,1)=0;
  end;
end;
NByte=sum([Field(:).NBytes]);
NByteFill=2*ceil(NByte/2)-NByte;
for r=1:NRecords,
  for f=1:NFields,
    switch Field(f).Type,
    case 5, % integer
      switch Field(f).NBytes,
      case 4,
        DB{f}(r)=fread(fid,1,'int32');
      otherwise,
        fprintf(1,'Needs implementing: integer %i bytes',Field(f).NBytes);
      end;
    case 6, % floating point
      switch Field(f).NBytes,
      case 4,
        DB{f}(r)=fread(fid,1,'float32');
      case 8,
        DB{f}(r)=fread(fid,1,'float64');
      otherwise,
        fprintf(1,'Needs implementing: integer %i bytes',Field(f).NBytes);
      end;
    case 2, % char
      DB{f}(r,:)=char(fread(fid,[1 Field(f).NBytes],'char'));
    otherwise, % unknown
      fprintf(1,'Needs implementing: unknown(%i) %i bytes',Field(f).Type,Field(f).NBytes);
      DB{f}(r,:)=fread(fid,[1 Field(f).NBytes],'uint8');
    end;
  end;
  fread(fid,NByteFill,'uint8');
end;
fclose(fid);


function Structure=Local_open_e00_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.e00');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r');

Line=fgetl(fid);
if ~isequal(Line(1:3),'EXP'),
  fclose(fid);
  return;
end;
Slash=max(findstr(filesep,filename));
Dot=max(findstr('.',filename));
Structure.Type='e00';
Structure.File=filename;

Structure.Cover.Name=filename((Slash+1):(Dot-1));

db=1;
Line=fgetl(fid);
while ~isequal(Line(1:3),'EOS'),

  FormatDbl=isequal(sscanf(Line(4:end),'%f',1),3);
  switch Line(1:3),
  case 'IFO', % info block
  otherwise,
    Structure.Cover.Database(db).Name=Line(1:3);
    Structure.Cover.Database(db).Double=FormatDbl;
    Structure.Cover.Database(db).Start=ftell(fid);
  end;

  switch Line(1:3),
  case 'GRD', % arc grid

    % SizeX SizeY 1-0.2E10
    % dx dy
    % xmin ymin
    % xmax ymax
    Line=fgetl(fid);
    X=sscanf(Line,'%i',[1 2]);
    Structure.Cover.Database(db).Info.Size=X;
    X=fscanf(fid,'%f',[1 6]);
    Line=fgetl(fid); % read EOL
    Structure.Cover.Database(db).Info.CellSize=X(1:2);
    Structure.Cover.Database(db).Info.Box=X(3:6);

    Structure.Cover.Database(db).Start=ftell(fid);

    Line=fgetl(fid);
    NBytesPerLine=ftell(fid)-Structure.Cover.Database(db).Start;
    fseek(fid,NBytesPerLine*((ceil(Structure.Cover.Database(db).Info.Size(1)/5)*Structure.Cover.Database(db).Info.Size(2))-1),0);

    Line=fgetl(fid); % EOG

  case 'ARC', % arc coordinates and topology

    % cov_nr cov_ID fromNode toNode leftPoly rightPoly NCoord
    Line=fgetl(fid);
    X=sscanf(Line,'%i',7);

    NArcs=0;
    NPnts=0;
    while X(1)>=0, % cov_nr = -1 for the last entry
      NArcs=NArcs+1;
      NPnts=NPnts+X(7);

      % x-y pairs
      X=fscanf(fid,'%f',[2 X(7)]);
      Line=fgetl(fid); % read EOL

      Line=fgetl(fid);
      X=sscanf(Line,'%i',7);
    end;

    Structure.Cover.Database(db).Info.NArcs=NArcs;
    Structure.Cover.Database(db).Info.NPnts=NPnts;

  case 'CNT', % polygon centroid coordinates

    % n_lbl x_centr y_centr
    Line=fgetl(fid);
    X=sscanf(Line,'%f',3);

    NPols=0;
    NLbls=0;
    while X(1)>=0, % n_lbl = -1 for the last entry
      NPols=NPols+1;
      NLbls=NLbls+X(1);

      % label_id(s)
      if X(1)>0,
        X=fscanf(fid,'%i',X(1));
        Line=fgetl(fid); % read EOL
      end;

      Line=fgetl(fid);
      X=sscanf(Line,'%f',3);
    end;

    Structure.Cover.Database(db).Info.NPols=NPols;
    Structure.Cover.Database(db).Info.NLbls=NLbls;

  case 'LAB', % label point coordinates and topology

    % cov_id poly_id x_coor y_coor
    Line=fgetl(fid);
    X=sscanf(Line,'%f',4);

    NLbls=0;
    while X(1)>=0, % n_lbl = -1 for the last entry
      NLbls=NLbls+1;

      % label box (obsolete)
      X=fscanf(fid,'%f',[2 2]);
      Line=fgetl(fid); % read EOL

      Line=fgetl(fid);
      X=sscanf(Line,'%f',4);
    end;

    Structure.Cover.Database(db).Info.NLbls=NLbls;

  case 'LOG', % coverage history

    % year month day hours minutes connect_time CPU_time IO_time command_line
    % command_line may continue on next line
    % entries separated by ~
    Line=fgetl(fid);

    NEntries=0;
    while ~isequal(Line,'EOL'), % EOL is the last entry
      if Line(1)=='~',
        NEntries=NEntries+1;
      end;
      Line=fgetl(fid);
    end;

    Structure.Cover.Database(db).Info.NEntries=NEntries;

  case 'PAL', % polygon topology

    % narcs xmin ymin xmax ymax
    Line=fgetl(fid);
    X=sscanf(Line,'%f',5);

    NPols=0;
    NArcs=0;
    while X(1)>=0, % narcs = -1 for the last entry
      NPols=NPols+1;
      NArcs=NArcs+X(1);

      % arc_nr node_nr poly_nr
      % 0 0 0 as separator between boundary sections
      X=fscanf(fid,'%f',[3 X(1)]);
      Line=fgetl(fid); % read EOL

      Line=fgetl(fid);
      X=sscanf(Line,'%f',5);
    end;

    if Structure.Cover.Database(db).Double, % in case of double precision, there's an additional line
      Line=fgetl(fid);
    end;

    Structure.Cover.Database(db).Info.NPols=NPols;
    Structure.Cover.Database(db).Info.NArcs=NArcs;

  case 'PRJ', % projection parameters

    % parameter strings separated by ~
    Line=fgetl(fid);

    NEntries=0;
    while ~isequal(Line,'EOP'), % EOP is the last entry
      if Line(1)=='~',
        NEntries=NEntries+1;
      end;
      Line=fgetl(fid);
    end;

    Structure.Cover.Database(db).Info.NEntries=NEntries;

  case 'RXP', % UNKNOWN

    % POLY
    % 1 42
    % 2 43
    % -1 0
    % JABBERWOCKY

    fprintf(1,['Warning: contains ',Line(1:3),' database.\n']);

    Line=fgetl(fid); % POLY

    Line=fgetl(fid);
    X=sscanf(Line,'%i',2);

    NE=0;
    while X(1)>=0, % -1 for the last entry
      NE=NE+1;

      Line=fgetl(fid);
      X=sscanf(Line,'%i',2);
    end;

    Line=fgetl(fid); % JABBERWOCKY

    Structure.Cover.Database(db).Info.NE=NE;

  case 'RPL', % UNKNOWN

    % POLY
    %         1 1.88758656250000E+05 4.29142468750000E+05
    % 1.90476593750000E+05 4.31323281250000E+05
    %        53        52         0
    %         9 1.47653593750000E+05 4.23802593750000E+05
    % 1.48717140625000E+05 4.25031875000000E+05
    %        60        60         0       -59        59         0
    %        58        58         0       -57        57         0
    %        56        56         0       -55        55         0
    %        54        54         0        61        53         0
    %       -62        61         0
    %        -1         0         0         0         0         0         0
    % JABBERWOCKY

    fprintf(1,['Warning: contains ',Line(1:3),' database.\n']);

    Line=fgetl(fid); % POLY

    Line=fgetl(fid);
    X=sscanf(Line,'%f',3); % N xmin ymin

    NE=0;
    NE1=0;
    while X(1)>=0, % -1 for the last entry
      NE=NE+1;
      NE1=NE1+X(1);

      Line=fgetl(fid); % xmax ymax
      X=fscanf(fid,'%i',[3 X(1)]);
      Line=fgetl(fid); % read EOL

      Line=fgetl(fid);
      X=sscanf(Line,'%f',3);
    end;

    if Structure.Cover.Database(db).Double, % in case of double precision, there's an additional line
      Line=fgetl(fid);
    end;

    Line=fgetl(fid); % JABBERWOCKY

    Structure.Cover.Database(db).Info.NE=NE;

  case 'SIN', % spatial index

    % contents mostly nothing but EOX
    Line=fgetl(fid);

    while ~isequal(Line,'EOX'), % EOX is the last entry
      Line=fgetl(fid);
    end;

  case 'TOL', % tolerance type

    % tolnr verify value
    Line=fgetl(fid);
    X=sscanf(Line,'%f',3);

    NTol=0;
    while X(1)>=0, % tolnr = -1 for the last entry
      NTol=NTol+1;
      Line=fgetl(fid);
      X=sscanf(Line,'%f',3);
    end;

    Structure.Cover.Database(db).Info.NTol=NTol;

  case 'NXY', % X and Y value for each point

    Line=fgetl(fid);
    X=sscanf(Line,'%f');
    NPnt=0;
    while ~isequal(X,[-1;0;0;0;0;0;0]),
      NPnt=NPnt+length(X);
      Line=fgetl(fid);
      X=sscanf(Line,'%f');
    end;

    Structure.Cover.Database(db).Info.NPnts=NPnt/2;
   

  case 'NZ ', % Z value for each point

    Line=fgetl(fid);
    Z=sscanf(Line,'%f');
    NPnt=0;
    while ~isequal(Z,[-1;0;0;0;0;0;0]),
      NPnt=NPnt+length(Z);
      Line=fgetl(fid);
      Z=sscanf(Line,'%f');
    end;

    Structure.Cover.Database(db).Info.NPnts=NPnt;
   

  case 'NOD', % Node 1, 2, and 3 for each patch

    Line=fgetl(fid);
    Nod=sscanf(Line,'%f');
    NTri=0;
    while ~isequal(Nod,[-1;0;0;0;0;0;0]),
      NTri=NTri+length(Nod);
      Line=fgetl(fid);
      Nod=sscanf(Line,'%f');
    end;

    Structure.Cover.Database(db).Info.NTri=NTri/3;

  case 'TMK', % Active patches mask

    Line=fgetl(fid);
    X=sscanf(Line,'%f',2); % NPnts NLines

    Structure.Cover.Database(db).Info.NTri=X(1);

    for i=1:X(2),
      Line=fgetl(fid);
    end;

    Line=fgetl(fid); %    -1    0    0  ...

  case 'EDG', % Edge number?

    Line=fgetl(fid);
    Edg=sscanf(Line,'%f');
    NTri=0;
    while ~isequal(Edg,[-1;0;0;0;0;0;0]),
      NTri=NTri+length(Edg);
      Line=fgetl(fid);
      Edg=sscanf(Line,'%f');
    end;

    Structure.Cover.Database(db).Info.NTri=NTri/3;

  case 'ENV', % NPnt, NPatch, min/max X,Y,Z

    fprintf(1,['Warning: contains ',Line(1:3),' database.\n']);

    X=fscanf(fid,'%i',[6 4]);

    Structure.Cover.Database(db).Info.NPnt=X(1);
    Structure.Cover.Database(db).Info.NTri=X(2);

    X=fscanf(fid,'%f',[2 4]);

    Structure.Cover.Database(db).Info.XLim=transpose(X(:,1));
    Structure.Cover.Database(db).Info.YLim=transpose(X(:,2));
    Structure.Cover.Database(db).Info.ZLim=transpose(X(:,4));

    Line=fgetl(fid); % 70001

    Line=fgetl(fid); %       -1      0

  case 'HUL', % HUL of active(?) area

    Line=fgetl(fid);
    Pnt=sscanf(Line,'%f');
    NPnt=0;
    while ~isequal(Pnt,[-1;0;0;0;0;0;0]),
      NPnt=NPnt+length(Pnt);
      Line=fgetl(fid);
      Pnt=sscanf(Line,'%f');
    end;

    Structure.Cover.Database(db).Info.NPntOnHul=NPnt;
    
  case 'IFO', % info files

    % contains .AAT .ACODE .BND .PAT .PCODE .TIC files
    Line=fgetl(fid);

    while ~isequal(Line,'EOI'), % EOI is the last entry
      Dot=min(findstr('.',Line));
      Space=min(findstr(' ',Line));
      XX=max(findstr('XX',Line));
      
      Structure.Cover.Database(db).Name=Line((Dot+1):(Space-1));
      Structure.Cover.Database(db).Double=FormatDbl;

      Line=Line(max(XX+2,Space):end);
      X=sscanf(Line,'%i',4);
     
      NFields=X(1);
%      NFields=X(2);
%      Structure.Cover.Database(db).Info.TotalNBytes=X(3);
      Structure.Cover.Database(db).Info.NRecs=X(4);

      TotalNChar=0;
      for fld=1:NFields,
        %         1         2         3         4         5         6         7
        %1234567890123456789012345678901234567890123456789012345678901234567890
        %AREA              8-1   14-1  18 5 60-1  -1  -1-1                   1-
        %PERIMETER         8-1   94-1  18 5 60-1  -1  -1-1                   2-
        %ALOCBOS#          4-1  174-1   5-1 50-1  -1  -1-1                   3-
        %ALOCBOS-ID        4-1  214-1   5-1 50-1  -1  -1-1                   4-
        %LEGENDA_NR        3-1  254-1   3-1 30-1  -1  -1-1                   5-
        %LEGENDA_SOORT    30-1  284-1  30-1 20-1  -1  -1-1                   6-

        Line=fgetl(fid);
        Structure.Cover.Database(db).Info.Field(fld).Name=deblank(Line(1:16));
        Structure.Cover.Database(db).Info.Field(fld).NBytes=sscanf(Line(17:19),'%i',1);
        % Structure.Cover.Database(db).Info.Field(fld).Offset=sscanf(Line(22:25),'%i',1);
        Structure.Cover.Database(db).Info.Field(fld).Type=sscanf(Line(35:36),'%i',1);
        switch Structure.Cover.Database(db).Info.Field(fld).Type,
        case 1, % NBytes=1
          Structure.Cover.Database(db).Info.Field(fld).NChars=Structure.Cover.Database(db).Info.Field(fld).NBytes;
        case 2,
          Structure.Cover.Database(db).Info.Field(fld).NChars=Structure.Cover.Database(db).Info.Field(fld).NBytes;
        case 3, % NBytes=1, 3 or 7
          Structure.Cover.Database(db).Info.Field(fld).NChars=Structure.Cover.Database(db).Info.Field(fld).NBytes;
        case 5, % NBytes=4
          switch Structure.Cover.Database(db).Info.Field(fld).NBytes,
          case 4,
            Structure.Cover.Database(db).Info.Field(fld).NChars=11;
          end;
        case 6, % NBytes=4 or 8
          switch Structure.Cover.Database(db).Info.Field(fld).NBytes,
          case 4,
            Structure.Cover.Database(db).Info.Field(fld).NChars=14;
          case 8,
            Structure.Cover.Database(db).Info.Field(fld).NChars=24;
          end;
        end;
        TotalNChar=TotalNChar+Structure.Cover.Database(db).Info.Field(fld).NChars;
      end;

      NLines=ceil(TotalNChar/80);
      Structure.Cover.Database(db).Start=ftell(fid);

      % skip data
      for i=1:Structure.Cover.Database(db).Info.NRecs;
        for l=1:NLines,
          Line=fgetl(fid);
        end;
      end;

      db=db+1;
      Line=fgetl(fid);
    end;
    db=db-1;

  otherwise,
    fprintf(1,['Unknown database (',Line(1:3),') encountered.\n']);
    fclose(fid);
    return;
  end;

  db=db+1;
  Line=fgetl(fid);
end;

fclose(fid);
Structure.Check='OK';


function Data=Local_read_e00_file(S,db),
Data=[];
C=S.Cover;
if ischar(db),
  db=strmatch(db,strvcat(C.Database.Name),'exact');
end;
if isempty(db) | ~ismember(db,1:length(C.Database)),
  return;
end;
D=C.Database(db);

fid=fopen(S.File,'r');
fseek(fid,D.Start,-1);

switch D.Name,
case 'ARC', % arc coordinates and topology

  % cov_nr cov_ID fromNode toNode leftPoly rightPoly NCoord
      % x-y pairs

  Data.Arc_=zeros(D.Info.NArcs,1);
  Data.Arc_ID=zeros(D.Info.NArcs,1);
  Data.Nodes=zeros(D.Info.NArcs,2);
  Data.Polygons=zeros(D.Info.NArcs,2);
  Data.PntInd=zeros(D.Info.NArcs,2);
  Data.Point=zeros(D.Info.NPnts,2);
  PntInd=0;
  for entry=1:D.Info.NArcs,
    X=fscanf(fid,'%i',[1 7]);
    Data.Arc_(entry)=X(1);
    Data.Arc_ID(entry)=X(2);
    Data.Nodes(entry,:)=X(3:4);
    Data.Polygons(entry,:)=X(5:6);
    Data.PntInd(entry,1)=PntInd+1;
    Data.PntInd(entry,2)=PntInd+X(7);
    X=fscanf(fid,'%f',[2 X(7)]);
    Data.Point(Data.PntInd(entry,1):Data.PntInd(entry,2),:)=transpose(X);
    PntInd=Data.PntInd(entry,2);
  end;

case 'GRD', % arc grid

  Data.CellSize=D.Info.CellSize;
  Data.Box=D.Info.Box;
  Data.Data=fscanf(fid,'%f',[D.Info.Size(1)+4 D.Info.Size(2)]);

case 'CNT', % polygon centroid coordinates

  % n_lbl x_centr y_centr
      % label_id(s)

  Data.Point=zeros(D.Info.NPols,2);
  Data.Label=cell(D.Info.NPols,1);
  for entry=1:D.Info.NPols,
    X=fscanf(fid,'%f',[1 3]);
    Data.Point(entry,:)=X(2:3);
    Data.Label{entry}=fscanf(fid,'%i',X(1));
  end;

case 'LAB', % label point coordinates and topology

  % lbl_id poly_id x_coor y_coor
      % label box (obsolete)

  Data.Lbl_ID=zeros(D.Info.NLbls,1);
  Data.Poly_ID=zeros(D.Info.NLbls,1);
  Data.Point=zeros(D.Info.NLbls,2);
  for entry=1:D.Info.NLbls,
    X=fscanf(fid,'%i',[1 2]);
    Data.Lbl_ID(entry,:)=X(1);
    Data.Poly_ID(entry,:)=X(2);
    X=fscanf(fid,'%f',[1 2]);
    Data.Point(entry,:)=X;
    X=fscanf(fid,'%f',[1 4]); % label box is obsolete
  end;

case 'LOG', % coverage history

  % year month day hours minutes connect_time CPU_time IO_time command_line
  % command_line may continue on next line
  % entries separated by ~

  Data.Date=zeros(D.Info.NEntries,1);
  Data.ConnectTime=zeros(D.Info.NEntries,1);
  Data.CPUTime=zeros(D.Info.NEntries,1);
  Data.IOTime=zeros(D.Info.NEntries,1);
  Data.Command=cell(D.Info.NEntries,1);
  Line=fgetl(fid);
  if Line(end)==13, Line=Line(1:(end-1)); end; % sometimes Matlab forgets to remove the EOL character
  for entry=1:D.Info.NEntries,
    Ye=sscanf(Line(1:4),'%i',1);
    Mo=sscanf(Line(5:6),'%i',1);
    Da=sscanf(Line(7:8),'%i',1);
    Ho=sscanf(Line(9:10),'%i',1);
    Mi=sscanf(Line(11:12),'%i',1);
    Data.Date(entry)=datenum(Ye,Mo,Da,Ho,Mi,0);
    Data.ConnectTime(entry)=sscanf(Line(13:16),'%i',1);
    Data.CPUTime(entry)=sscanf(Line(17:22),'%i',1);
    Data.IOTime(entry)=sscanf(Line(23:28),'%i',1);
    Data.Command{entry}=Line(29:end);
    Line=fgetl(fid);
    if Line(end)==13, Line=Line(1:(end-1)); end; % sometimes Matlab forgets to remove the EOL character
    while Line(1)=='~',
      Data.Command{entry}=[Data.Command{entry} Line(2:end)];
      Line=fgetl(fid);
      if Line(end)==13, Line=Line(1:(end-1)); end; % sometimes Matlab forgets to remove the EOL character
    end;
  end;

case 'PAL', % polygon topology

  % narcs xmin ymin xmax ymax
      % arc_nr node_nr outside_poly_nr
      % 0 0 0 as separator between boundary sections

  Data.Box=zeros(D.Info.NPols,4);
  Data.ArcInd=zeros(D.Info.NPols,2);
  Data.Arc=zeros(D.Info.NArcs,3);

  ArcInd=0;
  for entry=1:D.Info.NPols,
    X=fscanf(fid,'%f',[1 5]);
    Data.Box(entry,:)=X(2:5);
    Data.ArcInd(entry,1)=ArcInd+1;
    Data.ArcInd(entry,2)=ArcInd+X(1);
    X=fscanf(fid,'%f',[3 X(1)]);
    Data.Arc(Data.ArcInd(entry,1):Data.ArcInd(entry,2),:)=transpose(X);
    ArcInd=Data.ArcInd(entry,2);
  end;

case 'PRJ', % projection parameters

  % parameter strings separated by ~

  Data.Proj=cell(D.Info.NEntries,1);

  for entry=1:D.Info.NEntries,
    Data.Proj{entry}=deblank(fgetl(fid));
    Line=fgetl(fid); % skip ~
  end;

case 'TOL', % tolerance type

  % tolnr tolUsed value

  Data.TolNr=zeros(D.Info.NTol,1);
  Data.Used=zeros(D.Info.NTol,1);
  Data.Value=zeros(D.Info.NTol,1);

  for entry=1:D.Info.NTol,
    X=fscanf(fid,'%f',3);
    Data.TolNr(entry)=X(1);
    Data.Used(entry)=X(2)==2;
    Data.Value(entry)=X(3);
  end;

case 'NXY', % X,Y values per point

  XY=fscanf(fid,'%f',[2 D.Info.NPnts]);
  Data.X=XY(1,:);
  Data.Y=XY(2,:);

case 'NZ ', % Z value per point

  Z=fscanf(fid,'%f',[1 D.Info.NPnts]);
  Data.Z=Z(1,:);

case 'NOD', % Nodes of per triangle

  Data.Tri=fscanf(fid,'%f',[3 D.Info.NTri])';

case 'TMK', % TIN Mask; active triangles: 0, inactive triangles: 1

  X=fscanf(fid,'%f',2)';
  NTri=X(1);

  Data.Mask=logical(fscanf(fid,'%1i',NTri));

case 'EDG', % Edge number?

  Data.Edg=fscanf(fid,'%f',[3 D.Info.NTri])';

case 'ENV', % NPnt, NPatch, min/max X,Y,Z

  Data=D.Info;

case 'HUL', % HUL of active(?) area

  X=fscanf(fid,'%i',[1 D.Indo.NPntOnHul]);
  Cut=find([-1 X -1]==-1);
  for i=1:(length(Cut)-1),
    Data.Hul(i)=X(Cut(i),Cut(i+1)-2);
  end;

case {'SIN','RXP','RPL'},

  fprintf(1,['Format of ',Line(1:3),' database is unknown.\n']);

otherwise,
  % case {'AAT','ACODE','BND','PAT','PCODE','TIC','STA','VAT'},

  % AAT   % arc attribute table
  % ACODE % arc lookup table
  % BND   % coverage min/max coordinates
  % PAT   % polygon or point attribute table
  % PCODE % polygon or point lookup table
  % TIC   % tickmark coordinates
  % STA   % statistic data for grid
  % VAT   % value attribute table

  Data.FieldName={D.Info.Field.Name};
  Data.Field=cell(1,length(D.Info.Field));
  for fld=1:length(D.Info.Field),
    switch D.Info.Field(fld).Type,
    case 1, % integer % logical?
      Data.Field{fld}=zeros(D.Info.NRecs,1);
    case 2, % character
      Data.Field{fld}=cell(D.Info.NRecs,1);
    case 3, % integer % uint8?
      Data.Field{fld}=zeros(D.Info.NRecs,1);
    case 5, % integer
      Data.Field{fld}=zeros(D.Info.NRecs,1);
    case 6, % float
      Data.Field{fld}=zeros(D.Info.NRecs,1);
    end;
  end;

  TotalNChars=sum([D.Info.Field(:).NChars]);
  NLines=ceil(TotalNChars/80);

  for entry=1:D.Info.NRecs,
    EntryStr=char(32*ones(1,TotalNChars));
    for i=1:NLines,
      Line=fgetl(fid);
      if length(Line)>0,
        if Line(end)==13, Line=Line(1:(end-1)); end; % sometimes Matlab forgets to remove the EOL character
      end;
      EntryStr((i-1)*80+(1:length(Line)))=Line;
    end;
    Offset=0;
    for fld=1:length(D.Info.Field),
      switch D.Info.Field(fld).Type,
      case 1, % integer % logical?
        Data.Field{fld}(entry)=sscanf(EntryStr(Offset+(1:D.Info.Field(fld).NChars)),'%i',1);
      case 2, % character
        Data.Field{fld}{entry}=deblank(EntryStr(Offset+(1:D.Info.Field(fld).NChars)));
      case 3, % integer % uint8?
        Data.Field{fld}(entry)=sscanf(EntryStr(Offset+(1:D.Info.Field(fld).NChars)),'%i',1);
      case 5, % integer
        Data.Field{fld}(entry)=sscanf(EntryStr(Offset+(1:D.Info.Field(fld).NChars)),'%i',1);
      case 6, % float
        Data.Field{fld}(entry)=sscanf(EntryStr(Offset+(1:D.Info.Field(fld).NChars)),'%f',1);
      end;
      Offset=Offset+D.Info.Field(fld).NChars;
    end;
  end;

end;

fclose(fid);
