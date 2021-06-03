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
function D3D_write_bc(fpath,bc)

%% RENAME

nbc=numel(bc);

%% CALC
fid=fopen(fpath,'w');

for kbc=1:nbc
    
    % [forcing]
    % Name                            = rmm_rivpli_1_hagestein_lek_0001
    % Function                        = timeseries
    % Time-interpolation              = linear
    % Quantity                        = time
    % Unit                            = minutes since 2007-01-01 00:00:00 +01:00
    % Quantity                        = dischargebnd
    % Unit                            = m3/s
    nq=numel(bc(kbc).quantity);
    nt=size(bc(kbc).val,1);
    
    fprintf(fid,'[forcing] \n');
    fprintf(fid,'Name                            = %s_0001 \n',bc(kbc).name);
    fprintf(fid,'Function                        = %s \n',bc(kbc).function);
    fprintf(fid,'Time-interpolation              = %s \n',bc(kbc).time_interpolation);
    for kq=1:nq
        fprintf(fid,'Quantity                        = %s \n',bc(kbc).quantity{kq});
        fprintf(fid,'Unit                            = %s \n',bc(kbc).unit{kq});
    end
    for kt=1:nt
        fprintf(fid,' %f %f \n',bc(kbc).val(kt,:));
    end %kt

end %kbc

fclose(fid);
messageOut(NaN,sprintf('File created: %s',fpath))

end %function