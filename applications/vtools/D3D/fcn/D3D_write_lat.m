%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_write_poly.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_write_poly.m $
%
function D3D_write_lat(fpath,lat)

%% RENAME

nlat=numel(lat);

%% CALC
fid=fopen(fpath,'w');

for klat=1:nlat

    % [lateral]
    % Id             = Lopikerwaard
    % Type           = discharge
    % locationType   = 2d
    % numCoordinates = 1
    % xCoordinates   = 123672.0000
    % yCoordinates   = 441333.0000
    % discharge      = ../../boundary_conditions/flow/run010_lateral.bc

    %add to ext file
    fprintf(fid,'[lateral]                                                         \n');
    fprintf(fid,'Id             = %s                                     \n',lat(klat).id);
    fprintf(fid,'Type           = discharge                                        \n');
    fprintf(fid,'locationType   = 2d                                               \n');
    fprintf(fid,'numCoordinates = 1                                                \n');
    fprintf(fid,'xCoordinates   = %f                                      \n',lat(klat).x_coordinates);
    fprintf(fid,'yCoordinates   = %f                                      \n',lat(klat).y_coordinates);
    fprintf(fid,'discharge      = %s                                      \n',lat(klat).discharge);
    
end %kbc

fclose(fid);
messageOut(NaN,sprintf('File created: %s',fpath))
end %function