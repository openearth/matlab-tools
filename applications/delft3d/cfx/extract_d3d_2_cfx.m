function varargout = extract_d3d_2_cfx(filmap,varargin)

% extract_d3d_2_cfx extracts water level and velocity datat from a trim file
%                   writes to csv file that can be used bi\y cfx
%
% Syntax:
%         extract_d3d_2_cfx(trimfile,<keyword>,<value>), or,
%  data = extract_d3d_2_cfx(trimfile,<keyword>,<value>)
% Input:
%   trimfile = name of the Delft3D-Flow map file
%
% Implemented <keyword>/<value> pairs:
%   Time   =  either the integer time step number
%             or, the real matlab time,
%             or, a date/time string ('yyyymmdd  HHMMSS')
%             default (not specified) first time step on file
%   Range  =  a 2x2 matrix giving the range to be extracted ([m1,n1;m2,n2])
%             default (not specified) [1,mmax;1,nmax]
%   Filcsv =  name of csv file to write results to
%             if not specified the function returns the matrix written to file
%
% Examples:
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time','20030320 000000','Range',[80,100;90,110],'Filcsv','tst.csv')
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time',23               ,'Range',[80,100;90,110],'Filcsv','tst.csv')
%   extract_d3d_2_cfx('trim-3d_001_neap.dat','Time',731660.00        ,'Range',[80,100;90,110],'Filcsv','tst.csv')
%   data = extract_d3d_2_cfx('trim-3d_001_neap.dat','Time','20030320 000000','Range',[80,100;90,110])
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
%
%       theo.vanderkaaij@deltares.nl
%
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version
%
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/delft3d_trim2ini.m $
% $Keywords: $

%% Open nefis file and extract Fieldnames
File       = qpfopen(filmap);
Fields     = qpread(File);
Fieldnames = {Fields.Name};

%% Read the bed level, use to determine mmax and nmax;
Data       = qpread (File,'bed level in water level points','data',0,0,0);
dep        = Data.Val;

mmax = size(dep,1);
nmax = size(dep,2);

%% Optional arguments
OPT.Range  = [1,mmax;1,nmax];
OPT.Filcsv = '';
OPT.Time   = 1;
OPT        = setproperty(OPT,varargin);

%% Time, integer, timestepnumber, real, matlab time, string datetimestring
if isreal(OPT.Time)|| isstring(OPT.Time)
    if isstring(OPT.Time)
        OPT.Time = datenum(OPT.Time,'yyyymmdd HHMMSS');
    end
    % determine timestepnumber
    times = qpread(File,'water level','times');
    times = (abs(times - OPT.Time));
    [~,OPT.Time] = min(times);
end

%% Read Velocity data
if ~isempty( find(strcmp('velocity',Fieldnames) == 1))
    % 3D simulation
    Data = qpread (File,'velocity','griddata',OPT.Time,0,0);
    kmax = size(Data.X,3);
else
    % 2Dh simulation
    Data = qpread (File,'depth averaged velocity','griddata',OPT.Time,0,0);
    kmax = 1;
end

%% Extract coordinates
x_coor = Data.X;
y_coor = Data.Y;
if kmax > 1 z_coor = Data.Z; end

%% Extract velocities
u_vel   = Data.XComp;
v_vel   = Data.YComp;
if kmax > 1 w_vel   = Data.ZComp; end

%% Read the water levels;
Data       = qpread (File,'water level','data',OPT.Time,0,0);
s1         = Data.Val;

% Fill z_coor and w_vel for dav computation
if kmax == 1
    z_coor               = dep + 0.5*(s1-dep);
    w_vel(1:mmax,1:nmax) = 0.;
end

 %% Fill matrix for writing
 i_tel = 0;
 for k = 0 : kmax + 2
     k_act = kmax - k + 1; % Switch direction
     for m = OPT.Range(1,1): OPT.Range(2,1)
         for n = OPT.Range(1,2): OPT.Range(2,2)
             if ~isnan(x_coor(m,n,1))
                 i_tel = i_tel + 1;
                 % Initialise
                 M(i_tel,1:7) = 0.;
                 % x,y-coordinate
                 M(i_tel,1) = x_coor(m,n,1);
                 M(i_tel,2) = y_coor(m,n,1);
                 % z_coordinate
                 if k == 0
                     % bed
                     M(i_tel,3) = dep(m,n);
                 elseif k<=kmax
                     % computational points
                     M(i_tel,3) = z_coor(m,n,k_act);
                     % velocities for computational points
                     M(i_tel,4) = u_vel(m,n,k_act);
                     M(i_tel,5) = v_vel(m,n,k_act);
                     M(i_tel,6) = w_vel(m,n,k_act);
                 elseif k == kmax + 1
                     % water level
                     M(i_tel,3) = s1(m,n);
                 elseif k == kmax + 2
                     % air
                     M(i_tel,3) = s1(m,n) + 0.001;
                 end
                 % water fraction
                 M(i_tel,7) = 1;
                 if k == kmax + 2 M(i_tel,7) = 0; end
             end
         end
     end
 end

 %% Write the Matrix
 if ~isempty(OPT.Filcsv)
     csvwrite(OPT.Filcsv,M);
 else
     varargout{1} = M;
 end
