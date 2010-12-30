function runs = xb_check_run(xb, varargin)
%XB_CHECK_RUN  Checks whether a run from an XBeach input structure is still running
%
%   Checks whether a run started using either xb_run or xb_run_remote is
%   still running. The check can be repeated using a certain time interval
%   to get a warning once the run is finished.
%
%   Syntax:
%   runs = xb_check_run(xb, varargin)
%
%   Input:
%   xb        = XBeach run structure
%   varargin  = repeat:     boolean flag to determine if the check is
%                           repeated
%               interval:   seconds between checks, if repeated
%
%   Output:
%   runs      = boolean that indicates whether the job is still running
%
%   Example
%   xb_check_run(xb)
%
%   See also xb_run, xb_run_remote

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
% Created: 10 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'repeat', false, ...
    'interval', 60 ...
);

OPT = setproperty(OPT, varargin{:});

%% check run

runs = false;

if xb_exist(xb, 'ssh')
    % remote job
    exe_path = fullfile(fileparts(which(mfilename)), 'plink.exe');
    
    [host user pass id messages] = xb_get(xb, 'ssh.host', 'ssh.user', 'ssh.pass', 'id', 'messages');

    cmd = sprintf('%s %s@%s -pw %s ". /opt/sge/InitSGE && qstat -u %s"', ...
            exe_path, user, host, pass, user);

    [retcode messages] = system(cmd);

    if ~isempty(regexp(messages, ['(^|\n)\s*' num2str(id) '\s'], 'once'))
        runs = true;
    end
elseif xb_exist(xb, 'id')
    % local job
    
    id = xb_get(xb, 'id');
    
    % get current running xbeach instances
    [r tasklist] = system('tasklist /FI "IMAGENAME eq xbeach.exe"');
    if regexp(tasklist, ['xbeach.exe\s+' num2str(id) '\s+'], 'start')
    	runs = true;
    end
end

%% start timer

if OPT.repeat && runs
     t = timer( ...
         'TimerFcn', {@repeatCheck,xb}, ...
         'ExecutionMode', 'fixedDelay', ...
         'Period', OPT.interval ...
     );
 
    start(t);
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function repeatCheck(obj, event, xb)

if ~xb_check_run(xb)
    stop(obj); delete(obj);
    disp([upper(mfilename) ': Job ' xb_get(xb, 'name') ' (' num2str(xb_get(xb, 'id')) ') finished']);
    
    % halleluja
    try
        load handel;
        sound(y,Fs);
    end
end
