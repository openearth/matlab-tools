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
%Interpolates cross-sections at each computational node. 
%
%INPUT:
%   -path_mdu_ori: path to the mdu-file of the original (hydrodynamic) simulation; char
%
%OPTIONAL:
%   -fdir_new: path to the folder of the simulation to update the cross-section definitions and locations files; char
%
%OPTIONAL (pair value)
%   -'check_existing'       

function D3D_interpolate_crosssections(path_mdu_ori,varargin)

%% PARSE 

if numel(varargin)==1 %backward compatibility
    fdir_new=varargin{1,1};
    check_existing=true;
else %pair-value arguments
    parin=inputParser;

    addOptional(parin,'check_existing',true);

    parse(parin,varargin{:});

    check_existing=parin.Results.check_existing;
    
    fdir_new='';
end

%% PATHS

simdef=D3D_simpath_mdu(path_mdu_ori);

if isfield(simdef.file,'csdef')==0
    error('The mdu-file does not have cross-section definition: %s',path_mdu_ori);
end
path_csdef_ori=simdef.file.csdef;

if isfield(simdef.file,'csloc')==0
    error('The mdu-file does not have cross-section location: %s',path_mdu_ori);
end
path_csloc_ori=simdef.file.csloc;

if isfield(simdef.file,'map')==0
    error('The mdu-file does not have map output: %s',path_mdu_ori);
end
path_map_ori=simdef.file.map;

if exist(path_csdef_ori,'file')==2
    [~,cs_def_ori]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',2);
else
    error('Cannot access file: %s',path_csdef_ori);
end
check_fields_struct(cs_def_ori,{'levels','flowWidths','totalWidths','mainWidth','fp1Width','fp2Width'});

if exist(path_csloc_ori,'file')==2
    [~,cs_loc_ori]=S3_read_crosssectiondefinitions(path_csloc_ori,'file_type',3);
else
    error('Cannot access file: %s',path_csloc_ori);
end

if any([cs_loc_ori.shift])
    error('You have to rework this function for dealing with a shift.')
end

%% CALC

nelev_cs=max([cs_def_ori.numLevels]); %number of points to interpolate the new elevation 

% nc_info=ncinfo(path_map_ori);
mesh1d_node_offset=ncread(path_map_ori,'mesh1d_node_offset');
mesh1d_node_branch=ncread(path_map_ori,'mesh1d_node_branch');
mesh1d_flowelem_bl=ncread(path_map_ori,'mesh1d_flowelem_bl');
mesh1d_edge_nodes=ncread(path_map_ori,'mesh1d_edge_nodes');
network_edge_length=ncread(path_map_ori,'network_edge_length');

[~,~,str_network1d]=D3D_is(path_map_ori);
network1d_branch_id=ncread(path_map_ori,sprintf('%s_branch_id',str_network1d))';
nb=size(network1d_branch_id,1);
network1d_branch_id_c=cell(nb,1);
for kb=1:nb
    network1d_branch_id_c{kb,1}=strtrim(network1d_branch_id(kb,:));
end

nn=numel(mesh1d_node_branch);

%copy original structure
cs_def_upd=cs_def_ori(1); 
cs_loc_upd=cs_loc_ori(1); 

%reference value
cs_def_ref=cs_def_ori(1); %save it to 

%% loop on branches

F_min=cell(nb,1);
F_max=cell(nb,1);
F_flowWidths=cell(nb,1);
F_totalWidths=cell(nb,1);
F_mainWidth=cell(nb,1);
F_fp1Width=cell(nb,1);
F_fp2Width=cell(nb,1);
for kb=1:nb
%     fprintf('Dealing with branch %s \n',network1d_branch_id_c{kb,1}); %debug
    
    %2DO: A value may be empty. Check on that. 
    idx_br_loc=find_str_in_cell({cs_loc_ori.branchId},network1d_branch_id_c(kb,1));
    chain=[cs_loc_ori(idx_br_loc).chainage]';
    def_id={cs_loc_ori(idx_br_loc).definitionId};
    idx_br_def=find_str_in_cell({cs_def_ori.id},def_id);
    levels={cs_def_ori(idx_br_def).levels};
    flowWidths={cs_def_ori(idx_br_def).flowWidths};
    totalWidths={cs_def_ori(idx_br_def).totalWidths};
    mainWidth=[cs_def_ori(idx_br_def).mainWidth];
    fp1Width=[cs_def_ori(idx_br_def).fp1Width];
    fp2Width=[cs_def_ori(idx_br_def).fp2Width];

    %sort
    [chain,idx_s]=sort(chain);  %#ok<TRSRT> I want it column for the griddedInterpolant
    levels=levels(idx_s);
