function variables = xb_read_dat(fname, varargin)
%XB_READ_DAT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   variables = xb_read_dat(fname, varargin)
%   fname = directory name that contains the dat files.
%
%   Input:
%   varargin  = variables, timestepindex
%
%   Output:
%   variables = structure containing variables
%
%   Example
%   variables = xb_read_output('outputdir')
%   assert(ismember({variables.name},  'xw'})
%   variables = xb_read_output('outputdir', 'variables', {'yw','zs'},
%   timestepindex, 100}
%   assert(~ismember({variables.name},  'xw'})
%
%   See also xb_read_output, xb_read_nc

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Cursus Laptop
%
%       <EMAIL>	
%
%       <ADDRESS>
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



%%

variables = xb_empty();

options=[' 3Dwave';' 3Dsed ';' 3Dbed ';' 4Dbed '];

XBdims = xb_read_dims(fname);

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

names=dir([fname filesep '*.dat']);
% for (i=1:length(names))
%    variables.data(i).name = names(i).name(1:length(names(i).name)-4);
% end


for (i=1:length(names))
    % First open file
    varname = names(i).name(1:length(names(i).name)-4);
    filename = [varname '.dat'];
    fullfilename = fullfile(fname, filename);
    fid=fopen(fullfile(fname, filename),'r');
    temp=fread(fid,'double');
    fclose(fid);
    sz=length(temp)/(XBdims.nx+1)/(XBdims.ny+1)/nt;

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
    if exist('dims','var')
        if strcmpi(dims,'2D')
            [Var info]=read2Dout(fullfilename,XBdims);
        elseif strcmpi(dims,'3Dwave')
            [Var info]=readwaves(fullfilename,XBdims);
        elseif strcmpi(dims,'3Dbed')
            [Var info]=readbedlayers(fullfilename,XBdims);
        elseif strcmpi(dims,'3Dsed')
            [Var info]=readsediment(fullfilename,XBdims);
        elseif strcmpi(dims,'4Dbed')
            [Var info]=readgraindist(fullfilename,XBdims);
        else
            error(['Unknown dims type: ',dims]);
        end
    else
        % user does not know dims type
        if sz>max(XBdims.ntheta,XBdims.nd*XBdims.ngd)
            warning('Function will return values as though 2D array, but could not determine dims type with certainty');
            Var=read2Dout(fullfilename,XBdims);
        else
            % Probably 2D array
            if sz==1
                %display('Assuming array is 2D');
                [Var info]=read2Dout(fullfilename,XBdims);
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
                            [Var info]=readwaves(fullfilename,XBdims);
                        case 2
                            display('Assuming array is 3Dbed');
                            [Var info]=readbedlayers(fullfilename,XBdims);
                        case 3
                            display('Assuming array is 3Dsed');
                            [Var info]=readsediment(fullfilename,XBdims);
                        case 4
                            display('Assuming array is 4Dbed');
                            [Var info]=readgraindist(fullfilename,XBdims);
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
    variables = xb_set(variables, varname, Var);
end

% set meta data
variables = xb_meta(variables, mfilename, 'output', fname);

%%
function [Var info]=read2Dout(fullfilename,XBdims)
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


nodims=2;

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
    type='integer';
else
    type='double';
end
          
fid=fopen(fullfilename,'r');
switch type
    case'double'
        switch nodims
            case 2
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
                for i=1:nt
                    Var(:,:,i)=fread(fid,size(XBdims.x),'double');
                end
                info=['x ' 'y ' 't '];
            case 3
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
            case 4
                Var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
                for i=1:nt
                    for ii=1:XBdims.ngd
                        for iii=1:XBdims.nd
                            Var(:,:,iii,ii,i)=fread(fid,size(XBdims.x),'double');
                        end
                    end
                end
                info=['x   ' 'y   ' 'nd  ' 'ngd ' 't   '];
        end
    case 'integer'
        switch nodims
            case 2
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
                for i=1:nt
                    Var(:,:,i)=fread(fid,size(XBdims.x),'int');
                end
                info=['x ' 'y ' 't '];
            case 3
                Var=zeros(XBdims.nx+1,XBdims.ny+1,nt);
            case 4
                Var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
                for i=1:nt
                    for ii=1:XBdims.ngd
                        for iii=1:XBdims.nd
                            Var(:,:,iii,ii,i)=fread(fid,size(XBdims.x),'int');
                        end
                    end
                end
                info=['x   ' 'y   ' 'nd  ' 'ngd ' 't   '];
        end
end

fclose(fid);

%%
function [bedlayers info]=readbedlayers(fullfilename,XBdims)
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

bedlayers=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,nt);
info=['x  ' 'y  ' 'nd ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for jj=1:XBdims.nd
        bedlayers(:,:,jj,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
    end
end

fclose(fid);


%%
function [graindis info]=readgraindist(fullfilename,XBdims)
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

graindis=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.nd,XBdims.ngd,nt);
info=['x  ' 'y  ' 'nd ' 'ngd' '  t'];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ngd
        for jj=1:XBdims.nd
            graindis(:,:,jj,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
        end
    end
end

fclose(fid);


%%
function Pointdata=readpoint(fullfilename,XBdims,nvar)
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

Pointdata=zeros(XBdims.ntp,nvar+1);
fid=fopen(fullfilename,'r');
for i=1:XBdims.ntp
    Pointdata(i,:)=fread(fid,nvar+1,'double');
end
fclose(fid);

%%
function [sed info]=readsediment(fullfilename,XBdims)
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

sed=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.ngd,nt);
info=['x  ' 'y  ' 'ngd ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ngd
        sed(:,:,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
    end
end

fclose(fid);

%%
function [var info]=readwaves(fullfilename,XBdims)
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

var=zeros(XBdims.nx+1,XBdims.ny+1,XBdims.ngd,nt);
info=['x  ' 'y  ' 'ntheta ' 't  '];

fid=fopen(fullfilename,'r');

for i=1:nt
    for ii=1:XBdims.ntheta
        var(:,:,ii,i)=fread(fid,[XBdims.nx+1,XBdims.ny+1],'double');
    end
end

fclose(fid);
%%
