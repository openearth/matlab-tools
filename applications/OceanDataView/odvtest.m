%ODVTEST   script to test ODVRREAD, ODVDISP, ODVPLOT
%
% plots all CTDCAST files in a directory one by one.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: ODVREAD, ODVDISP, ODVPLOT

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL
% $Keywords:

OPT.directory = 'F:\checkouts\OpenEarthTools\matlab\applications\OceanDataView\usergd30d98-data_centre630-260409_result\';
OPT.prefix    = 'result_CTDCAST';
OPT.mask      = '*.txt';
OPT.files     = dir([OPT.directory,filesep,OPT.prefix,'*',OPT.mask])

for ifile=1:length(OPT.files)

    OPT.filename = OPT.files(ifile).name;

    D = odvread([OPT.directory,filesep,OPT.filename]);
    
    odvdisp(D)

    odvplot(D)
    
    pausedisp
       
end % ifile       