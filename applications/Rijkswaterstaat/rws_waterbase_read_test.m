function D = rws_waterbase_read_test(varargin)
%RWS_WATERBASE_READ_TEST   test script for DONAR_READ
%
%   donar_read_test(<filename>)
%
% Loads and timeseries data in filename.
%
%See also: DONAR_READ

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

MTestCategory.DataAccess;

   OPT.baseurl  = 'http://live.waterbase.nl';

D = [];
if TeamCity.running, TeamCity.ignore('Test requires user input'); return; end

%% get filename
if nargin==0
[fname, pathname, filterindex] = uigetfile( ...
   {['*.txt', 'text files from ',OPT.baseurl,' (*.txt)']; ...
     '*.*'  , 'All Files                         (*.*)'}, ...
    [OPT.baseurl,' text file']);
   F = fullfile(pathname,fname);
else
   F = varargin{1};
end

%% load
D = rws_waterbase_read(F)

%% plot
plot    (D.data.datenum,D.data.waarde)
ylabel  ([D.data.waarnemingssoort,' [',D.data.units,']'])
grid     on
datetick('x')
