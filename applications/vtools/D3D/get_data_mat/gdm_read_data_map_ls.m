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

function data=gdm_read_data_map_ls(fpath_map_loc,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'pli','');
addOptional(parin,'dchar','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
tol_t=parin.Results.tol_t;
pli=parin.Results.pli;
dchar=parin.Results.dchar;

%%

switch varname
    case {'d10','d50','d90','dm'}
        if isempty(dchar)
            error('You need to specify characteristic grain sizes. <D3D_read_sed(fpath_sed)>')
        end
        var_str='mesh2d_lyrfrac';
        [data,data.gridInfo]=EHY_getMapModelData(fpath_map_loc,'varName',var_str,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'pliFile',pli,'tol_t',tol_t);
        
        Fa=data.val;
        switch varname
            case 'd10'
                val=grain_size_dX_mat(Fa,dchar,10);
            case 'd50'
                val=grain_size_dX_mat(Fa,dchar,50);
            case 'd90'
                val=grain_size_dX_mat(Fa,dchar,90);
            case 'dm'
                val=sum(Fa.*permute(dchar,[1,3,4,2]),4); %arithmetic mean grain size
        end
        data.val=val;
        
    otherwise
        var_str=varname;
        [data,data.gridInfo]=EHY_getMapModelData(fpath_map_loc,'varName',var_str,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'pliFile',pli,'tol_t',tol_t);
end


end %function