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
%After creating the grid based on the cross-section information, the offset
%of the computational flow nodes changes, as a link is added upstream to
%link branches. Here the offset is corrected. 

function csl=floris_to_fm_adapt_offset(network,csl,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% UNPACK

mesh1d_node_offset=network.mesh1d_node_offset;

%% CALC

csl=struct_assign_val(csl,'chainage',mesh1d_node_offset);

end %function