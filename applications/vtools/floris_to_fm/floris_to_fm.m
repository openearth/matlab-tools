%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20235 $
%$Date: 2025-07-07 14:32:25 +0200 (Mon, 07 Jul 2025) $
%$Author: chavarri $
%$Id: D3D_gdm.m 20235 2025-07-07 12:32:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Convert Floris to Delft3D FM model. 

function floris=floris_to_fm(fpath_cfg)

%% PARSE

fid_log=NaN;

%% CALC

%% cfg

[floris.cfg,floris.file]=floris_to_fm_read_cfg(fpath_cfg,fid_log);

%% funin

[floris.csd,floris.csd_add]=floris_to_fm_read_funin(floris.file.funin);

%% floin

floris.csl=floris_to_fm_read_floin(floris.file.floin);

%%

end %function

%%
%% FUNCTIONS
%%

function [cfg,file]=floris_to_fm_read_cfg(fpath_cfg,varargin)

%% PARSE

fid_log=NaN;
if nargin>1
    fid_log=varargin{1};
end

%% CHECK FILE

[fdir,fname,fext]=fileparts(fpath_cfg);

if ~exist('fpath_cfg','file')
    messageOut(fid_log,sprintf('cfg-file does not exist: %s',fpath_cfg))
end
if ~strcmp(fext,'.cfg')
    messageOut(fid_log,sprintf('This is supposed to be a cfg-file: %s',fpath_cfg))
end

%% CALC

cfg=D3D_io_input('read',fpath_cfg);

file.cfg=fpath_cfg;

file_cell={'floin_file','floab_file','funin_file','funtab_file'}; %add more
nf=numel(file_cell);
for kf=1:nf
    file_tag=file_cell{kf};
    file_tag_reduced=strrep(file_tag,'_file',''); 
    if isfield(cfg,file_tag)
        file.(file_tag_reduced)=fullfile(fdir,cfg.(file_tag));
    else
        file.(file_tag_reduced)='';
        messageOut(fid_log,sprintf('Flag not found: %s',file_tag))
    end
end %nf

end %function

%%

function [csd,csd_add]=floris_to_fm_read_funin(fpath_funin,varargin)

%% PARSE

fid_log=NaN;
if nargin>1
    fid_log=varargin{1};
end

%% CHECK FILE

if isempty(fpath_funin)
    messageOut(fid_log,sprintf('No funin file.'))
    return
end
if ~exist('fpath_funin','file')
    messageOut(fid_log,sprintf('File does not exist: %s',fpath_funin))
end

%% CALC

fid=fopen(fpath_funin,'r');

idx_crs=0; %index of cross-section
inside_crs_block=false; %true if inside a cross-section block
inside_block_values=false; %true if inside a values block (i.e., not header)

