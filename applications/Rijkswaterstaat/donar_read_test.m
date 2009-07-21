function D = donar_read_test(varargin)
%DONAR_READ_TEST   test script for DONAR_READ
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

%% get filename
if nargin==0
[fname, pathname, filterindex] = uigetfile( ...
   {'*.txt', 'text files from www.waterbase.nl (*.txt)'; ...
    '*.*'  , 'All Files                        (*.*)'}, ...
    'www.waterbase.nl tetx file');
   F = fullfile(pathname,fname);
else
   F = varargin{1};
end

%% load
D = donar_read(F)

%% plot
plot    (D.data.datenum,D.data.waarde)
ylabel  ([D.data.waarnemingssoort,' [',D.data.units,']'])
grid     on
datetick('x')
