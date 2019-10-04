function boundary=nest2_dflowfm_in_dflowfm(hisfile,admfile,refdate,varargin)

boundary=[];
extfile=[];
zcor=0;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'boundary'}
                boundary=varargin{ii+1};
            case{'extfile'}
                extfile=varargin{ii+1};
            case{'zcor'}
                zcor=varargin{ii+1};
        end
    end                
end

% Read admin file
xml=xml2struct(admfile,'structuretype','supershort');

nb=length(xml.boundary);

% Read times
tim=nc_varget(hisfile,'time');
units=nc_attget(hisfile,'time','units');
t0=datenum(units(15:end),'yyyy-mm-dd HH:MM:SS');
tim=t0+tim/86400;

% Read stations
stat=nc_varget(hisfile,'station_name');
nstat=size(stat,1);
for istat=1:nstat
    stations{istat}=deblank2(stat(istat,:));
end

% Read all water level time series
wl=nc_varget(hisfile,'waterlevel');

for ib=1:nb    
    
    np=length(xml.boundary(ib).node);

    % Read times
    for ip=1:np
        istat=strmatch(lower(xml.boundary(ib).node(ip).obspoint.name),lower(stations),'exact');
        val=squeeze(wl(:,istat));
        boundary(ib).nodes(ip).timeseries.time=tim;
        boundary(ib).nodes(ip).timeseries.value=val+zcor;
    end
    
end

% % Save bc files
% for ib=1:nb    
%     
%     np=length(xml.boundary(ib).node);
% 
%     v=zeros(length(tim),np+1);
%     v(:,1)=(tim-refdate)*1440;
%     for ip=1:np
%         v(:,ip+1)=boundary(ib).node(ip).timeseries.value;
%     end
%     
%     fmt=['%10.2f' repmat('%10.3f',[1 np]) '\n'];
%     fname=boundary(ib).bcfile;
%     fid=fopen(fname,'wt');
%     for it=1:length(tim)
%         fprintf(fid,fmt,v(it,:));
%     end
%     fclose(fid);
%     
% end

% Save bc files
for ib=1:nb
    
    np=length(xml.boundary(ib).node);
    
    %     v=zeros(length(tim),np+1);
    %     v(:,1)=(tim-refdate)*1440;
    boundary(ib).forcingfile='ncar.bc';
    fname=boundary(ib).forcingfile;
    fid=fopen(fname,'wt');
    
    for ip=1:np
        
        fprintf(fid,'%s\n','[forcing]');
        fprintf(fid,'%s\n',['Name                            = ' boundary(ib).name '_' num2str(ip,'%0.4i') ]);
        fprintf(fid,'%s\n','Function                        = timeseries');
        fprintf(fid,'%s\n','Time-interpolation              = linear');
        fprintf(fid,'%s\n','Quantity                        = time');
        fprintf(fid,'%s\n',['Unit                            = seconds since ' datestr(refdate,'yyyy-mm-dd HHMMSS')]);
        fprintf(fid,'%s\n','Quantity                        = waterlevelbnd');
        fprintf(fid,'%s\n','Unit                            = m');
        for it=1:length(tim)
            fprintf(fid,'%12.1f %10.3f\n',(tim(it)-refdate)*86400,boundary(ib).nodes(ip).timeseries.value(it));
        end
    end
    
    fclose(fid);

end
