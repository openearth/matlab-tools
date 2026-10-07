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

function data_var=gdm_read_data_map_mean_grain_size(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'sum_var_idx',1);
% addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'do_load',true);

parse(parin,varargin{:});

tol_t=parin.Results.tol_t;
time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
sum_var_idx=parin.Results.sum_var_idx;
% tol=parin.Results.tol;
layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
do_load=parin.Results.do_load;

%% CALC
    
%REFACTORING: We have already computed the information of what the simulation is, 
%but this information is in `simdef` which is not passed here. In a refactoring stage,
%simdef needs to pass until here. 
[ismor,is1d,str_network1d,issus,structure,is3d]=D3D_is(fpath_map);
[varname_save_mat,varname_read_variable,varname_load_mat,varname_label]=D3D_var_num2str('lyrfrac','structure',structure,'ismor',ismor,'is1d',is1d,'res_type','map','is3d',is3d);
data_lyrfrac=gdm_read_data_map_Fak(fdir_mat,fpath_map,varname_read_variable,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'sum_var_idx',sum_var_idx,'tol_t',tol_t); 
Fa=data_lyrfrac.val; %'[time,mesh2d_nFaces,nBedLayers,nSedTot]'
[nt,nx,nl,nf]=size(Fa); %time, x, layers, fractions

%REFACTORING: Similarly as before, if we pass `simdef` we can read it directly here:
% dchar=gdm_read_dk(simdef);
fpath_dk=fullfile(fdir_mat,'dk.mat'); %we assume it is there
if ~isfile(fpath_dk)
    error('dk.mat not found in the specified directory.');
end
load(fpath_dk,'dk'); %[1,nf]

switch varname
    case 'dg' %geometric mean grain size
        d0=1e-3; %1 mm
        phi=log2(dk./d0); %[1,nf]
        phi_aux=repmat(reshape(phi,1,1,1,[]),[nt,nx,nl,1]); %[nt, nx, nl, nf]
        phi_m=sum(phi_aux.*Fa,4);
        val=d0.*2.^phi_m;
    case 'dm' %arithmetic mean grain size
        val=sum(Fa.*permute(dk,[1,3,4,2]),4);
    otherwise
        error('Unsupported variable name for mean grain size calculation.')
end

%% sum fractions 

data_var=data_lyrfrac;
data_var.val=val;

%get fractions in the desired layer
if ~isempty(layer)
%     idx_l=D3D_search_index_in_dimension(data_lyrfrac,'bed_layers'); 
    idx_l=D3D_search_index_layer(data_lyrfrac);
    data_var.val=submatrix(data_var.val,idx_l,layer); %take submatrix along dimension
end

end %function