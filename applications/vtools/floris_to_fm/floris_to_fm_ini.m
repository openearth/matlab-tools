%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create ini structure

function ini=floris_to_fm_ini(fname_ini_waterdepth)

ini.General.fileVersion='2.00';
ini.General.fileType='iniField';

ini.Initial0.quantity='waterdepth';
ini.Initial0.dataFile=fname_ini_waterdepth;
ini.Initial0.dataFileType='1dField';

end %function