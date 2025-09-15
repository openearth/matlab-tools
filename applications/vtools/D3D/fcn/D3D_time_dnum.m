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
%Read time in datenum format
%
%double: represent indices of the times to load. I.e., load the results at times [1,5,10];
%NaN = all
%Inf = last

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,in_dtime,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim_type',1);
addOptional(parin,'tol',1);
addOptional(parin,'fdir_mat','');
addOptional(parin,'results_type','map');

parse(parin,varargin{:});

tim_type=parin.Results.tim_type;
tol=parin.Results.tol;
fdir_mat=parin.Results.fdir_mat;
results_type=parin.Results.results_type;

%check if his or map
    %not robust enough I think for when dealing with SMT and D3D4
if ~isfolder(fpath_map) && (contains(fpath_map,'_his') || contains(fpath_map,'trih'))
    results_type='his';
end

switch results_type
    case 'map'
        str_tim='';
    case 'his'
        str_tim='_his';
    otherwise
        error('No idea about the type')
end

fpath_tim_all=fullfile(fdir_mat,sprintf('tim%s.mat',str_tim));

%%

if isa(in_dtime(1),'double') 
    [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_double(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,tol);
elseif isa(in_dtime(1),'datetime') %datetime
    tim_cmp=datenum_tzone(in_dtime);
    [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_dnum(fpath_map,tim_cmp,varargin{:});
    return
else
    error('ups...')
end

end %function

%%
%% FUNCTIONS
%%

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_double(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,tol)

idx_g=NaN; %not needed, but we need to output it

if strcmp(results_type,'his') && tim_type==2
    warning('There is no morphodynamic time in history output. It has been switched to hydrodynamic time.')
    tim_type=1;
end

%% get all results time
[~,~,time_dnum_all,time_dtime_all,time_mor_dnum_all,time_mor_dtime_all,sim_idx_all,time_idx_all]=D3D_time_all(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type);

%% get the requested ones

%all
if any(isnan(in_dtime))  
    %We already have what we want. 
    time_dnum=time_dnum_all;
    time_dtime=time_dtime_all;
    time_mor_dnum=time_mor_dnum_all;
    time_mor_dtime=time_mor_dtime_all;
    sim_idx=sim_idx_all;
    time_idx=time_idx_all;
    return
end

%match each one
ntt=numel(time_dnum_all);
nt=numel(in_dtime);
time_dnum=NaN(nt,1);
time_dtime=NaT(nt,1);
time_dtime.TimeZone='+00:00';
time_mor_dnum=NaN(nt,1);
time_mor_dtime=NaT(nt,1);
time_mor_dtime.TimeZone='+00:00';
sim_idx=NaN(nt,1);
time_idx=NaN(nt,1);
for kt=1:nt
    if isinf(in_dtime(kt)) %last
        idx_g=ntt;
    elseif mod(in_dtime(kt),1)==0 && in_dtime(kt)<=ntt %if integer and smaller than total number of results, you are specifying index
        idx_g=in_dtime(kt);
        if ntt>datenum(1687,07,05) %if there are more than 
            messageOut(NaN,'I supposed the input was an index but the number of results is huge, so maybe you want datenum?') %create a flag to force datenum
        end
    else %datenum
        if tim_type==1 %hydro time
            tim_cmp=time_dnum_all;
        elseif tim_type==2 %morpho time
            tim_cmp=time_mor_dnum_all;
        else
            error('You should not reach this point.')
        end
        if isnan(tim_cmp)
            error('Problem with time') %wanted morpho time?
        end
        idx_g=absmintol(tim_cmp,in_dtime(kt),'tol',tol,'dnum',1);
    end

    time_dnum(kt,1)=time_dnum_all(idx_g);
    time_dtime(kt,1)=time_dtime_all(idx_g);
    time_mor_dnum(kt,1)=time_mor_dnum_all(idx_g);
    time_mor_dtime(kt,1)=time_mor_dtime_all(idx_g);
    sim_idx(kt,1)=sim_idx_all(idx_g);
    time_idx(kt,1)=time_idx_all(idx_g);
end %kt

end %function

%%

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_get_all_results(fpath_tim_all,fpath_map,results_type)

if isfolder(fpath_map) %SMT
    [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_results_time_wrap(fpath_map,results_type);
else
    is_mor=D3D_is(fpath_map);
    [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map,is_mor,[1,Inf]);
    sim_idx=NaN(size(time_r));
    time_idx=(1:1:numel(time_r))';
end
data=v2struct(time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx);
save_check(fpath_tim_all,'data')

end %function

%% 

function new_all_time_needed=D3D_time_check_if_new_all_time_needed_data(data,in_dtime,fpath_map,results_type,tim_type)

new_all_time_needed=false;

%check all fields exist
fn=fieldnames(data);
fn_check={'time_dnum','time_dtime','time_mor_dnum','time_mor_dtime','sim_idx','time_idx'}; %fieldnames that must be present
[~,bol_f]=find_str_in_cell(fn_check,fn);

if ~all(bol_f)
    new_all_time_needed=true;
    return
end

%There is a file with all result times, but as we request the last one, we have to check that the simulation has not continued.
last_changed=false;
if any(isinf(in_dtime)) 
    if isfolder(fpath_map) %smt
        [~,~,time_dnum_f,~,~,~,~,~]=D3D_results_time_wrap(fpath_map,results_type);
    else
        is_mor=D3D_is(fpath_map);
        [~,~,time_dnum_f,~,~,~]=D3D_results_time(fpath_map,is_mor,NaN);
    end
    if abs(time_dnum_f-data.time_dnum)>1/3600/24 %1 s threshold
        last_changed=true;
    end
end

if last_changed
    new_all_time_needed=true;
    return
end

%It can happen that it has saved a file with no output. Then it
%crashes below because of size differences. If there is nothing
%inside, we erase. 
ntt=numel(data.(fn{1})); 

if ntt==0
    new_all_time_needed=true;
    return
end

%We request an index, and the number of times is smaller than the index.
if tim_type==3 && ntt<in_dtime(end)
    new_all_time_needed=true;
    return    
end

end %function

%%

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_all(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type)

if isempty(fdir_mat) || exist(fpath_tim_all,'file')~=2
    messageOut(NaN,sprintf('Mat-file with all times not available. Reading.'))
    new_all_time_needed=true;
elseif any(isnan(in_dtime)) 
    %if it is NaN we read it anyhow because we do not reach this point in case it is NaN and it is the same size as the one we have already.
    messageOut(NaN,sprintf('Mat-file with all times available but you want all times and we need to check it is updated. Reading.'))
    new_all_time_needed=true;
else
    messageOut(NaN,sprintf('Mat-file with all times available. Loading: %s',fpath_tim_all))
    load(fpath_tim_all,'data')
    
    new_all_time_needed=D3D_time_check_if_new_all_time_needed_data(data,in_dtime,fpath_map,results_type,tim_type);

    if new_all_time_needed  %old time file, data is missing. 
        messageOut(NaN,'Mat-file with all times is outdated. Erasing and computing again.')
        delete(fpath_tim_all)
    end
end

if new_all_time_needed
    [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_get_all_results(fpath_tim_all,fpath_map,results_type);
else
    messageOut(NaN,'Mat-file with all times is usable.')
    v2struct(data);
end

end %function