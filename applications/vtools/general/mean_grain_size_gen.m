%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17724 $
%$Date: 2022-02-03 06:41:30 +0100 (Thu, 03 Feb 2022) $
%$Author: chavarri $
%$Id: function_layout.m 17724 2022-02-03 05:41:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/function_layout.m $
%
%Compute mean grain size 
%
%INPUT:
%
%
%OPTIONAL:
%   -type: 1=geometric (2^); 2=arithmetic (sum)
%   
%OUTPUT:
%

function Dm=mean_grain_size_gen(dk,Fak,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type',1);

parse(parin,varargin{:});

%% CALL

input_i.tra.Dm=parin.Results.type;
input_i.sed.dk=dk;
input_i.mdv.nx=1;

Dm=mean_grain_size(Fak,input_i,NaN);

end %function