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
%Read FLORIS FLOIN file. 

function [csl,bc,network_node_id,network_node_x,network_node_y,network_branch_id,network_edge_nodes,structures_at_node,mdu]=floris_to_fm_read_floin(fpath_floin,csd,csd_add,time_unit,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log;

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

tim_factor=time_factor('hours',time_unit); %the input time is in hours

fid=fopen(fpath_floin,'r');

inside_block_aliase=false;
idx_network_node=0;

inside_block_branches=false;
idx_branches=0;

inside_block_node=false;
    %blocks inside block `node`
    inside_block_hqrelation=false;
    inside_block_qhydrograph=false;

idx_bc=0;
idx_bc_val=0;
idx_structure=0;
ncolumns_bc=2; %Number of columns in BC for a node. 

inside_block_branch=false;
idx_branch=0; 

inside_block_compute=false;
line_number_block_compute=0;

inside_block_qlateral=false;
idx_qlateral=0;

npreallocated=1000;
[network_node_id,network_node_x,network_node_y,~]=allocate_network(npreallocated,{''},[],[]);
[network_branch_id,network_edge_nodes,~]=allocate_branch(npreallocated,{''},[]);
[csl,nallocated_csl]=allocate_csl(npreallocated);
[bc,nallocated_bc]=allocate_bc(npreallocated);
[structures_at_node,nallocated_structures]=allocate_structures(npreallocated);

while ~feof(fid)
    %First, a line is read. If the line corresponds to the beginning of a
    %block, the block is initialized. A logical flag indicating the kind of
    %block is set. If we are inside a block, the line is processed. 

    %% NEW LINE
    line=strtrim(fgetl(fid)); %get line

    %skip empty lines and comments
    if isempty(line) || startsWith(line, '/') || startsWith(line, '//')
        continue
    end

    %%
    %% INITIALIZATION OF BLOCK
    %%

    %% block aliase
    if strcmpi(line, 'aliase')
        inside_block_aliase=true;

        continue
    end %aliase

    %% block branches
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

    %% block branch
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

    %% block node
    if strcmpi(line, 'node')
        inside_block_node=true;

        %get node name
        line=strtrim(fgetl(fid)); %get line
        tokens=regexp_string_no_quotes(line);
        bol_nodeId=strcmpi(network_node_id,tokens);
        if sum(bol_nodeId)~=1
            error('Node %s is defined, but it is not defined in aliases.',tokens)
        end
        nodeId=tokens{1};

        %check type of boundary condition
        line=strtrim(fgetl(fid)); %get line
        tokens=regexp_string_no_quotes(line);
        is_pump=false;
        switch tokens{1}
            case 'qhydrograph' %boundary condition on discharge
                inside_block_qhydrograph=true;

                %In FLORIS, a structure is always found at the end of a
                %branch. A discharge downstream of the structure can be set
                %using a `qhydrograph`. In D3D this is a pump. 

                %`network_edge_nodes` must be already populated. I.e, the
                %block `branches` in <floin> must be above `qhydrograph`.

                %If the node is found at the end and at the beginning of 
                %a branch, it is not a true Q boundary condition but a pump. 

                idx_nodeId=find(bol_nodeId)-1; %0-based index of the node
                bol_nodeId_at_branch=network_edge_nodes==idx_nodeId;
                if any(bol_nodeId_at_branch(:,1)) && any(bol_nodeId_at_branch(:,2))
                    is_pump=true;
                end

                if is_pump
                    structure_type='pump';
                else %true Q boundary condition
                    [bc,nallocated_bc,idx_bc]=fill_bc_header(bc,nallocated_bc,idx_bc,time_unit,nodeId,'Boundary','',[]);
                end

            case 'hqrelation' %boundary condition on qh-relation
                inside_block_hqrelation=true;
                
                idx_bc=idx_bc+1;
        
                if idx_bc==nallocated_bc
                    [bc,nallocated_bc]=allocate_bc(npreallocated,bc);
                end

                bc(idx_bc).type='Boundary';
                bc(idx_bc).name=nodeId;
                bc(idx_bc).function='qhtable';
                % bc(idx_bc).time_interpolation='linear';
                bc(idx_bc).quantity={'qhbnd discharge','qhbnd waterlevel'}; %ATTENTION! The order here influences the flip when the data is read.
                bc(idx_bc).unit={'m³/s','m'};
            case 'waterlevel'
                %nothing to be done
            otherwise
                error('Deal with this case: %s',tokens{1});
        end %switch
        [val_time,nallocated_bc_val]=allocate_bc_val(npreallocated,[],ncolumns_bc); %allocate `val_time` to save the time series
        continue
    end %node

    %% block weir

    % This is not ideal logic. As is information of a node, it would be
    % logical it is read inside the block `node`. However, the tag (i.e.,
    % `weir`, `gate`, ...) is not found immediatly after it. First come the
    % BC. We read it and add it to the last node we read. 
    %
    %It applies to all structures.

    if any(strcmpi(line, {'weir','gate'}))
        structure_type=line; %type of structure (e.g., `weir`, `gate`, ...)
        line=strtrim(fgetl(fid)); %get line
        val=extracNumbers_NaN(line); %values

        [structures_at_node,nallocated_structures,idx_structure]=fill_structures_at_node(structures_at_node,nodeId,structure_type,val,nallocated_structures,npreallocated,idx_structure);
    end

    % %block gate    
    % if strcmpi(line, 'gate')
    %     line=strtrim(fgetl(fid)); %get line
    %     val=extracNumbers_NaN(line);
    % end

    %% block qlateral
    if strcmpi(line, 'qlateral')
        inside_block_qlateral=true;

        line=strtrim(fgetl(fid)); %get line
        val=extractNumbers(line); %cross-section of last processed branch in which the lateral is found

        bol_branch=strcmp({csl.branchId},branchId);
        csl_branch=csl(bol_branch);
        chainage=csl_branch(val).chainage;

        name=sprintf('lateral_%s_%f',branchId,chainage); %last branchId processed and chainage of th

        % idx_qlateral=idx_qlateral+1;

        [bc,nallocated_bc,idx_bc]=fill_bc_header(bc,nallocated_bc,idx_bc,time_unit,name,'Lateral',branchId,chainage);
        
        continue
    end

    %% block compute
    if strcmpi(line, 'compute')
        inside_block_compute=true;
        continue
    end

    %% end
    if strcmpi(line, 'end')
        %finalize block branches
        if inside_block_branches
            network_branch_id=network_branch_id(1:idx_branches);
            network_edge_nodes=network_edge_nodes(1:idx_branches,:);

            inside_block_branches=false;
        end

        %finalize block node
        % Maybe not finalize it. If there are structure, there node
        % information continues after the end of the BC block. 
        % if inside_block_node
        %     inside_block_node=false;
        % end

        %finalize block branch
        if inside_block_branch
            inside_block_branch=false;
        end

        %finalize block qhydrograph or qh-relation
        if inside_block_qhydrograph || inside_block_hqrelation || inside_block_qlateral
            if is_pump
                [structures_at_node,nallocated_structures,idx_structure]=fill_structures_at_node(structures_at_node,nodeId,structure_type,val_time(1:idx_bc_val,:),nallocated_structures,npreallocated,idx_structure);
            else
                bc(idx_bc).val=val_time(1:idx_bc_val,:);  %cut the bc val
            end
            idx_bc_val=0;
            %I think I can make always all false rather than distinguishing
            %between cases. 
            inside_block_qhydrograph=false;
            inside_block_hqrelation=false; 
            inside_block_qlateral=false;
        end 

        %finalize block compute
        %assumed at the end of the definition, used to finalize all blocks
        if inside_block_compute
            inside_block_compute=false;

            %finalize all branch
            csl=csl(1:idx_branch);
    
            %finalize all boundary condition
            bc=bc(1:idx_bc);
    
            %finalize all structures
            structures_at_node=structures_at_node(1:idx_structure);
        end

        % %finalize block qlateral
        % if inside_block_qlateral
        %     inside_block_qlateral=false;
        % end

        continue
    end %end

    %%
    %% PROCESS BLOCK
    %%

    skip_process_block=~any([inside_block_aliase,inside_block_branches,inside_block_node,inside_block_branch,inside_block_qhydrograph,inside_block_compute,inside_block_qlateral]);
    
    if skip_process_block
        continue
    end

    %% block aliase
    if inside_block_aliase
        tokens=regexp(line,'^(\S+)\s+([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)','tokens'); %It is different than just numbers as it reads a string. We cannot use `extractNumbers`.

        idx_network_node=idx_network_node+1;

        if idx_network_node==nallocated_bc
            [network_node_id,network_node_x,network_node_y,nallocated_bc]=allocate_network(npreallocated,network_node_id,network_node_x,network_node_y);
        end

        network_node_id{idx_network_node}=tokens{1,1}{1,1};
        network_node_x(idx_network_node)=str2double(tokens{1,1}{1,3});
        network_node_y(idx_network_node)=str2double(tokens{1,1}{1,4});
    end %inside_block_aliase

    %% block branches
    if inside_block_branches
        tokens=regexp_string_no_quotes(line);

        idx_branches=idx_branches+1;

        if idx_branches==nallocated_bc
            [network_branch_id,network_edge_nodes,nallocated_bc]=allocate_branch(npreallocated,network_branch_id,network_edge_nodes);
        end

        network_branch_id{idx_branches}=tokens{1};

        %index in the `network_node_id` with the name of the node
        idx_i=find(strcmp(network_node_id,tokens{2}));
        idx_f=find(strcmp(network_node_id,tokens{3}));

        network_edge_nodes(idx_branches,:)=[idx_i,idx_f]-1; %Start and end nodes of network edges. Base 0 counting. 

    end %inside_block_branches

    %block node
    % if inside_block_node
    %     tokens=regexp_string_no_quotes(line);
    % 
    %     %DO SOMETHING
    % 
    % end %inside_block_node

    %% block qhydrograph or block qh-relation
    if inside_block_qhydrograph || inside_block_hqrelation || inside_block_qlateral
        val=extractNumbers(line);
        if ~isequal(size(val),[1,ncolumns_bc])
            error('It is expected that in this line there is one row of %d values: %s ',ncolumns_bc,line)
        end

        %modify time unit
        if inside_block_qhydrograph
            %Column 1: time [hours]
            %Column 2: discharge [m^3/s]

            %convert time to whatever time we set as input
            val(:,1)=val(:,1).*tim_factor;
        elseif inside_block_hqrelation
            %Column 1: water level  [mAD]
            %Column 2: discharge [m^3/s]

            %change order of columns. In D3D it is Q-H.
            val=fliplr(val);
        end

        idx_bc_val=idx_bc_val+1;
        if idx_bc_val==nallocated_bc_val
            [val_time,nallocated_bc_val]=allocate_bc_val(npreallocated,val_time,ncolumns_bc);
        end
        val_time(idx_bc_val,:)=val;

            % idx_bc_val=idx_bc_val+1;
            % if idx_bc_val==nallocated_bc_val
            %     [bc(idx_bc).val,nallocated_bc_val]=allocate_bc_val(npreallocated,bc(idx_bc).val,ncolumns_bc);
            % end
            % bc(idx_bc).val(idx_bc_val,:)=val;
        
    end

    %% block branch
    if inside_block_branch
        tokens=regexp_string_no_quotes(line);

        csl_id=tokens{1};
        idx_branch=idx_branch+1;

        if idx_branch==nallocated_csl
            [csl,nallocated_csl]=allocate_csl(npreallocated,csl);
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

    %% block compute
    if inside_block_compute
        line_number_block_compute=line_number_block_compute+1;

        if line_number_block_compute==2
            val=extractNumbers(line); 
            mdu.Tstart=val(1)*tim_factor;
            mdu.Tstop=val(2)*tim_factor;
        end
    end

    % %% block qlateral
    % if inside_block_qlateral
    % 
    % end

end %while

end %function

%%
%% FUNCTIONS
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

%%

function [bc,nallocated]=allocate_bc(npreallocated,bc)

% create a scalar struct with all the fields
template = struct( ...
    'type',               '', ...
    'branchId',           '', ...
    'chainage',            0, ...
    'name',               '', ...
    'function',           '', ...
    'time_interpolation', '', ...
    'quantity',          {''}, ...
    'unit',              {''}, ...
    'val',               0 ...
    );

% replicate the template into a 1×N struct array
bc_empty(1:npreallocated) = template;

if nargin==1
    bc=bc_empty;
else
    bc=[bc,bc_empty];
end
nallocated=numel(bc);

end %function

%%

function [structures,nallocated]=allocate_structures(npreallocated,structures)

% create a scalar struct with all the fields
template = struct( ...
    'nodeId',      '', ...
    'type',        '', ...
    'parameters',  0);

% replicate the template into a 1×N struct array
structures_empty(1:npreallocated) = template;

if nargin==1
    structures=structures_empty;
else
    structures=[structures,structures_empty];
end
nallocated=numel(structures);

end %function

%%

function [val,nallocated]=allocate_bc_val(npreallocated,val,ncolumns_bc)

val=cat(1,val,NaN(npreallocated,ncolumns_bc));
nallocated=size(val,1);

end %function

%%

%capture all numbers before a comment
%e.g.: str = '-240.  1370.   55.5   -12.3   // FOP - Donau Pg. Achleiten';
function nums = extractNumbers(str)

% If // is present, cut everything after it
beforeComment = regexp(str, '^(.*?)//', 'tokens', 'once');
if isempty(beforeComment)
    beforeComment = str; % no // found, use whole string
else
    beforeComment = beforeComment{1};
end

% Extract numbers (signed, optional decimals)
tokens = regexp(beforeComment, '(-?\d+(?:\.\d+)?)', 'match');
nums = str2double(tokens);

end %function

%%

% Parse a line into numbers, using commas as explicit NaN markers.
% Spaces separate numbers inside a comma-field.
% Consecutive commas give consecutive NaNs, but if the last comma is followed 
% by a number, no trailing NaN is inserted.
%
function nums = extracNumbers_NaN(line)

if nargin==0 || isempty(line)
    nums = [];
    return
end

% Number pattern (int, decimal, scientific, or quoted number)
numPat = '[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?';

% 1) Split on commas
parts = regexp(line, '\s*,\s*', 'split');

