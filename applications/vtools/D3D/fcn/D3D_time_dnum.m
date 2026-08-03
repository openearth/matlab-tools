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
addOptional(parin,'fdir_mat',fullfile(fpath_map,'../','mat'));
addOptional(parin,'results_type','map');
addOptional(parin,'fdir_csv',fullfile(fpath_map,'../','csv'));
addOptional(parin,'status',0); %unchecked

parse(parin,varargin{:});

tim_type=parin.Results.tim_type;
tol=parin.Results.tol;
fdir_mat=parin.Results.fdir_mat;
results_type=parin.Results.results_type;
fdir_csv=parin.Results.fdir_csv;
status=parin.Results.status;

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
    [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_double(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,tol,fdir_csv,status);
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

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_time_double(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,tol,fdir_csv,status)

%% PARSE
idx_g=NaN; %not needed, but we need to output it

if strcmp(results_type,'his') && tim_type==2
    warning('There is no morphodynamic time in history output. It has been switched to hydrodynamic time.')
    tim_type=1;
end

%% get all results time
[~,~,time_dnum_all,time_dtime_all,time_mor_dnum_all,time_mor_dtime_all,sim_idx_all,time_idx_all]=D3D_time_all(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,fdir_csv,status);

%% get the requested ones
[time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_get_requested_time(in_dtime,time_dnum_all,time_dtime_all,time_mor_dnum_all,time_mor_dtime_all,sim_idx_all,time_idx_all,tol,tim_type);

end %function

%%

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_get_all_results(fpath_tim_all,fpath_map,results_type,fdir_csv,status)

%% get time, both SMT and regular
[time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx,fpath_map_all]=D3D_results_time_wrap(fpath_map,results_type);

%% save
data=v2struct(time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx,status); %#ok
save_check(fpath_tim_all,'data')

%% write CSV
%we do it here because it is the point at which we know we need all the times and these have been read. It is also for both SMT and regular. 
write_csv_01(fdir_csv,fpath_map_all,time_r,time_mor_r,time_dnum,time_mor_dnum,sim_idx);

end %function

%% 

function new_all_time_needed=D3D_time_check_if_new_all_time_needed_data(data,in_dtime,fpath_map,results_type,tim_type)

new_all_time_needed=false;

%check all fields exist
fn=fieldnames(data);
fn_check={'time_dnum','time_dtime','time_mor_dnum','time_mor_dtime','sim_idx','time_idx','status'}; %fieldnames that must be present
[~,bol_f]=find_str_in_cell(fn_check,fn);

%a field is missing, we need to compute all times again.
if ~all(bol_f)
    new_all_time_needed=true;
    return
end
    
%simulation running, so we have to compute all times again.
if data.status==2 
    messageOut(NaN,'Mat-file with all times available and simulation is running. Computing again.')
    new_all_time_needed=true;
    return
end

%simulation finished, so we can trust the existing file. 
if data.status>2 
    messageOut(NaN,'Mat-file with all times available and simulation is finished. Using.')
    new_all_time_needed=false;
    return
end

%we want the last one or all times and the simulation is running, we need to compute all times again.
if any(isinf(in_dtime)) || any(isnan(in_dtime))
    new_all_time_needed=true;
    return
end

% %There is a file with all result times, but as we request the last one, we have to check that the simulation has not continued.
% last_changed=false;
% if any(isinf(in_dtime)) 
%     %`fpath_map` can be both a path to a map file or to an SMT simulation.
%     %We want the last time only. If it is just a simulation, we request it.
%     %If it is an SMT, we need all. `D3D_results_time_wrap` can deal with
%     %both SMT and map input, but the input to that function is the folder
%     %always, and not a map file.
%     if isfolder(fpath_map) %smt
%         [~,~,time_dnum_f,~,~,~,~,~]=D3D_results_time_wrap(fpath_map,results_type);
%     else
%         is_mor=D3D_is(fpath_map);
%         [~,~,time_dnum_f,~,~,~]=D3D_results_time(fpath_map,is_mor,NaN);
%     end

%     if isempty(time_dnum_f) || isempty(data.time_dnum)
%         error('This should not happen. We should have results.')
%     end
%     if abs(time_dnum_f(end)-data.time_dnum(end))>1/3600/24 %1 s threshold
%         last_changed=true;
%     end
% end

% if last_changed
%     new_all_time_needed=true;
%     return
% end

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

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_all(fdir_mat,fpath_tim_all,in_dtime,fpath_map,results_type,tim_type,fdir_csv,status)

if isempty(fdir_mat) || exist(fpath_tim_all,'file')~=2
    messageOut(NaN,sprintf('Mat-file with all times not available. Reading.'))
    new_all_time_needed=true;
% elseif any(isnan(in_dtime)) 
%     %if it is NaN we read it anyhow because we do not reach this point in case it is NaN and it is the same size as the one we have already.
%     if status>2 %simulation finished, so we can trust the existing file. 
%         messageOut(NaN,sprintf('Mat-file with all times available and simulation is finished. Loading: %s',fpath_tim_all))
%         load(fpath_tim_all,'data')
%         new_all_time_needed=false;
%     else
%         messageOut(NaN,sprintf('Mat-file with all times available and simulation is running. Reading.'))
%         new_all_time_needed=true;
%     end
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
    [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx]=D3D_time_get_all_results(fpath_tim_all,fpath_map,results_type,fdir_csv,status);
else
    messageOut(NaN,'Mat-file with all times is usable.')
    v2struct(data);
end

end %function

%%

function write_csv_01(fdir_csv,fpath_map,time_r,time_mor_r,time_dnum,time_mor_dnum,sim_idx)

%remove NaN to prevent cases in writing

bol_nan=isnan(time_mor_dnum);
time_mor_dnum(bol_nan)=0;

bol_nan=isnan(time_mor_dnum);
time_mor_dnum(bol_nan)=0;

nt=numel(time_r);
% fdir_csv=fullfile(sim_path,'csv');
mkdir_check(fdir_csv);
fpath_tim_csv=fullfile(fdir_csv,'tim.csv');
%better to always create in case tim file is overwritten
%         if exist(fpath_tim_csv,'file')~=2
fid=fopen(fpath_tim_csv,'w');
fprintf(fid,'time index, sim number, flow time since start [s], morpho time since start [s], flow date [datenum], morpho date [datenum], flow date [yyyy-mm-dd HH:MM:SS], morpho date [yyyy-mm-dd HH:MM:SS], map path \r\n');
for kt=1:nt
    fprintf(fid,'%04d, %03d, %10.1f, %10.1f, %15.7f, %15.7f, %s, %s, %s \r\n',kt,sim_idx(kt),time_r(kt),time_mor_r(kt),time_dnum(kt),time_mor_dnum(kt),datestr(time_dnum(kt),'yyyy-mm-dd HH:MM:SS'),datestr(time_mor_dnum(kt),'yyyy-mm-dd HH:MM:SS'),fpath_map{kt});
end %kt
fclose(fid);
%         end

end %function

%%

function [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,time_idx,fpath_map]=D3D_results_time_wrap(sim_or_map_path,varargin)

%% PARSE

switch numel(varargin)
    case 0
        nc_type='map'; 
    case 1
        nc_type=varargin{1};
    case 2
        nc_type=varargin{1};
end

%% CALC

if isfolder(sim_or_map_path) %SMT
    is_SMT=true;
else
    is_SMT=false;
end

if ~is_SMT
    fpath_nc=sim_or_map_path;
    ismor=D3D_is(fpath_nc);
    [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
    time_idx=(1:1:numel(time_r))';
    sim_idx=ones(size(time_idx));
    fpath_map=repmat({fpath_nc},numel(time_idx),1);
else
    fdir_output=fullfile(sim_or_map_path,'output');
    nf=D3D_SMT_nf(fdir_output);
    time_r=[];
    time_mor_r=[];
    time_dnum=[];
    time_dtime=[];
    time_mor_dnum=[];
    time_mor_dtime=[];
    sim_idx=[];
    fpath_map={};
    time_idx=[];
    for kf=0:1:nf
        fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf);
        simdef.D3D.dire_sim=fdir_loc;
        simdef=D3D_simpath(simdef);
        fpath_nc=simdef.file.(nc_type);
        ismor=D3D_is(fpath_nc);
        [time_r_loc,time_mor_r_loc,time_dnum_loc,time_dtime_loc,time_mor_dnum_loc,time_mor_dtime_loc]=D3D_results_time(fpath_nc,ismor,[1,Inf]);
        
        time_r=cat(1,time_r,time_r_loc);
        time_mor_r=cat(1,time_mor_r,time_mor_r_loc);
        time_dnum=cat(1,time_dnum,time_dnum_loc);
        time_dtime=cat(1,time_dtime,time_dtime_loc);
        time_mor_dnum=cat(1,time_mor_dnum,time_mor_dnum_loc);
        time_mor_dtime=cat(1,time_mor_dtime,time_mor_dtime_loc);
        sim_idx=cat(1,sim_idx,kf.*ones(size(time_mor_dtime_loc)));
        fpath_map=cat(1,fpath_map,repmat({fpath_nc},numel(time_mor_dtime_loc),1));
        if isempty(time_idx)
            time_idx=(1:1:numel(time_r_loc))';
        else
            time_idx=cat(1,time_idx,(time_idx(end)+1:1:time_idx(end)+1+numel(time_r_loc))');
        end
            
        messageOut(NaN,sprintf('Joined time %4.2f %%',kf/nf*100));
    end
end

end %function

%%

function [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,idx_g,time_idx]=D3D_get_requested_time(in_dtime,time_dnum_all,time_dtime_all,time_mor_dnum_all,time_mor_dtime_all,sim_idx_all,time_idx_all,tol,tim_type)

idx_g=NaN;

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