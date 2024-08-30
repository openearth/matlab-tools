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
%Convert (sediment) fractions from cumulative to mean grain size.
%
%INPUT:
%   -cum = cumulative fractions [nx,ns]
%   -dsieve = sieve sizes [1,ns];
%
%OUTPUT:
%   -dg = mean grain size 

function dg=cumulative_to_dg(cum,dsieve,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type',1);

parse(parin,varargin{:});

%% CALC

[bin,dk]=cumulative_to_bin(cum,dsieve);

in_m.mdv.nx=size(bin,1);
in_m.sed.dk=dk;
in_m.tra.Dm=parin.Results.type;

dg=mean_grain_size(bin',in_m)';

end
