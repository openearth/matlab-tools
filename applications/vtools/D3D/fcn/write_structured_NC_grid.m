%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 10:24:15 +0200 (do, 15 apr 2021) $
%$Author: chavarri $
%$Id: D3D_grd_DHL.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_DHL.m $
%

function write_structured_NC_grid(grdfile,x,y)

[nr,nc]=size(x);

n=reshape(1:length(x(:)),[nr,nc]);

lnk=[[reshape(n(1:nr-1,:), [(nr-1)*nc, 1]), reshape(n(2:nr,:), [(nr-1)*nc, 1])]; ...
    [reshape(n(:,1:nc-1), [nr*(nc-1), 1]), reshape(n(:,2:nc), [nr*(nc-1), 1])]];

%rename
x_v=x(:);
y_v=y(:);
lnk_v=lnk.';

% lnk_x=[x_v(lnk(:,1)),x_v(lnk(:,2))];
% lnk_y=[y_v(lnk(:,1)),y_v(lnk(:,2))];

%% SAVE

dflowfm.writeNet(grdfile,x_v,y_v,lnk_v);

end %function