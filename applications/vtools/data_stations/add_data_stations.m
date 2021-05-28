%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17248 $
%$Date: 2021-05-01 08:15:23 +0200 (Sat, 01 May 2021) $
%$Author: chavarri $
%$Id: separate_data.m 17248 2021-05-01 06:15:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/separate_data.m $
%

function add_data_stations(paths_main_folder,data_add)

paths=paths_data_stations(paths_main_folder);

%get available data
fields_add_all=fieldnames(data_add);
% naddall=numel(fields_add_all);

idx_add2index=find(~contains(fields_add_all,{'time','waarde'}));
fields_add2index=fields_add_all(idx_add2index);
nadd2i=numel(fields_add2index);

%change this to only grootheid, location clear, ? or deal with doubles?
idx_compare=find(~contains(fields_add_all,{'time','waarde','source','location'}));
fields_add=fields_add_all(idx_compare);
nadd=numel(fields_add);

tok_add=cell(1,nadd*2);
for kadd=1:nadd
    tok_add{1,kadd*2-1}=fields_add{kadd};
    tok_add{1,kadd*2  }=data_add.(fields_add{kadd});
end

[data_one_station,idx]=read_data_stations(paths_main_folder,tok_add{:});

if ~isempty(data_one_station)
    fprintf('Data already available:\n')
    fprintf('Location clear: %s\n',data_one_station.location_clear)
    fprintf('Grootheid: %s\n',data_one_station.grootheid)
    
    in=input('Merge? (0=NO, 1=YES): ');
    if in==0
        return
    end
    if numel(data_one_station)>1
        error('Be more specific, there are several data sets for these tokens.')
    end
    
    %combine
    tim_add=data_add.time;
    val_add=data_add.waarde;
    
    tim_ex=data_one_station.time;
    val_ex=data_one_station.waarde;
    
    tim_tot=cat(1,tim_ex,reshape(tim_add,[],1));
    val_tot=cat(1,val_ex,reshape(val_add,[],1));
    
    data_r=timetable(tim_tot,val_tot);
    data_r=rmmissing(data_r);
    data_r=sortrows(data_r);
    tim_u=unique(data_r.tim_tot);
    data_r=retime(data_r,tim_u,'mean'); 
    
    tim_tot=data_r.tim_tot;
    val_tot=data_r.val_tot;
    
%     [tim_tot,idx_s]=sort(tim_tot);
%     val_tot=val_tot(idx_s);
     
    %write
    data_one_station.time=tim_tot;
    data_one_station.waarde=val_tot;
    
    fname=fullfile(paths.separate,sprintf('%06d.mat',idx));
    save(fname,'data_one_station')
    messageOut(NaN,sprintf('data added to file %s',fname));
else
    in=input('New data. Proceed? (0=NO, 1=YES): ');
    if in==0
        return
    end
    load(paths.data_stations_index,'data_stations_index');
    ns=numel(data_stations_index);
    fnames_index=fieldnames(data_stations_index);
    nfnamesindex=numel(fnames_index);
    for kfnames=1:nfnamesindex
        data_stations_index(ns+1).(fnames_index{kfnames})=[];
    end
    for kadd2i=1:nadd2i
        data_stations_index(ns+1).(fields_add2index{kadd2i})=data_add.(fields_add2index{kadd2i});
    end
    
    %save index
    save(paths.data_stations_index,'data_stations_index');
    
    %save new file
    data_one_station=data_stations_index(ns+1);
    data_one_station.time=data_add.time;
    data_one_station.waarde=data_add.waarde;
    fname_save=fullfile(paths.separate,sprintf('%06d.mat',ns+1));
    save(fname_save,'data_one_station');
    messageOut(NaN,sprintf('New file written: %s',fname_save));
end