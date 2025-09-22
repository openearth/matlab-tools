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