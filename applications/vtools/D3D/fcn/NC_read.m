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
%get data from 1 time step in D3D, output name as in D3D

function out=NC_read(simdef,in)

error('deprecated, call D3D_read')
if isa(simdef.flg.which_p,'double')
    out=NC_read_map(simdef,in);
else
    out=NC_read_his(simdef,in);
end

end %function
        