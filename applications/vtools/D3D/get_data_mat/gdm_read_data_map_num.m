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

function data=gdm_read_data_map_num(fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum_obj=parin.Results.tim;
% layer=parin.Results.layer;

%% CALC

ismor=D3D_is(fpath_map);

[time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map,ismor,[1,Inf]);
[diff_tim,in.kt]=min(abs(time_dnum-time_dnum_obj));
if diff_tim>5/60/24
    error('The time differs by more than 5 min')
end

simdef.D3D.structure=2;
simdef.file.map=fpath_map;
in.flg.get_EHY=1;
in.flg.get_cord=0;
simdef.flg.which_p=2; 
simdef.flg.which_v=varname;

if isempty(time_dnum)
%     data=EHY_getMapModelData(fpath_map,'varName',varname,'mergePartitions',1,'disp',0);
else
    out=D3D_read(simdef,in);
end

data.val=out.z';

end %function