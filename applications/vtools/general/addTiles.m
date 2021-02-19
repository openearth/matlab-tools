%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_figure_2D.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_figure_2D.m $
%
%add tiles to figure

function addTiles(path_tiles,unitx,unity)

%% RENAME 

%% ADD

load(path_tiles,'tiles')
[nx,ny,~]=size(tiles);
for kx=1:nx
    for ky=1:ny
         surf(tiles{kx,ky,1}.*unitx,tiles{kx,ky,2}.*unity,zeros(size(tiles{kx,ky,2})),tiles{kx,ky,3},'EdgeColor','none')
    end
end
