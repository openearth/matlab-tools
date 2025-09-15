%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20303 $
%$Date: 2025-08-28 11:32:58 +0200 (Thu, 28 Aug 2025) $
%$Author: chavarri $
%$Id: floris_to_fm_read_floin.m 20303 2025-08-28 09:32:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/floris_to_fm/floris_to_fm_read_floin.m $
%
%Create ini structure

function ini=floris_to_fm_ini(fname_ini_waterdepth)

ini.General.fileVersion='2.00';
ini.General.fileType='iniField';

ini.Initial0.quantity='waterdepth';
ini.Initial0.dataFile=fname_ini_waterdepth;
ini.Initial0.dataFileType='1dField';

end %function