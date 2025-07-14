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
%Read FLORIS FLOIN file. 

function [csl,network_node_id,network_node_x,network_node_y,network_branch_id,network_edge_nodes]=floris_to_fm_read_floin(fpath_floin,csd,csd_add,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; %Not yet used

%% CHECK FILE

messageOut(fid_log,'Start processing FLOIN.')

if isempty(fpath_floin)
    messageOut(fid_log,sprintf('No floin file.'))
    return
end
if ~exist(fpath_floin,'file')==2
    messageOut(fid_log,sprintf('File does not exist: %s',fpath_floin))
end

%% INITIALIZE

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
[network_branch_id,network_edge_nodes,~]=allocate_branch(npreallocated,{''},[]);
[csl,nallocated]=allocate_csl(npreallocated);

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
        branchId=tokens{1};
        rkm0=NaN;
        continue
    end    

    %block node
    if strcmpi(line, 'node')
        inside_block_node=true;

        continue
    end

    %block compute
    if strcmpi(line, 'compute')
        % inside_block_compute=true;

        %finalize all branch
        csl=csl(1:idx_branch);

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

        if idx_branch==nallocated
            [csl,nallocated]=allocate_csl(npreallocated,csl);
        end

        csd_id={csd.id};
        idx_csd=strcmpi({csd.id},csl_id);
        if sum(idx_csd)~=1
            error('Not single cross-section definition matches %s',csl_id)
        end

        %chainage
        %We assume that cross-sections are in order along each branch.
        rkm_loc=csd_add(idx_csd).rkm;
        if isnan(rkm0)
            rkm0=csd_add(idx_csd).rkm;
            chainage=0;
        else
            chainage=(rkm_loc-rkm0)*1000; %converstion to meters
        end
        if chainage<0
            error('Chainage appears to be negative. Something is wrong.')
        end
        
        csl(idx_branch).id=sprintf('%s_loc',csl_id);
        csl(idx_branch).branchId=branchId;
        csl(idx_branch).chainage=chainage;
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

%%

function [csl,nallocated]=allocate_csl(npreallocated,csl)

% create a scalar struct with all the fields
template = struct( ...
    'id',           '', ...
    'branchId',     '', ...
    'chainage',      0, ...
    'shift',        0, ...
    'definitionId', '' );

% replicate the template into a 1×N struct array
csl_empty(1:npreallocated) = template;

if nargin==1
    csl=csl_empty;
else
    csl=[csl,csl_empty];
end
nallocated=numel(csl);

end %function