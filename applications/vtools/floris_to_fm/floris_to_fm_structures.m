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
%Convert the FLORIS data about structures, which are located at nodes, to
%Delft3D data about structures, which are located at a chainage in a
%branch.

function structures=floris_to_fm_structures(structures_at_node,network,fname_bc_pump,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% CALC

structures.General.fileVersion='2.00';
structures.General.fileType='structure';

nodes_with_structures={structures_at_node.nodeId};
nodes_with_structures_u=unique(nodes_with_structures);
nsnu=numel(nodes_with_structures_u);

idx_structures=0;

for ksnu=1:nsnu
    % ksnu=1;
    nodeId=nodes_with_structures_u{ksnu}; %local nodeId under consideration
    bol_structures=ismember(nodes_with_structures,nodeId); %boolean of structures at same node
    structures_loc=structures_at_node(bol_structures); %structures at same node
    nsl=numel(structures_loc); %number of structures at same node
    structureIds='';

    for ksl=1:nsl
        idx_structures=idx_structures+1;

        nodeId_loc_2=structures_loc(ksl).nodeId; %should be the same as `nodeId`
        type_loc_2=structures_loc(ksl).type; 
        parameters_loc_2=structures_loc(ksl).parameters; 
        np=numel(parameters_loc_2);

        switch type_loc_2
            case 'weir'
                %Default parameters
                slope_def=999; %default value in FLORIS, not used in FM for weir, yes for General Structure. Add if needed.
                corrCoeff_def=0.63; %ATTENTION! In FLORIS is the coefficient of Poleni, may be different in FM. 
                corrCoeff2_def=4; %ATTENTION! Default value in FLORIS. Has to do with flood conditions, but it is unclear. Investigate and use properly.
        
                %Assign default parameters
                slope=slope_def;
                corrCoeff=corrCoeff_def;
                corrCoeff2=corrCoeff2_def;
                if np<2
                    error('At least the crestlevel and width should be given.')
                end
                crestLevel=parameters_loc_2(1);
                crestWidth=parameters_loc_2(2);
                if np>=3 
                    if ~isnan(parameters_loc_2(3))
                        slope=parameters_loc_2(3);
                    end
                end
                if np>=4 
                    if ~isnan(parameters_loc_2(4))
                        corrCoeff=parameters_loc_2(4);
                    end
                end
                if np>=5
                    if ~isnan(parameters_loc_2(5))
                        corrCoeff2=parameters_loc_2(5);
                    end
                end
            case 'gate'
                %Default parameters 
                %ATTENTION! Check meaning and translation to FM
                factor_1_def=999; %mueg
                factor_2_def=4;  %zetag
                factor_3_def=999; %muew
                factor_4_def=4; %zetaw
        
                %Assign default parameters
                factor_1=factor_1_def;
                factor_2=factor_2_def;
                factor_3=factor_3_def;
                factor_4=factor_4_def;
                if np<3
                    error('At least the crestLevel, gateLowerEdgeLevel, and gateOpeningWidth should be given.')
                end
                crestLevel=parameters_loc_2(1);
                gateLowerEdgeLevel=parameters_loc_2(2);
                gateOpeningWidth=parameters_loc_2(3);
                if np>=4
                    if ~isnan(parameters_loc_2(4))
                        factor_1=parameters_loc_2(4);
                    end
                end
                if np>=5 
                    if ~isnan(parameters_loc_2(5))
                        factor_2=parameters_loc_2(5);
                    end
                end
                if np>=6
                    if ~isnan(parameters_loc_2(6))
                        factor_3=parameters_loc_2(6);
                    end
                end
                if np>=7
                    if ~isnan(parameters_loc_2(7))
                        factor_4=parameters_loc_2(7);
                    end
                end
            case 'pump'

            otherwise
                error('Implement')
        end

        %Branch and chainage
        %Take the length of the branch in which that end node is found.
        dest_nodes_idx=network.network_edge_nodes(:,2)+1; %Matlab index of the destination node of each branch
        node_idx=find(strcmp(network.network_node_id,nodeId)); %Matlab index of the node 
        if numel(node_idx)~=1
            error('We only expect to match one node.')
        end
        idx_branch=find(dest_nodes_idx==node_idx); %Matlab index of the branch whose end node is the node under consideration
        if numel(idx_branch)~=1
            error('We only expect to match one branch.')
        end
        branchId=network.network_branch_id{idx_branch};
        chainage=network.network_edge_length(idx_branch);

        chapter=sprintf('Structure%d',idx_structures);
        % id=floris_to_fm_structure_name(nodeId_loc_2,type_loc_2,ksl);
        id=sprintf('%s_%s_%d',nodeId_loc_2,type_loc_2,ksl);

        structures.(chapter).id=id;
        structures.(chapter).name=id;
        structures.(chapter).branchId=branchId;
        structures.(chapter).chainage=chainage;
        structures.(chapter).type=type_loc_2;
        switch type_loc_2
            case 'weir'
                structures.(chapter).crestWidth=crestWidth;
                structures.(chapter).allowedFlowDir='both'; 
                structures.(chapter).corrCoeff=corrCoeff;
                structures.(chapter).crestLevel=crestLevel;
            case 'gate'
                structures.(chapter).gateLowerEdgeLevel=gateLowerEdgeLevel;
                structures.(chapter).gateOpeningWidth=gateOpeningWidth;
                structures.(chapter).gateHeight=9999; %flow cannot overtop the gate
                structures.(chapter).gateOpeningHorizontalDirection='symmetric';
                structures.(chapter).crestLevel=crestLevel;
            case 'pump'
                structures.(chapter).capacity=fname_bc_pump;
                %ATTENTION! `time_series` is not a true parameter in the
                %block [structures]. We use it here to pass the information
                %to the place where we write the time series of the pump
                %capacity.
                structures.(chapter).controlSide='both';  %Only required/used when numStages >0, necessary for GUI reading
                structures.(chapter).time_series=parameters_loc_2; 
            otherwise
                error('Implement')
        end

        %for compound
        structureIds=cat(2,structureIds,';');
        structureIds=cat(2,structureIds,id);
    end %nsl

    structureIds(1)=''; %remove first semicolon

    %make compound
    if nsl>1
        idx_structures=idx_structures+1;
        chapter=sprintf('Structure%d',idx_structures);
        id=sprintf('%s_compound',nodeId_loc_2);

        structures.(chapter).type='compound';
        structures.(chapter).id=id;
        structures.(chapter).numStructures=nsl;
        structures.(chapter).structureIds=structureIds;
    end

end %nsnu

end %function
