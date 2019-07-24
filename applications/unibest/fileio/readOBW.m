function OBWdata = readOBW(filename)
%OBWdata = readOBW(filename)
%Writes a unibest breakwater file
%
%   Syntax:
%     function readOBW(filename)
% 
%   Input:
%     filename             string with output filename
%  
%   Output:
%     OBWdata              structure per breakwater (OBW(1), OBW(2), OBW(i), etc)
%           .filename             string with output filename
%           .Xw                   x values for each breakwater ([Nx2] matrix in meters)
%           .Yw                   x values for each breakwater ([Nx2] matrix in meters)
%           .local                index for type of local rays (0= no local rays, 1=local rays, 2 to 5=local diffraction; with local 2 and 3 being )
% 
%           if local rays are used ('local') : 
%           .xlocal              [Nx1] with x,y coordinates of local rays [m] for considered breakwater
%           .ylocal              [Nx1] with x,y coordinates of local rays [m] for considered breakwater
%           .rayfiles            cellstring with local ray filenames for considered breakwater
% 
%           if local diffraction is used ('local2' and 'local3') : 
%           .scofiles            cellstring with local ray filenames for considered breakwater
%           .profiles            cellstring with local ray filenames for considered breakwater
%           .cfsfiles            cellstring with local ray filenames for considered breakwater
%           .cfefiles            cellstring with local ray filenames for considered breakwater
%           .dform               cellstring with local ray filenames for considered breakwater
%           .hactive             hactive       
%           .smax0               smax0         
% 
%           if wave transmission is also computed ('local4' and 'local5') :
%           .depth               depth         
%           .crestwidth          crestwidth    
%           .crestheight         crestheight   
%           .beachslope          beachslope    
%
%   Example:
%     OBWdata = readOBW('test.obw')
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readOBW.m 10866 2014-06-19 08:20:42Z huism_b $
% $Date: 2014-06-19 10:20:42 +0200 (Thu, 19 Jun 2014) $
% $Author: huism_b $
% $Revision: 10866 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readOBW.m $
% $Keywords: $

%-----------Read data of breakwaters------------
%-------------------------------------------
if ~exist(filename,'file')
    fprintf('Error : Filename for breakwater not found!\n');
    return
end
    
OBWdata=struct;
fid = fopen(filename,'rt');
line1 = fgetl(fid);
line2 = fgetl(fid);
number_of_breakwaters = str2double(line2);

