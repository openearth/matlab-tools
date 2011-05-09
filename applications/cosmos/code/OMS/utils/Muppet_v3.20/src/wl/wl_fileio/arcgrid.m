function [Out,Out2]=arcgrid(cmd,varargin)
% ARCGRID File operations for an arcgrid file.
%        FileData = arcgrid('open',filename);
%           Opens data from an arcgrid file
%           and determines the dimensions of
%           the grid. Detects the presence of
%           multiple arcgrid-files (for FLS).
%
%        Data = arcgrid('read',filename);
%           Reads data from a not-opened
%           arcgrid file.
%
%        Data = arcgrid('read',FileData);
%           Reads data from an opened
%           arcgrid file.
%        Data = arcgrid('read',FileData,i);
%           Reads data from the i-th data
%           file in a series.
%
%        arcgrid('write',FileData,filename);
%           Writes data to an arcgrid file.
%
%        AxesHandle = arcgrid('plot',FileData);
%           Plots arcgrid data as elevations.

% (c) copyright 1998-2001, H.R.A. Jagers, bert.jagers@wldelft.nl
%     WL | Delft Hydraulics, The Netherlands

if nargin==0
   if nargout>0
      Out=[];
   end
   return
end
switch cmd
   case 'open'
      Out=Local_open_file(varargin{:});
   case 'read'
      DX=Local_read_file(varargin{:});
      if iscell(DX)
         Out=DX{1};
         if length(DX)>1
            Out2=DX{2};
         end
      else
         Out=DX;
      end
   case 'resample'
      Out=Local_resample_file(varargin{:});
   case 'write'
      if nargin==1
         error('Not enough input arguments.')
      end
      Local_write_file(varargin{:});
   case 'plot'
      if nargin==1
         H=[];
      else
         H=Local_plot_file(varargin{:});
      end
      if nargout>0
         Out=H;
      end
   otherwise
      error(sprintf('Unknown command: "%s"',cmd))
end


function Structure=Local_open_file(filename)
Structure.Check='NotOK';
Structure.FileType='arcgrid';

if (nargin==0) | strcmp(filename,'?')
   [fn,fp]=uigetfile('*.arc');
   if ~ischar(fn)
      return
   end
   filename=[fp fn];
end
fid=fopen(filename,'r');
Structure.FileName=filename;
if fid<0
   return
