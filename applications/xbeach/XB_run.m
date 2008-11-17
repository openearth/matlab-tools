function [runflag runtime msg] = XB_run(inpfile, exepath, varargin)
% XB_RUN runs xbeach calculation
%
% Routine calls "xbeach.exe" (by default; another exefile can be specified
% with keyword-value pairs) within the exepath, using inpfile as input for
% the run.
%
% See also CreateEmptyXBeachVar XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$ 
% $Date$
% $Author$
% $Revision$

%% input file
getdefaults('inpfile', fullfile(cd, 'params.txt'), 0);

if ~exist(inpfile, 'file')
    error('XB_RUN:NoInpfileFound', ['No inputfile "' inpfile '" found.'])
end
[inpath fname fext] = fileparts(which(inpfile));
inpfile = fullfile(inpath, [fname fext]);

%% name of executable
OPT = struct(...
    'exefile', 'xbeach.exe');

OPT = setProperty(OPT, varargin{:});

%% path of executable
getdefaults('exepath', fileparts(inpfile), 0);

if ~exist(fullfile(exepath, 'xbeach.exe'), 'file')
    error('XB_RUN:NoExecutableFound', ['"' OPT.exefile '" not found.'])
end

msg = '';

% if nargin<2 || ~ischar(exepath)
%     %% get default exepath
%     if exist('exepath','var') && iscell(exepath)
%         try
%             year = exepath{3};
%             month = exepath{2};
%             day = exepath{1};
%             DateVector = [year month day 0 0 0];
%             exepath = [fileparts(mfilename('fullpath')),filesep,'xbeach_' datestr(DateVector, 'yyyy_mm_dd') '_exe'];
%             if ~exist(exepath,'dir')
%                 error('exepath is not a directory');
%             end
%         catch
%             exepath = [];
%             disp('Exe path could not be found. Newest version is used.');
%         end
%     end
%     if exist('exepath','var') && isnumeric(exepath) && ~isempty(exepath)
%         id = exepath;
%         exepath = [];
%     end
%     if ~exist('exepath','var') || isempty(exepath) || (ischar(exepath) && ~isdir(exepath))
%         files = dir([fileparts(mfilename('fullpath')),filesep, 'xbeach*']);
%         exedirs = {files([files.isdir]).name}';
%         if ~exist('id','var')
%             id = length(exedirs);
%         end
%         exepath = [fileparts(mfilename('fullpath')),filesep,exedirs{id}];
%     end
% end

%% derive date of xbeach.exe and create message
exeinfo = dir(fullfile(exepath, OPT.exefile));
try %#ok<TRYNC>
    msg = sprintf('Version: %s\n', datestr(exeinfo.datenum, 'yyyy-mmm-dd'));
end


cdtemp = cd;
if ~strcmp(inpath, cd)
    % params.txt is in another path, run it from there
    cd(inpath);
end

%% read expected number of timesteps from params.txt
fid = fopen(inpfile, 'r');
strtext = fread(fid, '*char')';
searchstr = {'morstart' 'tint' 'tstop'};
for i = 1:length(searchstr)
    strbgn = findstr(strtext, searchstr{i});
    strend = min(findstr2afterstr1(strtext, searchstr{i}, char(10)))-1;
    evalstr = [strtext(strbgn:strend) ';'];
    eval(evalstr);
end
fclose(fid);
Nrtimesteps = length(morstart:tint:tstop);

%% make sure that dims.dat is created as output
DIMSisoutput = ~isempty(findstr(strtext, 'dims'));
if ~DIMSisoutput
    strbgn = findstr(strtext, 'nglobalvar');
    strend = min(findstr2afterstr1(strtext, 'nglobalvar', char(10)))-1;
    evalstr = [strtext(strbgn:strend) ';'];
    eval(evalstr);
    nglobalvar = nglobalvar + 1; %#ok<NODEF>
    nglobalvarstr = sprintf('%s %g\n', evalstr(1:findstr(evalstr, '=') + 1), nglobalvar);
    strtext = sprintf('%s', strtext(1:strbgn-1), nglobalvarstr, 'dims', strtext(strend+1:end));
    fid = fopen(inpfile, 'w');
    fprintf(fid, '%s', strtext);
    fclose(fid);
end

tic
system(['"' exepath filesep 'xbeach.exe" ' '"' fname fext '"']);
runtime = toc;

%% read actual number of timesteps from dims.dat
dimsfile = 'dims.dat';
if exist(dimsfile, 'file')
    fid = fopen(dimsfile,'r');
    temp = fread(fid,[3,1],'double');
    nt = temp(1);
    fclose(fid);
else
    nt = NaN; % will result in runflag = false
    msg = sprintf('%s%s\n', msg, 'dims.dat not found.');
end

%% set runflag and create message
if Nrtimesteps == nt
    runflag = true;
    msg = sprintf('%sRun successfully completed: %s', msg, datestr(now));
else
    runflag = false;
    if ~isnan(nt)
        msg = sprintf('%sit %i of %i completed: %s', msg, nt, Nrtimesteps, datestr(now));
    end
end

cd(cdtemp);