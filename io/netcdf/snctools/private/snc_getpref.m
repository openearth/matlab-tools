function retval = snc_getpref(group,pref,default)
%SNC_GETPREF As matlab function getpref but Preferences are loaded in persistent variable.
%   GETPREF('GROUP','PREF') returns the value for the preference
%   specified by GROUP and PREF.  It is an error to get a preference
%   that does not exist.
%
%   GROUP labels a related collection of preferences.  You can choose
%   any name that is a legal variable name, and is descriptive enough
%   to be unique, e.g. 'MathWorks_GUIDE_ApplicationPrefs'.
%
%   PREF identifies an individual preference in that group, and
%   must be a legal variable name.
%
%   GETPREF('GROUP','PREF',DEFAULT) returns the current value if the
%   preference specified by GROUP and PREF exists.  Otherwise creates
%   the preference with the specified default value and returns that
%   value.
%
%   GETPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) returns a cell array
%   containing the values for the preferences specified by GROUP and
%   the cell array of preferences.  The return value is the same size as the
%   input cell array.  It is an error if any of the preferences do not
%   exist.
%
%   GETPREF('GROUP',{'PREF1',...'PREFn'},{DEFAULT1,...DEFAULTn})
%   returns a cell array with the current values of the preferences
%   specified by GROUP and the cell array of preference names.  Any
%   preference that does not exist is created with the specified
%   default value and returned.
%
%   GETPREF('GROUP') returns the names and values of all
%   preferences in the GROUP as a structure.
%
%   GETPREF returns all groups and preferences as a structure.
%
%   Preference values are persistent and maintain their values between
%   MATLAB sessions.  Where they are stored is system dependent.
%
%   Example:
%      addpref('mytoolbox','version',1.0)
%      getpref('mytoolbox','version')
%
%   Example:
%      getpref('mytoolbox','version',1.0);
% 
%   See also SETPREF, ADDPREF, RMPREF, ISPREF, UIGETPREF, UISETPREF

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision$
persistent Preferences;
persistent Preffiledatenum;
D = dir(getPrefFile);
if ~isempty(D)
    if ~isequal(Preffiledatenum,D(1).datenum)
        Preferences = prefutils('loadPrefs');
        Preffiledatenum = D(1).datenum;
    end
elseif isempty(Preferences)
    Preferences = prefutils('loadPrefs');
end



% perform all error checks appropriate to number of inputs:
% - group must be a string
% - pref must be a string or cell array
% - default must match pref in size and type
if nargin >= 1

  prefutils('checkGroup',group);

  if nargin == 2
    prefCell = prefutils('checkAndConvertToCellVector',pref);
  elseif nargin == 3
    [prefCell,defaultCell] = prefutils('checkAndConvertToCellVector',pref,default);
  end
end

  
% now produce the desired output:
switch nargin
  
 case 0
  % GETPREF: Return all prefs in all groups:
  retval = Preferences;
 
 case 1
  % GETPREF(GROUP) Return all prefs in this group
  retval = prefutils('getFieldOptional', Preferences, group);
 
 case 2
  % GETPREF(GROUP, PREF) Return this pref; error out if it doesn't exist
  Group = prefutils('getFieldRequired',Preferences,group,...
                    ['group ',group,' does not exist']);
  len = length(prefCell);
  retval = cell(1,len);
  for i=1:len
     retval{i} = prefutils('getFieldRequired',Group,prefCell{i},...
            ['preference ',prefCell{i},' does not exist in group ',group]);
  end
 
 otherwise
  % GETPREF(GROUP, PREF, DEFAULT) Return this pref; set and return
  % default value if it didn't exist:
  Group = prefutils('getFieldOptional',Preferences,group);
  len = length(prefCell);
  retval = cell(1,len);
  for i=1:length(prefCell)
     [retval{i},existed] = prefutils('getFieldOptional',Group,prefCell{i});
     if ~existed
       retval{i} = defaultCell{i};
       addpref(group, prefCell{i}, defaultCell{i});
     end
  end

end % switch

% don't return cell if input was scalar
if nargin >= 2
  if ~iscell(pref)
    retval = retval{1};
  end
end

function varargout = prefutils(varargin)
% PREFUTILS Utilities used by set/get/is/add/rmpref

%   $Revision$  $Date$
%   Copyright 1984-2005 The MathWorks, Inc.


% Switchyard: call the subfunction named by the first input
% argument, passing it the remaning input arguments, and returning
% any return arguments from it.
[varargout{1:nargout}] = feval(varargin{:});


function prefName = truncToMaxLength(prefName)
% This is necessary because SETFIELD/GETFIELD/ISFIELD/RMFIELD do
% not operate the same as dotref and dotassign when it comes to
% variable names longer than 'namelengthmax'.  Dotref/dotassign 
% do an implicit truncation, so both operations appear to work 
% fine with longer names, even though they're really paying 
% attention only to the first 31 characters.  But the *field 
% functions don't do the truncation, so GETFIELD and ISFIELD 
% and RMFIELD report errors when you pass them a longer name that
% you've just used with SETFIELD.  So the suite of pref functions 
% are using truncToMaxLength until that bug is fixed - when it is, 
% just remove this.

prefName = prefName(1:min(end, namelengthmax));


function prefFile = getPrefFile
% return name of preferences file, create pref dir if it does not exist

prefFile = [prefdir(1) filesep 'matlabprefs.mat'];


function Preferences = loadPrefs
% return ALL preferences in the file.  Return empty matrix if file
% doesn't exist, or it is empty.

prefFile = getPrefFile;
Preferences = [];
if exist(prefFile)
  fileContents = load(prefFile);
  if isfield(fileContents, 'Preferences')
    Preferences = fileContents.Preferences;
  end
end


function savePrefs(Preferences)
prefFile = getPrefFile;
save(prefFile, 'Preferences');


function [val, existed_out] = getFieldOptional(s, f)
fMax = truncToMaxLength(f);
existed = isfield(s, fMax);
if existed == 1
  val = s.(fMax);
else
  val = [];
end
if nargout == 2
  existed_out = existed;
end

function val = getFieldRequired(s, f, e)
[val, existed] = getFieldOptional(s, f);
if ~existed
  error(e);
end

function [p_out, v_out] = checkAndConvertToCellVector(pref, value)
% Pref must be a string or cell array of strings.
%   return it as a cell vector.
% Value (if passed in) must be the same length as Pref.
%   return it as a cell vector (only convert it to cell if we
%   converted Pref to cell)

if ischar(pref)
  p_out = {pref};
elseif iscell(pref)
  p_out = {pref{:}};
  for i = 1:length(p_out)
    if ~ischar(p_out{i})
      error('MATLAB:prefutils:InvalidCellArray', 'PREF cell array must contain strings');
    end
  end
else
  error('MATLAB:prefutils:InvalidPREFinput', 'PREF must be a string or cell array of strings');
end

if nargin == 2
  if ischar(pref)
    v_out = {value};
  elseif iscell(value)
    v_out = {value{:}};
  else
    error('MATLAB:prefutils:InvalidValueType', 'VALUE type must match PREF');
  end
  if length(v_out) ~= length(p_out)
    error('MATLAB:prefutils:InvalidValueType', 'VALUE type must match PREF');
  end
end

function checkGroup(group)
% Error out if group is not a string:
if ~ischar(group)
  error('MATLAB:prefutils:InvalidGroupInput', 'GROUP must be a string');
end