end
[p,n,e]=fileparts(filename);
Structure.Extension=e(2:end);
Line=fgetl(fid); % First lines might be comment lines: /* ....
while strmatch('/*',Line)
   Line=fgetl(fid);
end
Line=lower(Line);

Loc=findstr(Line,'ncols');
if isequal(size(Loc),[1 1])
   Structure.NCols=sscanf(Line((Loc+5):end),'%i',1);
   Line=lower(fgetl(fid));
else
   Structure.NCols=0;
end
Loc=findstr(Line,'nrows');
if isequal(size(Loc),[1 1])
   Structure.NRows=sscanf(Line((Loc+5):end),'%i',1);
   Line=lower(fgetl(fid));
else
   Structure.NRows=0;
end
Loc=findstr(Line,'xllcorner');
if isequal(size(Loc),[1 1])
   Structure.XCorner=sscanf(Line((Loc+9):end),'%f',1);
   Line=lower(fgetl(fid));
   Loc=findstr(Line,'yllcorner');
   if isequal(size(Loc),[1 1])
      Structure.YCorner=sscanf(Line((Loc+9):end),'%f',1);
      Line=lower(fgetl(fid));
   else
      Structure.YCorner=0;
   end
else
   Loc=findstr(Line,'xllcentre');
   if isequal(size(Loc),[1 1])
      XCentre=sscanf(Line((Loc+9):end),'%f',1);
      Structure.XCorner='centre';
      Line=lower(fgetl(fid));
   else
      Structure.XCorner=0;
   end
   Loc=findstr(Line,'yllcentre');
   if isequal(size(Loc),[1 1])
      YCentre=sscanf(Line((Loc+9):end),'%f',1);
      Structure.YCorner='centre';
      Line=lower(fgetl(fid));
   else
      Structure.YCorner=0;
   end
end
Loc=findstr(Line,'cellsize');
if isequal(size(Loc),[1 1])
   Structure.CellSize=sscanf(Line((Loc+8):end),'%f',[1 2]);
   if length(Structure.CellSize)==1
      Structure.CellSize=Structure.CellSize([1 1]);
   end
   Line=lower(fgetl(fid));
else
   Structure.CellSize=0;
end
if isequal(Structure.XCorner,'centre')
   Structure.XCorner=XCentre-Structure.CellSize(1)/2;
   Structure.YCorner=YCentre-Structure.CellSize(2)/2;
end
Loc=findstr(Line,'nodata_value'); % both nodata_value and NODATA_value occur
if isequal(size(Loc),[1 1])
   Structure.NoData=sscanf(Line((Loc+12):end),'%f',1);
else
   Structure.NoData=NaN;
end
Structure.DataStart=ftell(fid);
%
% End of normal reading of header. Now, let's check whether we have opened
% a wind or pressure file of Delft3D which may include multiple data fields
% separated by time stamps. This check is performed by skipping all comment
% lines and scanning for a line stating "TIME (HRS)" ...
%
Line=fgetl(fid);
Time=[];
while strmatch('/*',Line)
   Structure.DataStart=ftell(fid);
   if isempty(Time)
      Time=sscanf(lower(Line),'/* time (hrs) %f',1);
   end
   Line=fgetl(fid);
end
Times=Time;
%
% If I did find such a line, I have to scan the whole file for similar
% lines ...
%
if ~isempty(Time)
   Time=[];
   while ~feof(fid)
      LineStartsAt=ftell(fid);
      Line=fgetl(fid);
      if length(Line)>2 & strcmp(Line(1:2),'/*') & isempty(Time)
         Time=sscanf(lower(Line),'/* time (hrs) %f',1);
      elseif ~isempty(Time)
         Structure.DataStart(end+1,1)=LineStartsAt;
         Times(end+1,1)=Time;
         Time=[];
      end
   end
end
%
% File reading finished. Close file and do some final checks ...
%
fclose(fid);
if Structure.NCols<=0
   error('Number of columns not specified or invalid')
elseif Structure.NRows<=0
   error('Number of rows not specified or invalid')
elseif Structure.CellSize<=0
   error('Cell size not specified or invalid')
end
Structure.Check='OK';
if ~isempty(Times)
   Structure.Times=Times;
   %
   Structure.FileBase=[p filesep n];
   lwc=Structure.Extension-upper(Structure.Extension);
   switch lower(Structure.Extension)
      case 'amu'
         amv=char('AMV'+lwc);
         fid=fopen([Structure.FileBase '.' amv],'r');
         if fid>0
            Structure.Extension=char('AMUV'+lwc([1:3 3]));
         end
         fclose(fid);
      case 'amv'
         amu=char('AMU'+lwc);
         fid=fopen([Structure.FileBase '.' amu],'r');
         if fid>0
            Structure.Extension=char('AMUV'+lwc([1:3 3]));
         end
         fclose(fid);
   end
   %
   return
end
Structure.Times=[];
%
% on unix systems assume that all extensions have the same case
% (upper/lower characters) in the same place.
%
switch lower(Structure.Extension)
   case {'amu','amv','amh','amz','amc'}
      digits=n(end-2:end);
      if all(abs(digits)>47 & abs(digits)<58)
         Structure.FileBase=[p filesep n(1:end-3)];
         
         Files=dir([Structure.FileBase '*.' Structure.Extension]);
         Files=str2mat(Files.name); % cannot be empty, should find this file
         Files=Files(:,end+(-6:-4));
         Structure.Times=sort((Files-48)*[100;10;1]);
      end
end
lwc=Structure.Extension-upper(Structure.Extension);
if strcmp(lower(Structure.Extension),'amu')
   amv=char('AMV'+lwc);
   Files=dir([Structure.FileBase '*.' amv]);
   if ~isempty(Files)
      Files=str2mat(Files.name); % cannot be empty, should find this file
      Files=Files(:,end+(-6:-4));
      Times=sort((Files-48)*[100;10;1]);
      if isequal(Times,Structure.Times)
         Structure.Extension=char('AMUV'+lwc([1:3 3]));
      end
   end
elseif strcmp(lower(Structure.Extension),'amv')
   amu=char('AMU'+lwc);
   Files=dir([Structure.FileBase '*.' amu]);
   if ~isempty(Files)
      Files=str2mat(Files.name); % cannot be empty, should find this file
      Files=Files(:,end+(-6:-4));
      Times=sort((Files-48)*[100;10;1]);
      if isequal(Times,Structure.Times)
         Structure.Extension=char('AMUV'+lwc([1:3 3]));
      end
   end
end


function Structure=Local_read_file(filename,nr)
if (nargin==0)
   filename='';
   Structure=Local_open_file;
elseif ischar(filename)
   Structure=Local_open_file(filename);
else
   Structure=filename;
   if isfield(Structure,'Data'),
      Structure=Structure.Data;
      return
   end
end
if strcmp(Structure.Check,'NotOK')
   if isstruct(filename)
      Structure=[];
   end
   return
end

ext=3;
if strcmp(lower(Structure.Extension),'amuv')
   ext=[3 4];
end
for i=ext
   fil=Structure.FileName;
   subnr=1;
   if nargin>1 & length(Structure.DataStart)==1
      fil=[Structure.FileBase sprintf('%3.3i',Structure.Times(nr)) '.' Structure.Extension([1 2 i])];
   elseif nargin>1
      subnr=nr;
      fil=[Structure.FileBase '.' Structure.Extension([1 2 i])];
   end
   fid=fopen(fil,'r');
   fseek(fid,Structure.DataStart(subnr),-1);
   
   Structure.Check='NotOK';
   [Data,NumRead]=fscanf(fid,'%f',[Structure.NCols Structure.NRows]);
   if NumRead<(Structure.NCols*Structure.NRows)
      if feof(fid)
         fclose(fid);
         error(sprintf('Insufficient data values found in the file: %s.',Structure.FileName));
      end
      X=char(fread(fid,1,'uchar'));
      if isequal(X,'*')
         fseek(fid,Structure.DataStart,-1);
         fprintf(1,'Trying to read file as free formatted.\n');
         Data=Local_read_freeformat(fid,[Structure.NCols Structure.NRows]);
         Structure.FreeFormat=1;
      else
         fclose(fid);
         fprintf(1,['Unexpected character ''' X ''' encountered.\n']);
         error(sprintf('Not all data values could be read from %s.',Structure.FileName));
      end
   else
      [X,More]=fscanf(fid,'%f',1);
      if More
         fprintf(1,'File seems to contain more data values than indicated in header.\n');
      end
   end
   
   if ~isnan(Structure.NoData)
      Data(Data==Structure.NoData)=NaN;
   end
   if i==3
      Structure.Data=Data;
   else
      Structure.Data2=Data;
   end
   fclose(fid);
   Structure.Check='OK';
end
if isstruct(filename)
   if isequal(ext,3)
      Structure={Structure.Data};
   else
      Structure={Structure.Data Structure.Data2};
   end
end


function Local_write_file(Structure,filename)

if nargin==1
   [fn,fp]=uiputfile('*.arc');
   if ~ischar(fn)
      return
   end
   filename=[fp fn];
end
fid=fopen(filename,'wt');
if fid<0
   error(['Could not create or open: ',filename])
end
fprintf(fid,'/* arc grid file created by Matlab\n');
fprintf(fid,'ncols         %i\n',Structure.NCols);
fprintf(fid,'nrows         %i\n',Structure.NRows);
fprintf(fid,'xllcorner     %f\n',Structure.XCorner);
fprintf(fid,'yllcorner     %f\n',Structure.YCorner);
if length(Structure.CellSize)==1
   fprintf(fid,'cellsize      %f\n',Structure.CellSize);
elseif Structure.CellSize(1)==Structure.CellSize(2)
   fprintf(fid,'cellsize      %f\n',Structure.CellSize(1));
else
   fprintf(fid,'cellsize      %f %f\n',Structure.CellSize(1:2));
end
Data=Structure.Data;

if ~isnan(Structure.NoData)
   fprintf(fid,'nodata_value  %f\n',Structure.NoData);
   Data(isnan(Data))=Structure.NoData;
end

FormatString=[repmat(' %f',[1 Structure.NCols]) '\n'];
fprintf(fid,FormatString,Data);
fclose(fid);


function Resampled=Local_resample_file(Structure,StepSize)
Resampled=[];
if nargin<2
   try
      StepSize=stdinputdlg('step size','Question',1,{num2str(1)});
   catch
      StepSize=inputdlg('step size','Question',1,{num2str(1)});
   end
   if isempty(StepSize)
      return
   end
   StepSize=str2num(StepSize{1});
end
if ~isequal(size(StepSize),[1 1]) | ~isfinite(StepSize) | ...
      StepSize~=round(StepSize) | StepSize<0 | ...
      StepSize>min(Structure.NRows,Structure.NCols)
   return
end

Resampled=Structure;

ColsSticks=1:StepSize:Structure.NCols+1;
RowsSticks=1:StepSize:Structure.NRows+1;
if ColsSticks(end)~=Structure.NCols+1
   ColsSticks = cat(2,ColsSticks,Structure.NCols+1);
end
if RowsSticks(end)~=Structure.NRows+1
   RowsSticks = cat(2,RowsSticks,Structure.NRows+1);
end

if isfield(Structure,'Data')
   Data = Structure.Data;
else
   Data = Local_read_file(Structure);
   Data = Data{1};
end
if StepSize~=1
   % take average data ...
   nRS = length(RowsSticks);
   nCS = length(ColsSticks);
   %
   plotData = repmat(NaN,nCS-1,nRS-1);
   for c=1:nCS-1
      for r=1:nRS-1
         subData = Data(ColsSticks(c):ColsSticks(c+1)-1,RowsSticks(r):RowsSticks(r+1)-1);
         Mask = ~isnan(subData);
         NPnt = sum(Mask(:));
         if NPnt>0
            plotData(c,r)=sum(subData(Mask))/NPnt;
         end
      end
   end
else
   plotData = Data;
end
Resampled.Data = plotData;
Resampled.NRows = size(plotData,2);
Resampled.NCols = size(plotData,1);
Resampled.CellSize = StepSize * Resampled.CellSize;


function H=Local_plot_file(Structure,Axes,StepSize)
H=[];
if nargin<3
   try
      StepSize=stdinputdlg('step size','Question',1,{num2str(1)});
   catch
      StepSize=inputdlg('step size','Question',1,{num2str(1)});
   end
   if isempty(StepSize)
      return
   end
   StepSize=str2num(StepSize{1});
end
if ~isequal(size(StepSize),[1 1]) | ~isfinite(StepSize) | ...
      StepSize~=round(StepSize) | StepSize<0 | ...
      StepSize>min(Structure.NRows,Structure.NCols)
   return
end

if nargin<2
   Axes=gca;
   view(0,90);
end

ColsSticks=1:StepSize:Structure.NCols+1;
RowsSticks=1:StepSize:Structure.NRows+1;
if ColsSticks(end)~=Structure.NCols+1
   ColsSticks = cat(2,ColsSticks,Structure.NCols+1);
end
if RowsSticks(end)~=Structure.NRows+1
   RowsSticks = cat(2,RowsSticks,Structure.NRows+1);
end

x=Structure.XCorner+(ColsSticks-1)*Structure.CellSize(1);
y=Structure.YCorner+(Structure.NRows+1)*Structure.CellSize(2)-RowsSticks*Structure.CellSize(2);

if isfield(Structure,'Data')
   Data = Structure.Data;
else
   Data = Local_read_file(Structure);
   Data = Data{1};
end
if StepSize~=1
   % take average data and ...
   % transpose data for plotting
   nRS = length(RowsSticks);
   nCS = length(ColsSticks);
   %
   plotData = repmat(NaN,nRS-1,nCS-1);
   for c=1:nCS-1
      for r=1:nRS-1
         subData = Data(ColsSticks(c):ColsSticks(c+1)-1,RowsSticks(r):RowsSticks(r+1)-1);
         Mask = ~isnan(subData);
         NPnt = sum(Mask(:));
         if NPnt>0
            plotData(r,c)=sum(subData(Mask))/NPnt;
         end
      end
   end
   % z data
   zData = repmat(NaN,nRS,nCS);
   for c=1:nCS
      for r=1:nRS
         %
         % Determine z level at corner points based on original data
         %
         c1 = max(ColsSticks(c)-1,1);
         c2 = min(ColsSticks(c),Structure.NCols);
         r1 = max(RowsSticks(r)-1,1);
         r2 = min(RowsSticks(r),Structure.NRows);
         subData = Data(c1:c2,r1:r2);
         Mask = ~isnan(subData);
         NPnt = sum(Mask(:));
         if NPnt>0
            zData(r,c)=sum(subData(Mask))/NPnt;
         else
            %
            % However, if the corner point lies far from the actual data,
            % the point may be missing data. In that case use the data from
            % the coarse plotData set.
            %
            c1 = max(c-1,1);
            c2 = min(c,nCS-1);
            r1 = max(r-1,1);
            r2 = min(r,nRS-1);
            subData = plotData(r1:r2,c1:c2);
            Mask = ~isnan(subData);
            NPnt = sum(Mask(:));
            if NPnt>0
               zData(r,c)=sum(subData(Mask))/NPnt;
            end
         end
      end
   end
else
   % transpose data for plotting
   plotData = transpose(Data);
   Mask = isnan(plotData);
   masked_pD = plotData;
   masked_pD(Mask) = 0;
   %
   zData = masked_pD([1:end end],[1:end end]) + ...
           masked_pD([1 1:end],[1:end end]) + ...
           masked_pD([1:end end],[1 1:end]) + ...
           masked_pD([1 1:end],[1 1:end]);
   zMask = Mask([1:end end],[1:end end]) + ...
           Mask([1 1:end],[1:end end]) + ...
           Mask([1:end end],[1 1:end]) + ...
           Mask([1 1:end],[1 1:end]);
   zMask = 4 - zMask;
   zData = zData./max(zMask,1);
   zData(zMask==0) = NaN;
end
H=surface(x,y,zData,plotData,'parent',Axes,'edgecolor','none');
set(Axes,'dataaspectratio',[1 1 1]);


function [Data,NextValue]=Local_read_freeformat(fid,Size)
Data=repmat(NaN,Size);
NextValue=1;
while ~feof(fid)
   Line=fgetl(fid);
   Line=strrep(Line,',',' ');
   Star=findstr('*',Line);
   NTimes=1;
   for s=1:length(Star)
      if s==1
         X=sscanf(Line(1:(Star(1)-1)),'%f');
      else
         X=sscanf(Line((Star(s-1)+1):(Star(s)-1)),'%f');
      end
      if length(X)==1
         NTimes=X(1);
      else
         Data(NextValue-1+(1:NTimes))=X(1);
         if length(X)>2
            Data(NextValue-1+NTimes+(1:(length(X)-2)))=X(2:(end-1));
         end
         NextValue=NextValue+max(0,length(X)-2)+NTimes;
         NTimes=X(end);
      end
   end
   if isempty(Star)
      X=sscanf(Line,'%f');
   else
      X=sscanf(Line((Star(end)+1):end),'%f');
   end
   Data(NextValue-1+(1:NTimes))=X(1);
   if length(X)>1
      Data(NextValue-1+NTimes+(1:(length(X)-1)))=X(2:end);
   end
   NextValue=NextValue+max(0,length(X)-1)+NTimes;
end
NextValue=NextValue-1;
