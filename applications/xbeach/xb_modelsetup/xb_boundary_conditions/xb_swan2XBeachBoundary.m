function xb_swan2XBeachBoundary(fname,varargin)
%XB_SWAN2XBEACHBOUNDARY  convert Swan output for use in XBeach
%
%   This function converts non-stationary or multiple time step SWAN 2D
%   spectra files (.sp2) into a series of single time step SWAN output files and
%   a FILELIST file for use with XBeach (using instat = swan). This 
%   function does not interpolate the SWAN data in time.
%
%   Syntax:
%   xb_swan2XBeachBoundary(fname,varargin)
%
%   Input:   fname    - Name of SWAN 2D spectra time series file
%                       No default.
%
%   Optional input, in the form of keyword,value pairs
%          starttime  - Start reading SWAN spectra from this time onwards, 
%                       as specified in the SWAN simulation.
%                       If starttime does not correspond to a specific
%                       spectral output time, the first spectrum to be read
%                       will be the first spectrum beyond starttime in
%                       time. starttime should be specified in Matlab
%                       numerical time, i.e. 
%                       starttime=datenum('2000-02-25 15:00','yyyy-mm-dd HH:MM')
%                       Default = -Inf.
%          stoptime   - Stop reading SWAN spectra from this time onwards.
%                       If stoptime corresponds to a specific
%                       spectral output time, the spectrum at stoptime will
%                       be included in the XBeach boundary condition.
%                       stoptime should be specified in Matlab numerical
%                       time, i.e.
%                       starttime=datenum('2000-02-28 11:00','yyyy-mm-dd HH:MM').
%                       Default = Inf
%          step       - Step through spectra from starttime to stoptime
%                       with stepsize = step. Step = 1 means all SWAN
%                       spectra are converted to XBeach spectra. Step = 2
%                       means every second SWAN spectrum is converted. Step
%                       = 3 means every third spectrum is converted, etc.
%                       Default = 1
%          dtbc       - Required dtbc for XBeach (in seconds), see XBeach 
%                       manual. Default = 2.
%
%   Output:  - swanlist.txt file containing the list of SWAN files required
%              for XBeach, including the values of rt and dtbc
%            - one swan *.sp2 file for each spectrum needed for XBeach
%
%   Example
%   xb_swan2XBeachBoundary('c:\swan\run1\output1.sp2','step',2);
%
%   See also 
%   swan, swan_io_spectrum
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl
%
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
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
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

% Default values
OPT = struct(...
    'starttime',-Inf,...
    'stoptime',Inf,...
    'step',1,...
    'dtbc',2);

setProperty(OPT,varargin{:});

% Check file length
fid=fopen(fname,'r');
fseek(fid, 0, 'eof');
filesize = ftell(fid);
frewind(fid);

% Make empty containers
headerstr={};
varstr={};

% Collect header data
hd=1;
count=0;
nfreqreached=0;
while hd==1
    count=count+1;
    line=fgetl(fid);
    if nfreqreached==1
        endnum=findstr(line,'number');
        nfreq=str2num(line(1:endnum-1));
        nfreqreached=0;
    end
    if ~isempty(findstr(line,'FREQ'));
        nfreqreached=1;
    end
    if ~isempty(findstr(line,'exception value'));
        hd=0;
    end
    headerstr{count}=line;
end

% Collect spectra data
count=0;
countf=0;
startno=0;
stopno=0;
indexXB=0;
fpos = ftell(fid);
while fpos<filesize
    count=count+1;
    date=fgetl(fid);
    factorstr=fgetl(fid);
    factornum=fgetl(fid);
    for j=1:nfreq
        vdstr{j}=fgetl(fid);
    end
    
    % Check to see if time >= OPT.starttime
    if (datenum(date(1:15),'yyyymmdd.HHMMSS')>=OPT.starttime && countf==0)
        indexXB=count:OPT.step:filesize;
    end
    
    % Check to see if time > OPT.stoptime
    if (datenum(date(1:15),'yyyymmdd.HHMMSS')>OPT.stoptime)
        break
    end
    
    % Check to see if this sepctrum should be included in XBeach
    if any(indexXB==count)
        countf=countf+1;
        fnameif=['swan2d_' strtrim(date(1:15)) '.sp2'];
        fnlist{countf}=fnameif;
        datemat(countf)=datenum(date(1:15),'yyyymmdd.HHMMSS');
        if countf==1
            datemat0=datemat(1);
        end
        datemat(countf)=(datemat(countf)-datemat0)*24*3600;
                
        fidif=fopen(fnameif,'w');
        
        for hdi=1:length(headerstr)
            fprintf(fidif,'%s\n',headerstr{hdi});
        end
        fprintf(fidif,'%s\n',date);
        fprintf(fidif,'%s\n',factorstr);
        fprintf(fidif,'%s\n',factornum);
        for vdi=1:nfreq
            fprintf(fidif,'%s\n',vdstr{vdi});
        end
        fclose(fidif);
    end
    fpos = ftell(fid);
end
    
% Write XBeach boundary condition list file   
fidl=fopen('swanlist.txt','w');
fprintf(fidl,'%s\n','FILELIST');
for i=1:countf
    if i<countf
        fprintf(fidl,'% 14.2f % 5.2f %s\n',datemat(i+1)-datemat(i),OPT.dtbd,fnlist{i});
    else
        fprintf(fidl,'% 14.2f % 5.2f %s\n',datemat(i)-datemat(i-1),OPT.dtbd,fnlist{i});
    end
end
fclose(fidl);
fclose(fid);
