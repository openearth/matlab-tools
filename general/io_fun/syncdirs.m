function OPT = syncdirs(source, destination,varargin)
%SYNCDIRS  synchronizes files and folders source directory to destination
%
%   More detailed description goes here.
%
%   Syntax:
%   OPT = syncdirs(source, destination, varargin)
%
%   Input:
%   source      = source directory
%   destination = destination directory
%   varargin    = <keyword>,<value>
%
%   Output:
%   OPT         = structure with applied settings
%
%   Example
%   syncdirs
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 23 May 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.remove_files_from_destination   = false;
OPT.source_dir_excl                 = '';
OPT.source_file_incl                = '.*';
OPT.destination_dir_excl            = '';
OPT.destination_file_incl           = '.*';
OPT.extraBytesForWaitbar            = 40;  % To compensate for the the reduced throughput when copying many small files add some bytes to their size (this is only for the waitbar) 

OPT = setproperty(OPT,varargin{:});

if nargin==0;
    return;
end
%% code

% create destination if it does not exist yet
if ~exist(destination,'dir')
    mkpath(destination);
end

D_srce          = dir2(source,     'dir_excl',OPT.source_dir_excl,     'file_incl',OPT.source_file_incl     );
D_dest          = dir2(destination,'dir_excl',OPT.destination_dir_excl,'file_incl',OPT.destination_file_incl);

% add a field relativepathname to the source files
for ii = 2:length(D_srce)
    D_srce(ii).relativepathname = strrep(D_srce(ii).pathname ,[D_srce(1).pathname D_srce(1).name filesep],'');
end

% add a field relativepathname to the destination files
for ii = 2:length(D_dest)
    D_dest(ii).relativepathname = strrep(D_dest(ii).pathname ,[D_dest(1).pathname D_dest(1).name filesep],'');
end

%% look for existing / outdated / modified files and directories
to_remove = false(size(D_dest));
for ii = 2:length(D_dest)
    remove_file = true;
    % look for equal filename
    tf1    = ismember({D_srce.name},D_dest(ii).name);
    tf1(1) = false;
    if any(tf1)
        % and equal relative path
        tf2 = ismember({D_srce(tf1).relativepathname},D_dest(ii).relativepathname);
        if any(tf2)
            tf1 = find(tf1);
            jj  = tf1 (tf2);
            % discern between directories and files
            if isequal(D_dest(ii).isdir  ,D_srce(jj).isdir  )
                if D_dest(ii).isdir
                    remove_file = false;
                else
                    % for files compare file date...
                    if isequal(D_dest(ii).datenum,D_srce(jj).datenum)
                        % and file size
                        if isequal(D_dest(ii).bytes,D_srce(jj).bytes  )
                            remove_file = false;
                        end
                    end
                end
            end
        end
    end
    if remove_file 
        to_remove(ii) = true;
    else
        D_srce(jj) = [];
    end
end
if OPT.remove_files_from_destination
    delete2(D_dest(to_remove));
end

%% create directory tree
multiWaitbar('Making directories','reset')
dirs_to_make = D_srce([D_srce.isdir]);
for ii = 2:length(dirs_to_make);
    dirname = [D_dest(1).pathname D_dest(1).name filesep dirs_to_make(ii).relativepathname dirs_to_make(ii).name];
    if ~exist(dirname,'dir')
        mkpath(dirname)
    end
    multiWaitbar('Making directories',ii/length(dirs_to_make))
end
multiWaitbar('Making directories','close')

%% copy files
multiWaitbar('Copying files','reset')
file_to_copy  = D_srce(~[D_srce.isdir]);
bytes_to_copy = sum([file_to_copy.bytes] + OPT.extraBytesForWaitbar);
for ii = 2:length(file_to_copy);
    multiWaitbar('Copying files','label',[file_to_copy(ii).relativepathname file_to_copy(ii).name]);
    srcename = [D_srce(1).pathname D_srce(1).name filesep file_to_copy(ii).relativepathname file_to_copy(ii).name];
    destname = [D_dest(1).pathname D_dest(1).name filesep file_to_copy(ii).relativepathname file_to_copy(ii).name];
    copyfile(srcename,destname,'f');
    multiWaitbar('Copying files','increment',(file_to_copy(ii).bytes + OPT.extraBytesForWaitbar) / bytes_to_copy);
end
if OPT.remove_files_from_destination
    label_msg = sprintf('Syncdirs completed, %d files where copied. %d files or folders where removed from destination',length(file_to_copy)-1,sum(to_remove));
else
    label_msg = sprintf('Syncdirs completed, %d files where copied. %d files or folders where found that are not in source.',length(file_to_copy)-1,sum(to_remove));
end
multiWaitbar('Copying files',1,'label',label_msg);
