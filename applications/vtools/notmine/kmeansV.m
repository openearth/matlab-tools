%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19009 $
%$Date: 2023-06-20 07:14:19 +0200 (Tue, 20 Jun 2023) $
%$Author: chavarri $
%$Id: create_mat_measurements_from_shp_01.m 19009 2023-06-20 05:14:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/create_mat_measurements_from_shp_01.m $
%
%This is a wrap around the kmeans version in FileExchange to not
%overlap the version available if one has the statistical toolbox
%available

function [label, mu, energy] = kmeansV(X, m)
[label, mu, energy] = kmeansV(X, m)
end
