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
%%Pack or unpack the variables of a 1D grid structure.
%
%Pack:
%   network=NC_1D_grid_variables('pack');
%The variables listed below are evaluated in the caller workspace.
%
%Unpack:
%   [epsg,network_edge_nodes,...,mesh1d_edge_nodes]= ...
%       NC_1D_grid_variables('unpack',network);
%The output order is the order of variable_names below.

function varargout=NC_1D_grid_variables(mode,varargin)

variable_names={...
    'epsg',...
    'network_edge_nodes','network_branch_id','network_branch_long_name',...
    'network_edge_length','network_node_id','network_node_long_name',...
    'network_node_x','network_node_y','network_geom_node_count',...
    'network_geom_x','network_geom_y','network_branch_order','network_branch_type',...
    'mesh1d_node_branch','mesh1d_node_offset','mesh1d_node_x','mesh1d_node_y',...
    'mesh1d_edge_branch','mesh1d_edge_offset','mesh1d_edge_x','mesh1d_edge_y',...
    'mesh1d_node_id','mesh1d_node_long_name','mesh1d_edge_nodes'};
varargout=cell(1,nargout);

switch lower(mode)
    case 'pack'
        if nargin~=1 || nargout~=1
            error('NC_1D_grid_variables:packArguments', ...
                'Pack requires no inputs after mode and one output.')
        end

        network=struct();
        for k=1:numel(variable_names)
            network.(variable_names{k})=evalin('caller',variable_names{k});
        end
        varargout{1}=network;

    case 'unpack'
        if nargin~=2
            error('NC_1D_grid_variables:unpackArguments', ...
                'Unpack requires a network structure as input.')
        end
        if nargout~=numel(variable_names)
            error('NC_1D_grid_variables:unpackOutputs', ...
                'Unpack requires %d outputs.',numel(variable_names))
        end

        network=varargin{1};
        for k=1:numel(variable_names)
            varargout{k}=network.(variable_names{k});
        end

    otherwise
        error('NC_1D_grid_variables:mode', ...
            'Unknown mode "%s". Use "pack" or "unpack".',mode)
end

end
