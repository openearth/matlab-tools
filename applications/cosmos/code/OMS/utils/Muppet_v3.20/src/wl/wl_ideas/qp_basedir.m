function p=qp_basedir(t)
%QP_BASEDIR Get various base directories.
%
%   PATH=QP_BASEDIR(TYPE)
%   where TYPE=
%      'base' returns base directory of installation (default).
%      'exe'  returns directory of executable.
%      'pref' returns preference directory of installation.

%   Copyright 2000-2008 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

if nargin==0
    t='base';
elseif ~ischar(t)
    error('Invalid input argument.');
end
t=lower(t);
if isstandalone
    p=matlabroot;
    switch t
        case 'exe'
            % do nothing
        case 'pref'
            p=qp_prefdir;
        otherwise
            slash=findstr(p,filesep);
            p=p(1:(slash(end-1)-1));
    end
else
    p=which('d3d_qp');
    if ~isempty(p)
        slash=findstr(p,filesep);
        p=p(1:(slash(end)-1));
    end
    switch t
        case 'exe'
            % nothing
        case 'pref'
            p=qp_prefdir;
        otherwise
            % nothing
    end
end


%=======================
function dd = qp_prefdir
%QP_PREFDIR Preference directory name (adaptation of MATLAB's prefdir).
c = computer;
if c(1:2) == 'PC'
    % Try %UserProfile% first. This is defined by NT
    dd = getenv('UserProfile');
    if isempty(dd)
        % Try the windows registry next. Win95/98 uses this
        % if User Profiles are turned on (you can check this
        % in the "Passwords" control panel).
        dd = get_profile_dir;
        if isempty(dd)
            % This must be Win95/98 with user profiles off.
            dd = getenv('windir');
        end
    end
    dd = fullfile(dd, 'Application Data', 'Deltares', '');
else % Unix
    dd = fullfile(getenv('HOME'), '.Deltares', '');
end
curd=pwd;
try
    ensure_directory(dd);
catch
    dd='';
end
cd(curd);
%TODO: Shift to Deltares directory


function ensure_directory(dirname)
if ~exist(dirname, 'dir')
    [parent, thisdir, ext] = fileparts(dirname);
    thisdir = [thisdir ext];
    ensure_directory(parent);
    cd(parent)
    c = computer;
    if c(1:2) == 'PC'
        s=dos(['mkdir "',thisdir,'"']);
    else
        s=unix(['mkdir -p ',thisdir]);
    end
end


function profileDir = get_profile_dir
le = lasterr;
try
    profileDir = winqueryreg('HKEY_CURRENT_USER',...
        'Software\Microsoft\Windows\CurrentVersion\ProfileReconciliation',...
        'ProfileDirectory');
catch
    lasterr(le);
    profileDir = '';
end
