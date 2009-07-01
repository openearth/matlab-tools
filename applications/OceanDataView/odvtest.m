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

OPT.directory = 'D:\checkouts\OpenEarthRawData\NIOZ\usergd30d98-data_centre630-260409_result\';
OPT.prefix    = 'result_CTDCAST';
OPT.mask      = '*.txt';
OPT.files     = dir([OPT.directory,filesep,OPT.prefix,'*',OPT.mask])

L   = load('m_coasts');
lon = L.ncst(:,1);
lat = L.ncst(:,2);

for ifile=1:length(OPT.files); %239 not all colummns, 264 empty

    OPT.filename = OPT.files(ifile).name;
    
    set(gcf,'name',[num2str(ifile),': ',OPT.filename])

    D = odvread([OPT.directory,filesep,OPT.filename]);
    
   %odvdisp(D)

    if ~(isempty(D.lat) | isnan(D.lat))
    odvplot(D,lon,lat)
    else
    clf
    end
    
    disp(['plotting # ',num2str(ifile,'%0.3d'),', press key to continue'])
    pause
       
end % ifile       