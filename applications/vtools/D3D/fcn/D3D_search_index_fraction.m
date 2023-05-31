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
%

function idx_f=D3D_search_index_fraction(data)

idx_f=D3D_search_index_in_dimension(data,'sedimentFraction');
if isnan(idx_f)
    idx_f=D3D_search_index_in_dimension(data,'nSedTot');
end
if isnan(idx_f)
    error('do not know where to get the fraction index');
end

end %function