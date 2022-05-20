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
