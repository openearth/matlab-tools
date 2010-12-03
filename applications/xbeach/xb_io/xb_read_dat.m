function variables = xb_read_dat(readname, varargin)
%XB_READ_DAT  Reads DAT formatted output files from XBeach
%
%   Reads DAT formatted output files from XBeach in the form of an XBeach
%   structure. Specific variables can be requested in the varargin by means
%   of an exact match, dos-like filtering or regular expressions (see
%   xb_filter)
%
%   Syntax:
%   variables = xb_read_dat(readname, varargin)
%
%   Input:
%   readname    = directory name that contains the dat files, or single
%                 .dat file name
%
%   Optional input in keyword,value pairs
%   variables   = string or cell array of strings with name of variable to 
%                 read or regular expression of variables to be read.
%                 Default returns all .dat files in a directory if readname
%                 is a directory, or one .dat file if readname is a file.
%   timestepindex = vector or cell array of vectors of time steps to return
%                   data. If a cell array of vectors, each cell corresponds
%                   to the corresponding variables cell. Default returns
%                   all time steps
%   nocheck     = logical (true/false) to use time saving option for
%                 checking file size (no prescan of datafile). 
%                 If 'nocheck' is used, 'dimension' must be specified.
%   dimension   = string or cell array of strings with the read dimensions
%                 of variables. If a cell array of vectors, each cell corresponds
%                 to the corresponding variables cell. Options are:
%                 '2D', '3Dwave', '3Dsed', '3Dbed' and '4Dbed'.
%                 Default will solve file size automatically, but takes
%                 longer than if the file size is specified. If 'nocheck' is
%                 used, 'dimension' must be specified. 
%   outputtype  = string with type of output format required ('single', or
%                 'double'). Default is 'double'.
%
%   Output:
%   variables   = XBeach structure array
%
%   Example
%   xb = xb_read_dat('.')
%   xb = xb_read_dat('H.dat')
%   xb = xb_read_dat('path_to_model/')
%   xb = xb_read_dat('path_to_model/H.dat')
%   xb = xb_read_dat('.','variables','H')
%   xb = xb_read_dat('.','variables','H*')
%   xb = xb_read_dat('.','variables','/_mean$')
%   xb = xb_read_dat('path_to_model/','variables',{'H', 'u*', '/_min$'})
%
%   See also xb_read_output, xb_read_netcdf, xb_filter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read dat files

% set defaults
OPT = struct(...
    'variables','all',...
    'timestepindex','all',...
    'dimension','unknown',...
    'nocheck',false,...
    'outputtype','double');
OPT = setproperty(OPT,varargin{:});

options=[' 2D    ';' 3Dwave';' 3Dsed ';' 3Dbed ';' 4Dbed '];

% check to stop 3d/4d arrays being completely misread
if OPT.nocheck==true & strcmpi(OPT.dimension,'unknown')
    error(['Please specify dimensions of each file if using memory saving option ',... 
           'e.g. vars=xb_read_dat(''zs.dat'',''nocheck'',true,''dimension'',''2D''). ',...
           'valid dimensions are: ''2D'', ''3Dwave'', ''3Dsed'', ''3Dbed'' and ''4Dbed''']);
    
end

%Now  there are two options, either user inputs a directory and wants all
% or a subset of the *.dat files, or user specified one .dat file and only
% wants that output.

if exist(readname, 'dir')
    dirname = readname;
    filename=dir([dirname filesep '*.dat']);
    filename=struct2cell(filename);
    filename=filename(1,:);
    for i=1:length(filename)           
        if strcmpi(filename{i},'dims.dat')
            count(1)=i;
        elseif strcmpi(filename{i},'xy.dat')
            count(2)=i;
        end
    end
    filename(count)=[];
    if strcmpi(OPT.variables,'all')
        OPT.variables={};
        for i=1:length(filename)
            OPT.variables{i}=filename{i}(1:end-4);
        end
    else
        if ~iscell(OPT.variables)
            OPT.variables={OPT.variables};
        end
        count=zeros(1,length(filename));
        % temporary generate variable names of filenames
        for i=1:length(filename)
            tempnames{i}=filename{i}(1:end-4);
        end 
        pos = 0;
        tempdimensions={};
        temptstep={};
        for i=1:length(OPT.variables)
            results = xb_filter(tempnames,OPT.variables{i});
            count=count+ results;
            if iscell(OPT.dimension)
                for ii=1:sum(results)
                    tempdimensions{end+1}=OPT.dimension{i};
                end
            end
            if iscell(OPT.timestepindex)
                for ii=1:sum(results)
                    temptstep{end+1}=OPT.timestepindex{i};
                end
            end
        end
        if iscell(OPT.dimension)
            OPT.dimension=tempdimensions;
        end
        if iscell(OPT.timestepindex)
            OPT.timestepindex=temptstep;
        end            
        count=max(0,min(count,1));
        filename(~count)=[];
        OPT.variables={};
        for i=1:length(filename)
            OPT.variables{i}=filename{i}(1:end-4);
        end
    end
