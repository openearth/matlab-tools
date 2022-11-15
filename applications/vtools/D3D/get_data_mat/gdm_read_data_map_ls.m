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

function data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'pli','');
% addOptional(parin,'dchar',''); %why did I comment this out?
addOptional(parin,'overwrite',false);
addOptional(parin,'branch','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
tol_t=parin.Results.tol_t;
pli=parin.Results.pli;
overwrite=parin.Results.overwrite;
branch=parin.Results.branch;
% dchar=parin.Results.dchar;

[~,pliname,~]=fileparts(pli);
pliname=strrep(pliname,' ','_');

%%

var_str=varname;
fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'pli',pliname,'branch',branch);
if exist(fpath_sal,'file')==2 ~=overwrite
    messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_sal));
    load(fpath_sal,'data')
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',var_str));
    [data,data.gridInfo]=EHY_getMapModelData(fpath_map,'varName',var_str,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'pliFile',pli,'tol_t',tol_t);
    save_check(fpath_sal,'data');
end

end %function