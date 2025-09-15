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
%Create ini waterdepth structure

function ini_waterdepth=floris_to_fm_ini_h(varargin)

%% PARSE
parin=inputParser;

addOptional(parin,'ini_waterdepth_constant',3)

parse(parin,varargin{:})

ini_waterdepth_constant=parin.Results.ini_waterdepth_constant; 

%% CALC

ini_waterdepth.General.fileVersion='2.00';
ini_waterdepth.General.fileType='1dField';

ini_waterdepth.Global0.quantity='WaterDepth';
ini_waterdepth.Global0.unit='m';
ini_waterdepth.Global0.value=ini_waterdepth_constant;

end %function