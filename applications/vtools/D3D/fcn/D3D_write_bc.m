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
    
    fprintf(fid,'[forcing] \n');
    if any(contains(bc(kbc).quantity,'lateral'))||any(contains(bc(kbc).quantity,'qhtable')) %at a point
        %ATTENTION! this is not robust enough. I am not sure it works well for all cases.
        fprintf(fid,'Name                            = %s \n',bc(kbc).name);
    else %along pli
        fprintf(fid,'Name                            = %s_0001 \n',bc(kbc).name);
    end
    fprintf(fid,'Function                        = %s \n',bc(kbc).function);
    if isfield(bc(kbc),'time_interpolation') 
        fprintf(fid,'Time-interpolation              = %s \n',bc(kbc).time_interpolation);
    end
    for kq=1:nq-1
        fprintf(fid,'Quantity                        = %s \n',bc(kbc).quantity{kq});
        fprintf(fid,'Unit                            = %s \n',bc(kbc).unit{kq});
    end
    for kq=nq
        fprintf(fid,'Quantity                        = %s \n',bc(kbc).quantity{kq});
        fprintf(fid,'Unit                            = %s \n',bc(kbc).unit{kq});
    end    
    if iscell(bc(kbc).val)
        for kl = 1:size(bc(kbc).val)
            fprintf(fid,'%s %f %f\n', bc(kbc).val{kl,1:end});
        end
    else
        %`writematrix` was implemented by WO because it is faster, but AK found that it does
        %not add space delimiter properly when number of digits increases along the column dimension. 
        for kl = 1:size(bc(kbc).val,1)
            fprintf(fid, '%.6f %.6f\n', bc(kbc).val(kl,:));
        end
    end
end %kbc

fclose(fid);
% messageOut(NaN,sprintf('File created: %s',fpath))

end %function