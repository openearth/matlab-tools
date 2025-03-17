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

[~,~,fext]=fileparts(fpath_csv);

switch fext
    case '.csv'
        export_csv(fpath_csv,data,fields_header);
    case '.nc'
        export_nc(fpath_csv,data,fields_header);
end


end %function

%%
%% FUNCTIONS
%%

%%

function export_csv(fpath_csv,data,fields_header)

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

%%

function export_nc(filename,data,fields_header)

nheader=numel(fields_header);
nt=numel(data.time);

ncid=netcdf.create(filename,'CLOBBER');

tim=seconds(data.time-data.time(1));
str_time=char(data.time(1),'dd-MM-yyyyy HH:mm:ss.SSS');
tz=data.time.TimeZone;

% Define dimensions
t_dim=netcdf.defDim(ncid,'time',nt);

% Define variables
t_var=netcdf.defVar(ncid,'time','NC_FLOAT',t_dim);
netcdf.putAtt(ncid,t_var,'units',sprintf('seconds since %s %s',str_time,tz));
netcdf.putAtt(ncid,t_var,'long_name','time');

v_var=netcdf.defVar(ncid,data.grootheid,'NC_FLOAT',t_dim);
netcdf.putAtt(ncid,v_var,'units',data.eenheid);

% Add attributes
for kheader=1:nheader
    val=data.(fields_header{kheader});
    if ~iscell(val)
        netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),fields_header{kheader},data.(fields_header{kheader}));
    end
end

% End define mode
netcdf.endDef(ncid);

% Write data
netcdf.putVar(ncid,t_var,tim);
netcdf.putVar(ncid,v_var,data.waarde);

% Close file
netcdf.close(ncid);

messageOut(NaN,sprintf('file written: %s',filename));

end %function