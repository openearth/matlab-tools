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