elseif exist(readname, 'file')
    if ~strcmpi(OPT.variables,'all')
        warning('No need to specify ''variables'' if only reading from one .dat file');
    end
    filename = readname;
    if ~iscell(filename)
        filename={filename};
    end
    dirname = fileparts(which(filename{1}));
    OPT.variables={filename{1}(1:end-4)};
else    
    error(['Input readname ''' readname ''' does not exist as a file or a directory'])
end

% So now we have dirname (string), filename (cell array of strings) and
% OPT.variables (cell array of strings, without ".dat" extension)

variables = xb_empty();

XBdims = xb_read_dims(dirname);

for i=1:length(filename)
    fname=filename{i};
   
    % Determine output time series length in dims.dat
    if (length(fname)>9 && strcmp(fname(end-8:end), '_mean.dat'))
        nt=XBdims.ntm;
    elseif (length(fname)>8 && strcmp(fname(end-7:end), '_max.dat'))
        nt=XBdims.ntm;
    elseif (length(fname)>8 && strcmp(fname(end-7:end), '_min.dat'))
        nt=XBdims.ntm;
    elseif (length(fname)>8 && strcmp(fname(end-7:end), '_var.dat'))
        nt=XBdims.ntm;
    else
        nt=XBdims.nt;
    end
    
    % do we know what dimensions this valiable should have?
    if iscell(OPT.dimension)
        dims=OPT.dimension{i};
    else
        dims=OPT.dimension;
    end
       
    % do we know what timesteps should be read?
    if iscell(OPT.timestepindex)
        tsi=OPT.timestepindex{i};
    else
        tsi=OPT.timestepindex;
    end
    if strcmpi(tsi,'all')
        tsi=1:nt;
    end       
    
    % local copy so if not all time output is needed, less file reading
    % done
    XBdimsnow = XBdims;
    XBdimsnow.nt=min(XBdimsnow.nt,max(tsi));
    XBdimsnow.ntp=min(XBdimsnow.ntp,max(tsi));
    XBdimsnow.ntc=min(XBdimsnow.ntc,max(tsi));
    XBdimsnow.ntm=min(XBdimsnow.ntm,max(tsi));
    
    % First open file
    if ~(OPT.nocheck)
        fullfilename = fullfile(dirname, fname);
        fid=fopen(fullfilename,'r');
        temp=fread(fid,'double');
        fclose(fid);
        % here we do use the "proper" nt to see what size the file is
        sz=length(temp)/(XBdims.nx+1)/(XBdims.ny+1)/nt;
    else
        sz=1;
        fullfilename = fullfile(dirname, fname);
    end
    
    % In case file does not match dims.dat
    if sz>max(XBdims.ntheta,XBdims.nd*XBdims.ngd)
        display('File length is longer than suggested in dims.dat');
        if exist('dims','var')
            display('- data file may be corrupt, or contain data of a previous simulation');
        else
            display('- if simulation is running, retry and specify dims type');
            display('- if simulation is complete, data file may be corrupt, or contain data of a previous simulation');
            display('  please try again with specified dims type');
            display(' ');
            display(' Valid dims types are:');
            display(options(1:end,:));
            display(' ');
        end
    end
    
    % User knows what to specify
    if ~strcmpi(dims,'unknown')
        if strcmpi(dims,'2D')
            [Var info]=read2Dout(fullfilename,XBdimsnow,OPT.outputtype);
        elseif strcmpi(dims,'3Dwave')
            [Var info]=readwaves(fullfilename,XBdimsnow,OPT.outputtype);
        elseif strcmpi(dims,'3Dbed')
            [Var info]=readbedlayers(fullfilename,XBdimsnow,OPT.outputtype);
        elseif strcmpi(dims,'3Dsed')
            [Var info]=readsediment(fullfilename,XBdimsnow,OPT.outputtype);
        elseif strcmpi(dims,'4Dbed')
            [Var info]=readgraindist(fullfilename,XBdimsnow,OPT.outputtype);
        else
            error(['Unknown dimensions type: ',dims]);
        end
    else
        % user does not know dims type
        if sz>max(XBdims.ntheta,XBdims.nd*XBdims.ngd)
            warning('Function will return values as though 2D array, but could not determine dims type with certainty');
            Var=read2Dout(fullfilename,XBdimsnow);
        else
            % Probably 2D array
            if sz==1
                %display('Assuming array is 2D');
                [Var info]=read2Dout(fullfilename,XBdimsnow,OPT.outputtype);
            else
                % more complicated, could be ntheta, or nd or ngd or nd*ngd
                check=zeros(4,1);
                if sz==XBdims.ntheta
                    check(1)=1;
                end
                if sz==XBdims.nd
                    check(2)=1;
                end
                if sz==XBdims.ngd
                    check(3)=1;
                end
                if sz==XBdims.nd*XBdims.ngd
                    check(4)=1;
                end
                % Complies with nothing
                if sum(check)==0
                    warning('File cannot be read, unknown size. Returning unprocessed values');
                    Var=temp;
                    info=['unknown'];
                elseif sum(check)==1
                    ty=find(check==1);
                    switch ty
                        case 1
                            display('Assuming array is 3Dwave');
                            [Var info]=readwaves(fullfilename,XBdimsnow,OPT.outputtype);
                        case 2
                            display('Assuming array is 3Dbed');
                            [Var info]=readbedlayers(fullfilename,XBdimsnow,OPT.outputtype);
                        case 3
                            display('Assuming array is 3Dsed');
                            [Var info]=readsediment(fullfilename,XBdimsnow,OPT.outputtype);
                        case 4
                            display('Assuming array is 4Dbed');
                            [Var info]=readgraindist(fullfilename,XBdimsnow,OPT.outputtype);
                    end
                else
                    display('Variable read is ambiguous');
                    display('Please try one of the following dims:')
                    display(options(check==1,:));
                end
            end
        end
    end
    
    %variables.data(i).value = Var;
    if ndims(Var)==3
        Var = Var(:,:,tsi);
    elseif ndims(Var)==4
        Var = Var(:,:,:,tsi);
    elseif ndims(Var)==5
        Var = Var(:,:,:,:,tsi);
    end
    variables = xb_set(variables, OPT.variables{i}, Var);
end

% set meta data
variables = xb_meta(variables, mfilename, 'output', fname);

%%
function [Var info]=read2Dout(fullfilename,XBdims,type)
% Var=readvar(fullfilename,XBdims,nodims) or
% [Var info]=readvar(fullfilename,XBdims,nodims)
%
% Output Var is XBeach output 3D array
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 't'], where the first dimension in Var is the x-coordinate,
% the second dimension in Var is the y-coordinate and the third dimension in
% Var is the time coordinate (XBdims.nt or XBdims.ntm)
% Input - fullfilename : name of data file to open, e.g. 'zb.dat' or 'u_mean.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - nodims: rank of the variable matrix being read (default = 2)
%
% Created 19-06-2008 : XBeach-group Delft
%
% See also getdimensions, readpoint, readgraindist, readbedlayers,
%          readsediment, readwaves


if (length(fullfilename)>9 && strcmp(fullfilename(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
    nameend=9;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
    nameend=8;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
    nameend=8;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
    nameend=8;
else
    nt=XBdims.nt;
    nameend=4;
end

integernames={'wetz';
    'wetu';
    'wetv';
    'struct';
    'nd';
    'respstruct'};

if any(strcmpi(fullfilename(1:end-nameend),integernames))
    typeread='integer';
else
    typeread='double';
end

fid=fopen(fullfilename,'r');
switch typeread
    case'double'
        Var=zeros(XBdims.nx+1,XBdims.ny+1,nt,type);
        for i=1:nt
            Var(:,:,i)=fread(fid,size(XBdims.x),'double');
            if strcmpi(type,'single')
                Var(:,:,i)=single(Var(:,:,i));
            end
        end
        info=['x ' 'y ' 't '];
        
    case 'integer'
        Var=zeros(XBdims.nx+1,XBdims.ny+1,nt,'int8');
        for i=1:nt
            Var(:,:,i)=fread(fid,size(XBdims.x),'int');
        end
        info=['x ' 'y ' 't '];
end

fclose(fid);

%%
function [bedlayers info]=readbedlayers(fullfilename,XBdims,type)
% Var=readbedlayers(fullfilename,XBdims) or
% [Var info]=readbedlayers(fullfilename,XBdims)
%
% Output Var is XBeach output 4D array with bed layer data
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'nd' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fullfilename : name of data file to open, e.g. 'dzbed.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readgraindist, readsediment,
%          readwaves

if (length(fullfilename)>9 && strcmp(fullfilename(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end

bedlayers=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,nt,type);
info=['x  ' 'y  ' 'nd ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for jj=1:XBdims.nd
        bedlayers(:,:,jj,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
        if strcmpi(type,'single')
            bedlayers(:,:,jj,i)=single(bedlayers(:,:,jj,i));
        end
    end
end

fclose(fid);


%%
function [graindis info]=readgraindist(fullfilename,XBdims,type)
% Var=readgraindis(fullfilename,XBdims) or
% [Var info]=readgraindist(fullfilename,XBdims)
%
% Output Var is XBeach output 5D array with bed composition data
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'nd' 'ngd' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fullfilename : name of data file to open, e.g. 'pbbed.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readbedlayers, readsediment,
%          readwaves

if (length(fullfilename)>9 && strcmp(fullfilename(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end

graindis=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt,type);
info=['x  ' 'y  ' 'nd ' 'ngd' '  t'];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ngd
        for jj=1:XBdims.nd
            graindis(:,:,jj,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
            if strcmpi(type,'single')
                graindis(:,:,jj,ii,i)=single(graindis(:,:,jj,ii,i));
            end
        end
    end
end

fclose(fid);


%%
function Pointdata=readpoint(fullfilename,XBdims,nvar,type)
% Pointdata=readpoint(fullfilename,XBdims,nvar)
%
% Output Point is [ntp,nvar+1] array, where ntp is XBdims.ntp
%                 First column of Pointdata is time
%                 Second and further columns of Pointdata are values of
%                 variables
% Input - fullfilename : name of data file to open, e.g. 'point001.dat' or 'rugau001.dat'
%       - XBdims: dimension data provided by getdimensions function
%       - nvar  : number of variables output at this point location
%
% Created 19-06-2008 : XBeach-group Delft
%
% See also getdimensions, readvar, readgraindist, readbedlayers,
%          readsediment, readwaves

Pointdata=zeros(XBdims.ntp,nvar+1,type);
fid=fopen(fullfilename,'r');
for i=1:XBdims.ntp
    Pointdata(i,:)=fread(fid,nvar+1,'double');
    if strcmpi(type,'single')
        Pointdata(i,:)=single(Pointdata(i,:));
    end
end
fclose(fid);

%%
function [sed info]=readsediment(fullfilename,XBdims,type)
% Var=readsediment(fullfilename,XBdims) or
% [Var info]=readsediment(fullfilename,XBdims)
%
% Output Var is XBeach output 4D array with sediment concentrations and transport data
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'ngd' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fullfilename : name of data file to open, e.g. 'Subg.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readgraindist, readbedlayers,
%          readwaves


if (length(fullfilename)>9 && strcmp(fullfilename(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end

sed=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.ngd,nt,type);
info=['x  ' 'y  ' 'ngd ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ngd
        sed(:,:,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
        if strcmpi(type,'single')
            sed(:,:,ii,i)=single(sed(:,:,ii,i));
        end
    end
end

fclose(fid);

%%
function [var info]=readwaves(fullfilename,XBdims,type)
% Var=readwaves(fullfilename,XBdims) or
% [Var info]=readwaves(fullfilename,XBdims)
%
% Output Var is XBeach output 4D array with wave data per wave bin
% Output info is character array describing the dimensions of Var, i.e.
% info = ['x' 'y' 'ntheta' 't'], where the first dimension in Var is the x-coordinate,
% etc.
% Input - fullfilename : name of data file to open, e.g. 'Subg.dat'
%       - XBdims: dimension data provided by getdimensions function
%
% Created 24-11-2009 : XBeach-group Delft
%
% See also getdimensions, readvar, readpoint, readgraindist, readbedlayers,
%          readsediment


if (length(fullfilename)>9 && strcmp(fullfilename(end-8:end), '_mean.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_max.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_min.dat'))
    nt=XBdims.ntm;
elseif (length(fullfilename)>8 && strcmp(fullfilename(end-7:end), '_var.dat'))
    nt=XBdims.ntm;
else
    nt=XBdims.nt;
end

var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.ngd,nt,type);
info=['x  ' 'y  ' 'ntheta ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ntheta
        var(:,:,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
        if strcmpi(type,'single')
            var(:,:,ii,i)=single(var(:,:,ii,i));
        end
    end
end

fclose(fid);
%%