%     flowWidths=flowWidths(idx_s);
%     totalWidths=totalWidths(idx_s);

    %interpolation objects minimum elevation for all branches
    min_lev=cellfun(@(X)X(1),levels)';
    F_min{kb,1}=griddedInterpolant(chain,min_lev);

    %interpolation objects maximum elevation for all branches
    max_lev=cellfun(@(X)X(end),levels)';
    F_max{kb,1}=griddedInterpolant(chain,max_lev);

    %interpolation objects x-val for all branches
    F_mainWidth{kb,1}=griddedInterpolant(chain,mainWidth);
    F_fp1Width{kb,1}=griddedInterpolant(chain,fp1Width);
    F_fp2Width{kb,1}=griddedInterpolant(chain,fp2Width);
    
    %interpolation objects x-z-w for all branches
    ncs=numel(levels);
    chain_v=[];
    level_v=[];
    flowWidths_v=[];
    totalWidths_v=[];
    for kcs=1:ncs
        nlev=numel(levels{1,kcs});
        chain_v=cat(1,chain_v,chain(kcs).*ones(nlev,1));
        level_v=cat(1,level_v,levels{1,kcs}');
        flowWidths_v=cat(1,flowWidths_v,flowWidths{1,kcs}');    
        totalWidths_v=cat(1,totalWidths_v,totalWidths{1,kcs}');    
    end
    F_flowWidths{kb,1}=scatteredInterpolant(chain_v,level_v,flowWidths_v,'linear','nearest');
    F_totalWidths{kb,1}=scatteredInterpolant(chain_v,level_v,totalWidths_v,'linear','nearest');
    

end %kb

%% loop on mesh nodes (i.e., cell centres)

for kn=1:nn
    
    %local names
    br_l=strtrim(network1d_branch_id(mesh1d_node_branch(kn)+1,:));
    ch_l=mesh1d_node_offset(kn); %local chainage
    cs_id_l=cs_name(br_l,ch_l);
    
    [lev_i,relative_levels,flowWidths_i,totalWidths_i,mainWidth_i,fp1Width_i,fp2Width_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width);

    %definition
    cs_def_upd(kn)=cs_def_ref; %copy original
    cs_def_upd(kn).id=cs_id_l; %modify name    
    cs_def_upd(kn).flowWidths=flowWidths_i; 
    cs_def_upd(kn).totalWidths=totalWidths_i;
    cs_def_upd(kn).mainWidth=mainWidth_i;
    cs_def_upd(kn).fp1Width=fp1Width_i;
    cs_def_upd(kn).fp2Width=fp2Width_i;
    cs_def_upd(kn).numLevels=nelev_cs;

    %modify levels
    %the two lines below should be the same. Using the mesh1d_bl we guarantee that it is exactly the same.
    cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; 
%     cs_def_upd(kn).levels=lev_i; 

    %location
    cs_loc_upd(kn).id=cs_id_l;
    cs_loc_upd(kn).branchId=br_l;
    cs_loc_upd(kn).chainage=ch_l;
    cs_loc_upd(kn).shift=0;
    cs_loc_upd(kn).definitionId=cs_id_l;
       
end

%% add CS at beginning and end of branches

kn=nn; %last one
for kb=1:nb
    
    
    br_l=strtrim(network1d_branch_id(kb,:)); %branch name
    
    %loop upstream and downstream
    for kud=1:2
        if kud==1 %upstream
            ch_l=0;
        elseif kud==2 %downstream
            ch_l=network_edge_length(kb);
        end
        
        %create location
        cs_id_l=cs_name(br_l,ch_l);
        idx_loc=find_str_in_cell({cs_loc_upd.id},{cs_id_l});
        if ~isnan(idx_loc); continue; end %if it already exists we do not add it
        
        %data to add
        [lev_i,relative_levels,flowWidths_i,totalWidths_i,mainWidth_i,fp1Width_i,fp2Width_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width);
    
        %update
        kn=kn+1;
        
        %definition
        cs_def_upd(kn)=cs_def_ref; %copy original
        cs_def_upd(kn).id=cs_id_l; %modify name    
        cs_def_upd(kn).flowWidths=flowWidths_i; 
        cs_def_upd(kn).totalWidths=totalWidths_i;
        cs_def_upd(kn).mainWidth=mainWidth_i;
        cs_def_upd(kn).fp1Width=fp1Width_i;
        cs_def_upd(kn).fp2Width=fp2Width_i;
        cs_def_upd(kn).numLevels=nelev_cs;

        %modify levels
        %the two lines below should be the same. We need to extrapolate in this case
%         cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; 
        cs_def_upd(kn).levels=lev_i; 

        %location
        cs_loc_upd(kn).id=cs_id_l;
        cs_loc_upd(kn).branchId=br_l;
        cs_loc_upd(kn).chainage=ch_l;
        cs_loc_upd(kn).shift=0;
        cs_loc_upd(kn).definitionId=cs_id_l;
    
        
    end %kud

end

% %1=upstream
% [cs_def_upd,cs_loc_upd]=add_CS_at_bifurcations(1,cs_def_upd,cs_loc_upd,mesh1d_edge_nodes,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width,network_edge_length,mesh1d_node_branch);
% %2=downstream
% [cs_def_upd,cs_loc_upd]=add_CS_at_bifurcations(2,cs_def_upd,cs_loc_upd,mesh1d_edge_nodes,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width,network_edge_length,mesh1d_node_branch);

%% write

[fdir_csdef,fname_csdef,fext_csdef]=fileparts(path_csdef_ori);
[fdir_csloc,fname_csloc,fext_csloc]=fileparts(path_csloc_ori);
if ~isempty(fdir_new) %not being passed as input
    fdir_csdef=fdir_new;
    fdir_csloc=fdir_new;
end
fpath_csdef_new=fullfile(fdir_csdef,sprintf('%s_int%s',fname_csdef,fext_csdef));
fpath_csloc_new=fullfile(fdir_csloc,sprintf('%s_int%s',fname_csloc,fext_csloc));
    
D3D_io_input('write',fpath_csdef_new,cs_def_upd,'check_existing',check_existing);
D3D_io_input('write',fpath_csloc_new,cs_loc_upd,'check_existing',check_existing);

% simdef.D3D.dire_sim=fdir_new;
% simdef.csd=cs_def_upd;
% simdef.csl=cs_loc_upd;

% simdef=D3D_simpath(simdef);
% [~,csloc_fname,csloc_ext]=fileparts(simdef.file.csloc);
% [~,csdef_fname,csdef_ext]=fileparts(simdef.file.csdef);
% D3D_crosssectiondefinitions(simdef,'check_existing',false,'fname',sprintf('%s%s',csdef_fname,csdef_ext));
% D3D_crosssectionlocation(simdef,'check_existing',false,'fname',sprintf('%s%s',csloc_fname,csloc_ext));

end %function

%%
%% FUNCTIONS
%%

function [lev_i,relative_levels,flowWidths_i,totalWidths_i,mainWidth_i,fp1Width_i,fp2Width_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width)

%2DO: I could group between the function that require interpolation in chainage only and the ones that require
%interpolation in both chainage and elevation. Then we simply loop through the functions generically and we do not
%have to modify this function when a new variable changes. 

idx_br=find_str_in_cell(network1d_branch_id_c,{br_l});

%interpolation only on chainage
min_lev_i  =F_min      {idx_br,1}(ch_l); %interpolate minimum elevation
max_lev_i  =F_max      {idx_br,1}(ch_l); %interpolate maximum elevation
mainWidth_i=F_mainWidth{idx_br,1}(ch_l); %interpolate main width
fp1Width_i =F_fp1Width {idx_br,1}(ch_l); %interpolate fp1
fp2Width_i =F_fp2Width {idx_br,1}(ch_l); %interpolate fp1

%interpolation in elevation
lev_i=linspace(min_lev_i,max_lev_i,nelev_cs)';
relative_levels=cumsum([0;diff(lev_i)]);
flowWidths_i =F_flowWidths {idx_br,1}(ch_l.*ones(nelev_cs,1),lev_i); %interpolate maximum elevation
totalWidths_i=F_totalWidths{idx_br,1}(ch_l.*ones(nelev_cs,1),lev_i); %interpolate maximum elevation

end %funtion

%%

function cs_id_l=cs_name(br_l,ch_l)

cs_id_l=sprintf('br_%s_ch_%7.7f',br_l,ch_l);

end %function

%% 

%All naming in this function is made for searching an upstream node. Then the possibility of searching for a downstream node was added. 

function [cs_def_upd,cs_loc_upd]=add_CS_at_bifurcations(idx_ud,cs_def_upd,cs_loc_upd,mesh1d_edge_nodes,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width,network_edge_length,mesh1d_node_branch)

if idx_ud==1 %upstream
    idx_du=2;
elseif idx_ud==2 %downstream
    idx_du=1;
end

kn=numel(cs_loc_upd);

us_u=unique(double(mesh1d_edge_nodes(idx_ud,:))); %upstream nodes unique
us_count=hist(mesh1d_edge_nodes(idx_ud,:),us_u)'; %time a node is upstream node
bol_bif=us_count>1;
idx_bif=us_u(bol_bif);
nbif=sum(bol_bif);

for kbif=1:nbif
    us_node_v=find(mesh1d_edge_nodes(idx_ud,:)==idx_bif(kbif));
    nds=numel(us_node_v);
    for kds=1:nds
        idx_ds=mesh1d_edge_nodes(idx_du,us_node_v(kds));
        cs_loc_ds=cs_loc_upd(idx_ds);
        cs_def_ds=cs_def_upd(idx_ds);

        if idx_ud==1 %upstream
            ch_l=0;
        elseif idx_ud==2 %downstream
            idx_br=mesh1d_node_branch(idx_ds)+1;
            ch_l=network_edge_length(idx_br);
        end
        
        br_l=cs_loc_ds.branchId;
        [lev_i,relative_levels,flowWidths_i,totalWidths_i,mainWidth_i,fp1Width_i,fp2Width_i]=interpolate_at_chain(ch_l,br_l,nelev_cs,network1d_branch_id_c,F_min,F_max,F_flowWidths,F_totalWidths,F_mainWidth,F_fp1Width,F_fp2Width);
    
        %add
        kn=kn+1;

        cs_id_l=cs_name(br_l,ch_l);

        %definition
        cs_def_upd(kn)=cs_def_ds; %copy original
        cs_def_upd(kn).id=cs_id_l; %modify name    
        cs_def_upd(kn).flowWidths=flowWidths_i; 
        cs_def_upd(kn).totalWidths=totalWidths_i;
        cs_def_upd(kn).mainWidth=mainWidth_i;
        cs_def_upd(kn).fp1Width=fp1Width_i;
        cs_def_upd(kn).fp2Width=fp2Width_i;
        cs_def_upd(kn).numLevels=nelev_cs;

        %modify levels
        %the two lines below should be the same. We need to extrapolate in this case
%         cs_def_upd(kn).levels=mesh1d_flowelem_bl(kn)+relative_levels; 
        cs_def_upd(kn).levels=lev_i; 

        %location
        cs_loc_upd(kn).id=cs_id_l;
        cs_loc_upd(kn).branchId=br_l;
        cs_loc_upd(kn).chainage=ch_l;
        cs_loc_upd(kn).shift=0;
        cs_loc_upd(kn).definitionId=cs_id_l;

    end
end %kbif

end %function
