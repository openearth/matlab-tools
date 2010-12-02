function xb_plotprofile(varargin)
%XB_PLOTPROFILE  Plot or animate cross shore profiles
%
%   Visualization toolbox for cross shore model results. The function
%   allows users to specify which XBeach output data to read and how to
%   plot them. This function reads XBeach output directly from the source
%   files. The function allows results to be saved as figures or as a
%   movie
%
%   Syntax:
%   xb_plotprofile(varargin)
%
%   Input:
%   Keyword,value pairs:
%     - vars   ::  cell of names of variable to be plotted 
%                  (default {'zb' 'zs' 'H'})
%     - starttime :: index of timestep to start animation (default 0)
%     - stoptime  :: index of timestep to stop animation (default Inf)
%     - colors ::  array of line colors for plotting each variable 
%                  (default ['k','r','g','b','m',...])                
%     - lineweights :: array of line weights for plotting each variable
%                      (default 1)
%     - factor ::  array of multiplication factors for plotting each
%                  variable (default 1)
%     - ylimit ::  ylim for animation (default none)
%     - rownumber :: number of the cross shore row to be plotted (default 2)
%     - stride :: number of time steps to stride during animation (default 1)
%     - pauselength :: period between subsequent frames (default 0.1s)
%     - output :: option to save as pictures ('png') or movie ('avi') or
%                 neither ('none'). Deafult 'none'.
%
%   Example
%   xb_plotprofile('vars',{'zs' 'u' 'ccg'},'factor',[1 1 2650])
%
%   See also 

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
OPT = struct(...
    'vars',{'zb' 'zs' 'H'},...
    'starttime',0,...
    'stoptime',Inf,...
    'colors',['k','r','g','b','m'],...
    'lineweights',1,...
    'factor',1,...
    'ylimit','none',...
    'rownumber',2,...
    'stride',1,...
    'pauselength',0.1,...
    'output','none');

setproperty(OPT,varargin{:});

for i=1:length(OPT.vars)
    eval(['fid',num2str(i),'=fopen(''',OPT.vars{i},'.dat'',''r'');']);
    eval(['if fid',num2str(i),'<0;error(''cannot find ',OPT.vars{i},'.dat'');end']);
end

XBdims=xb_getdimensions;
nt=XBdims.nt;
x=XBdims.x;
y=XBdims.y;

% original profile
fidzb0=fopen('zb.dat','r');
zb0=fread(fidzb0,size(x),'double');
fclose(fidzb0);

if strcmpi(OPT.output,'avi');
    mov = avifile('plotprofile.avi','fps',4,'quality',85);
end

f1=figure;

h0=plot(x(:,row),zb0(:,row),'color','k','linewidth',2,'linestyle','-.');

if ~strcmpi(OPT.ylimit,'none')
    ylim(ylimit);
end

if strcmpi(OPT.output,'avi');
    F=getframe(f1);
    mov = addframe(mov,F);
end

hold on;
for ii=1:length(OPT.vars)
    eval(['var',num2str(ii),'=fac(ii).*fread(fid',num2str(ii),',size(x),''double'');']);
    eval(['h',num2str(ii),'=plot(x(:,row),var',num2str(ii),'(:,row),''color'',''',OPTcolors(ii,:),''',''linewidth'',lw(ii));']);
end
legtext{1}='zb0';
for i=1:length(OPT.vars)
    if fac(i)==1
        legtext{i+1}=OPT.vars{i};
    else
        legtext{i+1}=[OPT.vars{i} ' (x ' num2str(fac(i)) ')'];
    end
end
l=legend(legtext,'location','eastoutside');
if start>2
    progressbar(0);
end
grid on
title('Start');
pause
times = [start:stride:stop];

for i=2:stop
    for ii=1:length(OPT.vars)
        eval(['var',num2str(ii),'=fac(ii).*fread(fid',num2str(ii),',size(x),''double'');']);
    end
    
    
    if any(times==i) %i>=start
        if isempty(pausel)
            show=true;
        else
            if or(pausel>0,i==stop)
                show=true;
            else
                show=false;
            end
        end
        if show
            for ii=1:length(OPT.vars)
                eval(['set(h',num2str(ii),',''YData'',var',num2str(ii),'(:,row));']);
            end
            title(num2str(i));
            if movie
                F=getframe(f1);
                mov = addframe(mov,F);
            end
            if isempty(pausel)
                pause
            else
                pause (pausel);
            end
        end
    elseif i<start
        progressbar(i/(start-1));
    end
end

if movie
    mov=close(mov);
end

fclose all
