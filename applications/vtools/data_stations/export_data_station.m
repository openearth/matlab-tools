%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19676 $
%$Date: 2024-06-17 21:37:30 +0200 (Mon, 17 Jun 2024) $
%$Author: chavarri $
%$Id: fig_his_sal_01.m 19676 2024-06-17 19:37:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_his_sal_01.m $
%

function export_data_station(fpath_csv,data)

%get existing fields in data
fields_add_all=fieldnames(data);

%get indices of fields to add to header (i.e., all but `time` and `waarde`)
idx_header=find(~contains(fields_add_all,{'time','waarde'}));
fields_header=fields_add_all(idx_header);
nheader=numel(fields_header);

fid=fopen(fpath_csv,'w');

%header
for kh=1:nheader
    fn_loc=fields_header{kh};
    val=data.(fn_loc);
    if ischar(val)
        fprintf(fid,'%25s: %s \r\n',fn_loc,val);
    elseif isnumeric(val)
        fprintf(fid,'%25s: %f \r\n',fn_loc,val);
    end
end

%data
nv=numel(data.time);
for kv=1:nv
    if ~isnat(data.time(kv))
        fprintf(fid,'%s, %f \r\n',datestr(data.time(kv),'yyyy-mm-dd HH:MM:SS'),data.waarde(kv));
    end
end
fclose(fid);

end %function