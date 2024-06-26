%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19659 $
%$Date: 2024-06-03 08:02:18 +0200 (Mon, 03 Jun 2024) $
%$Author: chavarri $
%$Id: D3D_create_simulation.m 19659 2024-06-03 06:02:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_create_simulation.m $
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
