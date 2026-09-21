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
%

function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'station','');
addOptional(parin,'pli','');
addOptional(parin,'pol','');
addOptional(parin,'iso','');
addOptional(parin,'var','');
addOptional(parin,'sb','');
addOptional(parin,'tim2',[]);
addOptional(parin,'stat','');
addOptional(parin,'var_idx','');
addOptional(parin,'sim_idx',''); %just to be able to pass all varargin
addOptional(parin,'branch',''); 
addOptional(parin,'elevation',[]); 
addOptional(parin,'depth_average',[]); 
addOptional(parin,'depth_average_limits',[]); 

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;
station=parin.Results.station;
pli=parin.Results.pli;
pol=parin.Results.pol;
iso=parin.Results.iso;
var=parin.Results.var;
sb=parin.Results.sb;
time_dnum_2=parin.Results.tim2;
stat=parin.Results.stat;
var_idx=parin.Results.var_idx;
branch=parin.Results.branch;
elev=parin.Results.elevation;
depth_average=parin.Results.depth_average;
depth_average_limits=parin.Results.depth_average_limits;

%%

% if isempty(time_dnum)
%     error('time missing')
% end

%% CALC

str_total='';

%time
if ~isempty(time_dnum)
    str_total=sprintf('%s%s',str_total,datestr(time_dnum,'yyyymmddHHMMSS'));
end

%time 2
if ~isempty(time_dnum_2)
    str_total=sprintf('%s-%s',str_total,datestr(time_dnum_2,'yyyymmddHHMMSS'));
end

%station
if ~isempty(station)
    str_total=sprintf('%s_%s',str_total,strrep(station,' ','_'));
end

%layer
if ~isempty(layer)
    str_add=add_numbers(layer,'layer');
    str_total=sprintf('%s_%s',str_total,str_add); %add to the total string
    % str_total=strrep(str_total,' ',''); %why should there be spaces?
end

%pli
if ~isempty(pli)
    str_total=sprintf('%s_pli_%s',str_total,strrep(pli,' ',''));
end

%pol
if ~isempty(pol)
    str_total=sprintf('%s_pol_%s',str_total,strrep(pol,' ',''));
end

%iso
if ~isempty(iso)
    str_total=sprintf('%s_iso_%s',str_total,strrep(iso,' ',''));
end

%var
if ~isempty(var)
    str_total=sprintf('%s_var_%s',str_total,strrep(var,' ',''));
end

%stat
if ~isempty(stat)
    str_total=sprintf('%s_stat_%s',str_total,strrep(stat,' ',''));
end

%sb
if ~isempty(sb)
    str_total=sprintf('%s_sb_%s',str_total,strrep(sb,' ',''));
end

%var_idx
if ~isempty(var_idx)
    str_add=add_numbers(var_idx,'var_idx');
    str_total=sprintf('%s_%s',str_total,str_add); %add to the total string
end

%branch
if ~isempty(branch)
    str_total=sprintf('%s_branch_%s',str_total,branch);
end

%elevation
if ~isempty(elev) && ~isnan(elev)
    str_total=sprintf('%s_elev_%5.3f',str_total,elev);
end

%depth average
if ~isempty(depth_average) && depth_average==1
    str_total=sprintf('%s_da',str_total);
end

%depth average limits
if ~isempty(depth_average_limits) && ~isnan(depth_average_limits(1)) && ~all(isinf(depth_average_limits))
    str_total=sprintf('%s_%5.3f-%5.3f',str_total,depth_average_limits(1),depth_average_limits(2));
end

%final
str_total=sprintf('%s_%s.mat',tag,str_total);
str_total=strrep(str_total,'__','_');
str_total=strrep(str_total,'_.mat','.mat');
if strcmp(str_total(1),'_')
    str_total(1)='';
end
fpath_mat_tmp=fullfile(fdir_mat,str_total);

end %function

%%
%% FUNCTIONS
%%

function str_add=add_numbers(layer,str_variable)

nvar=numel(layer);
str_add=repmat('%02d_',1,nvar); %create format string for each layer number: e.g., '%02d_%02d_%02d_' for 3 layers
str_add(end)=''; %remove last '_': e.g., '%04d_%04d_%04d' for 3 layers
str_add=sprintf(str_add,layer); %substitute by actual layer numbers
%if it is too long (more than 10 characters), hash it to keep the filename manageable
if numel(str_add)>10
    str_add=hash_string(str_add);
end
str_add=strcat(str_variable,'_',str_add); %add 'layer': e.g. 'layer_%04d_%04d_%04d' for 3 layers

end