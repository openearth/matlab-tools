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