while ~feof(fid)
    line=strtrim(fgetl(fid)); %get line

    %skip empty lines and comments
    if isempty(line) || startsWith(line, '/') || startsWith(line, '//')
        continue;
    end

    %if the line has `values`, we have already looped through the header.
    %Variable `inside_block_values` will always be true.
    if strcmpi(line, 'values')
        if inside_block_values && ~inside_crs_block
            %if the line has `values` and we are not inside a crs block, we
            %are starting a new crs block. 
            inside_crs_block=true;
        end
        inside_block_values = true;
        continue;
    end

    %if not in `values` block, we are in the header.
    if ~inside_block_values
        continue
    end

    %get first number of the line
    tokens = regexp(line, '([-+]?\d*\.?\d+)|,', 'match');
    tokens = cellfun(@(x) strtrim(x), tokens, 'uni', 0);
    tokens(strcmp(tokens, ',')) = {''};

    tokens_num=str2double(tokens);
    num_ident=tokens_num(1); %this identifies the type of line
    switch num_ident
        case 1
            %top definition of friction
            %1.00 0.15 38. 15. , , 38.  /

            %DO SOMETHING WITH IT
            %nums=str2double(tokens);
        case 20
            %cross-section location
            %20 '2223000' -2223.000 0. , , , , 412571.38 520292.5 412799.59 520218.7 /
            tokens=regexp(line,'''[^'']*''|[-+]?\d*\.?\d+','match');

            idx_crs=idx_crs+1; %new cross-section

            id_token=tokens{2};
            id=strrep(id_token,'''','');
            
            %data for d3d cross-sections
            csd(idx_crs).id=id;
            csd(idx_crs).type='yz';
            csd(idx_crs).singleValuedZ='yes';
            csd(idx_crs).yzCount=0;
            csd(idx_crs).yCoordinates=[];
            csd(idx_crs).zCoordinates=[];
            csd(idx_crs).conveyance='lumped'; %segmented, lumped
            csd(idx_crs).sectionCount=1; %number of roughness cross-section
            csd(idx_crs).frictionPositions=1; 
            csd(idx_crs).frictionIds=1; 
            csd(idx_crs).frictionTypes=1;
            csd(idx_crs).frictionValues=1;

            %other data
            csd_add(idx_crs).rkm=tokens_num(3);
            csd_add(idx_crs).x_left=tokens_num(9);
            csd_add(idx_crs).y_left=tokens_num(10);
            csd_add(idx_crs).x_right=tokens_num(11);
            csd_add(idx_crs).y_right=tokens_num(12);

        case 21
            %cross-section definition
            %21 5.910 290.697 /
            csd(idx_crs).yzCount=csd(idx_crs).yzCount+1;
            csd(idx_crs).yCoordinates=cat(1,csd(idx_crs).yCoordinates,tokens_num(2));
            csd(idx_crs).zCoordinates=cat(1,csd(idx_crs).zCoordinates,tokens_num(3));
        case 99
            %end of cross-section definition
            inside_crs_block=false;
            continue
    end %switch

end %while

end %function

%%

function floris_to_fm_read_floin(fpath_floin)

%%

fid=fopen(fpath_floin,'r');

inside_block_aliase=false;
idx_network_node=0;

inside_block_branches=false;
idx_branches=0;

inside_block_node=false;

inside_block_branch=false;
idx_branch=0; 

npreallocated=1000;
[network_node_id,network_node_x,network_node_y,~]=allocate_network(npreallocated,{''},[],[]);
[network_branch_id,network_edge_nodes,nallocated]=allocate_branch(npreallocated,{''},[]);

while ~feof(fid)
    line=strtrim(fgetl(fid)); %get line

    %skip empty lines and comments
    if isempty(line) || startsWith(line, '/') || startsWith(line, '//')
        continue
    end

    %% INITIALIZATION

    %block aliase
    if strcmpi(line, 'aliase')
        inside_block_aliase=true;

        continue
    end %aliase

    %block branches
    if strcmpi(line, 'branches')
        inside_block_branches=true;

        %finalize block aliases
        if inside_block_aliase
            network_node_id=network_node_id(1:idx_network_node);
            network_node_x=network_node_x(1:idx_network_node);
            network_node_y=network_node_y(1:idx_network_node);

            inside_block_aliase=false;
        end

        continue
    end %branches

    %block branch
    if strcmpi(line, 'branch')
        inside_block_branch=true;

        %get branch name
        line=strtrim(fgetl(fid)); %get line
        tokens=regexp_string_no_quotes(line);
        idx_branchId=strcmpi(network_branch_id,tokens);
        if sum(idx_branchId)~=1
            error('Branch %s is defined, but it is not defined in branches.',tokens)
        end
        branchId=tokens;
        rkm0=NaN;
        continue
    end    

    %block node
    if strcmpi(line, 'node')
        inside_block_node=true;

        continue
    end

    %end
    if strcmpi(line, 'end')
        %finalize block branches
        if inside_block_branches
            network_branch_id=network_branch_id(1:idx_branches);
            network_edge_nodes=network_edge_nodes(1:idx_branches,:);

            inside_block_branches=false;
        end

        %finalize block node
        if inside_block_node
            inside_block_node=false;
        end

        %finalize block branch
        if inside_block_branch
            inside_block_branch=false;
        end

        continue
    end %end

    %% PROCESS BLOCK

    if ~inside_block_aliase && ~inside_block_branches && ~inside_block_node && ~inside_block_branch
        continue
    end

    %block aliase
    if inside_block_aliase
        tokens=regexp(line,'^(\S+)\s+([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)','tokens');

        idx_network_node=idx_network_node+1;

        if idx_network_node==nallocated
            [network_node_id,network_node_x,network_node_y,nallocated]=allocate_network(npreallocated,network_node_id,network_node_x,network_node_y);
        end

        network_node_id{idx_network_node}=tokens{1,1}{1,1};
        network_node_x(idx_network_node)=str2double(tokens{1,1}{1,3});
        network_node_y(idx_network_node)=str2double(tokens{1,1}{1,4});
    end %inside_block_aliase

    %block branches
    if inside_block_branches
        tokens=regexp_string_no_quotes(line);

        idx_branches=idx_branches+1;

        if idx_branches==nallocated
            [network_branch_id,network_edge_nodes,nallocated]=allocate_branch(npreallocated,network_branch_id,network_edge_nodes);
        end

        network_branch_id{idx_branches}=tokens{1};

        %index in the `network_node_id` with the name of the node
        idx_i=find(strcmp(network_node_id,tokens{2}));
        idx_f=find(strcmp(network_node_id,tokens{3}));

        network_edge_nodes(idx_branches,:)=[idx_i,idx_f]-1; %Start and end nodes of network edges. Base 0 counting. 

    end %inside_block_branches

    %block node
    if inside_block_node
        % tokens=regexp(line,'''[^'']*''|\S+','match');
        %DO SOMETHING

    end %inside_block_node

    %block branch
    if inside_block_branch
        tokens=regexp_string_no_quotes(line);

        csl_id=tokens{1};
        idx_branch=idx_branch+1;

        csd_id={floris.csd.id};
        idx_csd=strcmpi({floris.csd.id},csl_id);
        if sum(idx_csd)~=1
            error('Not single cross-section definition matches %s',csl_id)
        end

        %chainage
        %We assume that cross-sections are in order along each branch.
        rkm_loc=floris.csd_add(idx_csd).rkm;
        if isnan(rkm0)
            rkm0=floris.csd_add(idx_csd).rkm;
            chainage=0;
        else
            chainage=(rkm_loc-rkm0)*1000; %converstion to meters
        end
        if chainage<0
            error('Chainage appears to be negative. Something is wrong.')
        end
        
        csl(idx_branch).id=sprintf('%s_loc',csl_id);
        csl(idx_branch).branchId=branchId;
        csl(idx_branch).chinage=chainage;
        csl(idx_branch).shift=0;
        csl(idx_branch).definitionId=csd_id{idx_csd};

    end %inside_block_branch

end %while

end %function

%%

function [network_node_id,network_node_x,network_node_y,nallocated]=allocate_network(npreallocated,network_node_id,network_node_x,network_node_y)

network_node_id_empty=cell(npreallocated,1);
network_node_id=cat(1,network_node_id,network_node_id_empty);

network_node_x_empty=NaN(npreallocated,1);
network_node_x=cat(1,network_node_x,network_node_x_empty);

network_node_y_empty=NaN(npreallocated,1);
network_node_y=cat(1,network_node_y,network_node_y_empty);

nallocated=numel(network_node_id);

end %function

%%

function [network_branch_id,network_edge_nodes,npreallocated]=allocate_branch(npreallocated,network_branch_id,network_edge_nodes)

network_branch_id_empty=cell(npreallocated,1);
network_branch_id=cat(1,network_branch_id,network_branch_id_empty);

network_node_x_empty=NaN(npreallocated,2);
network_edge_nodes=cat(1,network_edge_nodes,network_node_x_empty);

end %function

%%

function tokens=regexp_string_no_quotes(line)

tokens=regexp(line,'''[^'']*''|\S+','match');
tokens=regexprep(tokens, '^''|''$', ''); %strip the single quotes

end %function