nums = [];
for i = 1:numel(parts)
    part = strtrim(parts{i});
    if isempty(part)
        % empty slot → NaN
        nums(end+1) = NaN; %#ok<AGROW>
    else
        % extract numbers (including those inside quotes)
        m = regexp(part, numPat, 'match');
        if ~isempty(m)
            vals = str2double(m);
            nums = [nums, vals]; %#ok<AGROW>
        end
    end
end

% Ensure row vector
nums = reshape(nums, 1, []);

end %function

%%

function [structures_at_node,nallocated_structures,idx_structure]=fill_structures_at_node(structures_at_node,nodeId,strcuture_type,val,nallocated_structures,npreallocated,idx_structure)
        
idx_structure=idx_structure+1;

if idx_structure==nallocated_structures
    [structures_at_node,nallocated_structures]=allocate_structures(npreallocated,structures_at_node);
end

structures_at_node(idx_structure).nodeId=nodeId;
structures_at_node(idx_structure).type=strcuture_type;
structures_at_node(idx_structure).parameters=val;

end %function

%%

function [bc,nallocated_bc,idx_bc]=fill_bc_header(bc,nallocated_bc,idx_bc,time_unit,name,bc_type,branchId,chainage)

idx_bc=idx_bc+1;

if idx_bc==nallocated_bc
    [bc,nallocated_bc]=allocate_bc(npreallocated,bc);
end


switch bc_type
    case {'Boundary','boundary'}
        quantity_discharge='dischargebnd';
    case {'Lateral','lateral'}
        quantity_discharge='lateral_discharge';
end

bc(idx_bc).type=bc_type;
bc(idx_bc).name=name;
bc(idx_bc).function='timeseries';
bc(idx_bc).time_interpolation='linear';
bc(idx_bc).quantity={'time',quantity_discharge};
%with timezone is best, but the GUI cannot read it
bc(idx_bc).unit={sprintf('%s since 2000-01-01 00:00:00',time_unit),'m³/s'};
% bc(idx_bc).unit={sprintf('%s since 2000-01-01 00:00:00 +00:00',time_unit),'m³/s'};
bc(idx_bc).branchId=branchId;
bc(idx_bc).chainage=chainage;

end