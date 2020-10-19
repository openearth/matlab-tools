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
%meshgrid with node connectivity
%
%NOTES:
%   -for plotting patch:
%   patch('faces',nodes','vertices',[x_m(:),y_m(:)],'FaceVertexCData',vmag_cen,'FaceColor','flat');

function [x_m,y_m,nodes]=meshgridNodes(x_v,y_v)

npmx=numel(x_v);
npmy=numel(y_v);

[x_m,y_m]=meshgrid(x_v,y_v);
    
nel=(npmx-1)*(npmy-1);
nnel=4;
nodes=NaN(nnel,nel);
c1=0;
idx_vert=reshape(1:1:npmx*npmy,npmy,npmx);
for kx=1:npmx-1
    for ky=1:npmy-1
        idx_xl=idx_vert(ky,kx);
        idx_xu=idx_vert(ky,kx+1);
        idx_yl=idx_vert(ky+1,kx);
        idx_yu=idx_vert(ky+1,kx+1);
        c1=c1+1;
        nodes(:,c1)=[idx_xl,idx_xu,idx_yu,idx_yl]; 
    end %ky
end %kx

end