for ii=1:number_of_breakwaters
    line3 = fgetl(fid);
    line4 = fgetl(fid);
    [OBWdata(ii).Xw(1),OBWdata(ii).Yw(1),OBWdata(ii).Xw(2),OBWdata(ii).Yw(2)] = strread(line4,'%f %f %f %f','delimiter',' ');
    
    line5 = fgetl(fid);
    if ~isempty(strfind(lower(line5),'end'))
        OBWdata(ii).local=0; 
    elseif ~isempty(strfind(lower(line5),'local2'))
        OBWdata(ii).local=2; 
    else ~isempty(strfind(lower(line5),'local'))
        OBWdata(ii).local=1; 
    end
    
    while isempty(strfind(lower(line5),'end'));
        if ~isempty(strfind(lower(line5),'local2')) || ...
           ~isempty(strfind(lower(line5),'local3'))
            %'LOCAL3'
	    %NUMBER OF TRANSPORT POINTS
	    % 2
	    %  Xw          Yw      .SCO    .PRO     .CFS      .CFE      dform   h0 Smax0
	    %3500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis' 5  0
            %6500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis' 5  0
            line6 = fgetl(fid);
            line7 = fgetl(fid); number_of_rays = str2double(line7);
            line8 = fgetl(fid);
            for iii=1:number_of_rays
                line9 = fgetl(fid);
                [OBWdata(ii).xlocal(iii,1),OBWdata(ii).ylocal(iii,1), ...
                    scofile,profile,cfsfile,cfefile,dform,hactive,smax0] = ... 
                    strread(line9,'%f %f %s %s %s %s %s %f %f','delimiter',' ');
                OBWdata(ii).rayfiles{iii}    = '';
                OBWdata(ii).scofiles{iii}    = regexprep(scofile,'''','');
                OBWdata(ii).profiles{iii}    = regexprep(profile,'''','');
                OBWdata(ii).cfsfiles{iii}    = regexprep(cfsfile,'''','');
                OBWdata(ii).cfefiles{iii}    = regexprep(cfefile,'''','');
                OBWdata(ii).dform{iii}       = regexprep(dform,'''','');
                OBWdata(ii).hactive(iii)     = hactive;    
                OBWdata(ii).smax0(iii)       = smax0;                 
            end
            
        elseif ~isempty(strfind(lower(line5),'local4')) || ...
               ~isempty(strfind(lower(line5),'local5'))
            %'LOCAL5'
	    %NUMBER OF TRANSPORT POINTS
	    % 2
	    %  Xw          Yw      .SCO    .PRO     .CFS      .CFE      dform   h0 Smax0 Depth  Cw      Ch        slope
	    %3500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis' 5  0     4      19     -0.25     200
            %6500.00      50.00   'LOC03' 'RECHT' 'DEFAULT' 'DEFAULT' 'kamphuis' 5  0     4      19     -0.25     200
            line6 = fgetl(fid);
            line7 = fgetl(fid); number_of_rays = str2double(line7);
            line8 = fgetl(fid);
            for iii=1:number_of_rays
                line9 = fgetl(fid);
                [OBWdata(ii).xlocal(iii,1),OBWdata(ii).ylocal(iii,1), ...
                    scofile,profile,cfsfile,cfefile,dform, ...
                    hactive,smax0,depth,crestwidth,crestheight,beachslope] = ... 
                    strread(line9,'%f %f %s %s %s %s %s %f %f %f %f %f %f','delimiter',' ');
                OBWdata(ii).rayfiles{iii}    = '';
                OBWdata(ii).scofiles{iii}    = regexprep(scofile,'''','');
                OBWdata(ii).profiles{iii}    = regexprep(profile,'''','');
                OBWdata(ii).cfsfiles{iii}    = regexprep(cfsfile,'''','');
                OBWdata(ii).cfefiles{iii}    = regexprep(cfefile,'''','');
                OBWdata(ii).dform{iii}       = regexprep(dform,'''','');
                OBWdata(ii).hactive(iii)     = hactive;    
                OBWdata(ii).smax0(iii)       = smax0;      
                OBWdata(ii).depth(iii)       = depth;      
                OBWdata(ii).crestwidth(iii)  = crestwidth; 
                OBWdata(ii).crestheight(iii) = crestheight;
                OBWdata(ii).beachslope(iii)  = beachslope; 
            end 
        
        else ~isempty(strfind(lower(line5),'local'))
            %'LOCAL'
	    %NUMBER OF TRANSPORT POINTS
	    % 3
	    %  Xw          Yw      .RAY
	    %3500.00      50.00   'LOC01'
	    %4500.00      50.00   'LOC02'
	    %5500.00      50.00   'LOC03'
            line6 = fgetl(fid);
            line7 = fgetl(fid); number_of_rays = str2double(line7);
            line8 = fgetl(fid);
            for iii=1:number_of_rays
                line9 = fgetl(fid);
                [OBWdata(ii).xlocal(iii,1),OBWdata(ii).ylocal(iii,1),rayfile] = strread(line9,'%f %f %s','delimiter',' ');
                if strcmpi(rayfile(1),'''')
                   rayfile=rayfile(2:end);
                end
                if strcmpi(rayfile(end),'''')
                   rayfile=rayfile(1:end-1);
                end
                OBWdata(ii).ray_files{iii}=rayfile;
            end
        end
        line5 = fgetl(fid);
    end
end
fclose(fid);
