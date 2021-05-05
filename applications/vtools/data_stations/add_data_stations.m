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

function add_data_stations(paths,tim_add,val_add,tok_add)

%get available data
[data_one_station,idx]=read_data_stations(paths,tok_add{:});

if ~isempty(data_one_station)
    
    if numel(data_one_station)>1
        error('Be more specific, there are several data sets for these tokens.')
    end
    
    %combine
    tim_ex=data_one_station.time;
    val_ex=data_one_station.waarde;
    
    tim_tot=cat(1,tim_ex,reshape(tim_add,[],1));
    val_tot=cat(1,val_ex,reshape(val_add,[],1));
    
    [tim_tot,idx_s]=sort(tim_tot);
    val_tot=val_tot(idx_s);
    
    %write
    data_one_station.time=tim_tot;
    data_one_station.waarde=val_tot;
    
    fname=fullfile(paths.separate,sprintf('%06d.mat',idx));
    save(fname,'data_one_station')
    messageOut(NaN,sprintf('data added to file %s',fname));
else
    %write new value and add to index
    error('do')
end