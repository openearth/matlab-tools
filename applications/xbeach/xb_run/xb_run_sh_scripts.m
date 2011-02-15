function [job_id job_name messages] = xb_run_sh_scripts(rpath, script, varargin)
%XB_RUN_SH_SCRIPTS  Run SH scripts on H4 cluster
%
%   Run SH scripts on H4 cluster
%
%   Syntax:
%   [job_id job_name messages] = xb_run_sh_scripts(rpath, script, varargin)
%
%   Input:
%   rpath     = Path where script is located seen from remote source
%   script    = Name of the script to run
%   varargin  = ssh_host:   Host name of remote computer
%               ssh_user:   Username for remote computer
%               ssh_pass:   Password for remote computer
%               ssh_prompt: Boolean indicating if password prompt should be
%                           used
%
%   Output:
%   job_id    = Job number of process started
%   job_name  = Name of process started
%   messages  = Messages returned by remote source
%
%   Example
%   job_id = xb_run_sh_scripts('~/', 'run.sh', 'ssh_prompt', true)
%
%   See also xb_run_remote, xb_write_sh_scripts

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 15 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'ssh_host', 'h4', ...
    'ssh_user', '', ...
    'ssh_pass', '', ...
    'ssh_prompt', false ...
);

OPT = setproperty(OPT, varargin{:});

%% prompt for password

if OPT.ssh_prompt
    [OPT.ssh_user OPT.ssh_pass] = uilogin;
elseif isempty(OPT.ssh_user) && isempty(OPT.ssh_pass)
    [OPT.ssh_user OPT.ssh_pass] = xb_getpref('ssh_user', 'ssh_pass');
end

if isempty(OPT.ssh_user) && isempty(OPT.ssh_pass)
    error('No username and password found');
end

%% run model

if isunix()
    % use expect to work around ssh password prompt
    cmd = sprintf('expect -c ''spawn ssh %s@%s "dos2unix %s/%s"; expect assword; send "%s\\n"; interact''', ...
        OPT.ssh_user, OPT.ssh_host, rpath, script, OPT.ssh_pass); system(cmd);
    cmd = sprintf('expect -c ''spawn ssh %s@%s "%s/%s"; expect assword; send "%s\\n"; interact''', ...
        OPT.ssh_user, OPT.ssh_host, rpath, script, OPT.ssh_pass);
else
    % use plink for remote command execution
    exe_path = fullfile(fileparts(which(mfilename)), 'plink.exe');
    
    cmd = sprintf('%s %s@%s -pw %s "dos2unix %s/%s && %s/%s"', ...
        exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, script, rpath, script);
end

[retcode messages] = system(cmd);

job_id = 0;
job_name = 0;

% extract job number and name
if retcode == 0
    s = regexp(messages, 'Your job (?<id>\d+) \("(?<name>.+)"\) has been submitted', 'names');

    if ~isempty(s)
        job_id = str2double(s.id);
        job_name = s.name;
    else
        error(['Submitting remote job failed [' cmd ']']);
    end
else
    error(['Submitting remote job failed [' cmd ']']);
end