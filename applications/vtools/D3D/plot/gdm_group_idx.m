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
%GDM_GROUP_IDX groups sediment fractions into sediment classes based on grain size

function varargout=gdm_group_idx(method,fid_log,flg_loc,simdef,varargin)

switch method
    case 'initialize'
        [varargout{1:2}]=initialize_grouping(fid_log,flg_loc,simdef,varargin{1:2});
        
    case 'group'
        varargout{1}=group_data(fid_log,flg_loc,varargin{1});
        
    otherwise
        error('Unknown method: %s',method);
end

end %function

%%
%% SUBFUNCTIONS
%%

function [flg_loc,in_p]=initialize_grouping(fid_log,flg_loc,simdef,varname,in_p)
%INITIALIZE_GROUPING Determine grouping indices based on grain sizes

%% CHECK CONDITIONS

% Only process 'scum' variable
if ~strcmp(varname,'scum')
    return
end

% Check if grouping is requested
if ~isfield(flg_loc,'group_idx') || isempty(flg_loc.group_idx)
    return
end

%% PROCESS SEDIMENT CLASSES

switch flg_loc.group_idx
    case 'sediment_classes'
        
        % Get grain sizes from sediment file
        dk=gdm_read_dk(simdef(1));
        
        if isempty(dk)
            messageOut(fid_log,'Warning: No sediment data found. Cannot group sediment classes.');
            return
        end
        
        nf=numel(dk); % number of fractions
        
        % Define sediment class boundaries (in meters)
        limit.sand=0.002; 
        limit.fine_gravel=8.00e-03; 
        limit.coarse_gravel=3.15e-02;
        limit.very_coarse_gravel=6.30e-02;
        limit.cobbles=2.56e-01;
        
        % Initialize class indices
        idx_sand=[];
        idx_fine_gravel=[];
        idx_coarse_gravel=[];
        idx_very_coarse_gravel=[];
        idx_cobbles=[];
        idx_boulders=[];
        
        % Categorize each fraction into a sediment class
        for kf=1:nf
            if dk(kf) < limit.sand
                idx_sand=[idx_sand,kf];
            elseif dk(kf) < limit.fine_gravel
                idx_fine_gravel=[idx_fine_gravel,kf];
            elseif dk(kf) < limit.coarse_gravel
                idx_coarse_gravel=[idx_coarse_gravel,kf];
            elseif dk(kf) < limit.very_coarse_gravel
                idx_very_coarse_gravel=[idx_very_coarse_gravel,kf];
            elseif dk(kf) < limit.cobbles
                idx_cobbles=[idx_cobbles,kf];
            else
                idx_boulders=[idx_boulders,kf];
            end
        end
        
        % Store class indices (only non-empty classes)
        class_idx_all={idx_sand,idx_fine_gravel,idx_coarse_gravel,idx_very_coarse_gravel,idx_cobbles,idx_boulders};
        class_names_all={'sand','fine_gravel','coarse_gravel','very_coarse_gravel','cobbles','boulders'};
        
        % Keep only classes with fractions
        class_idx={};
        class_names={};
        for kc=1:numel(class_idx_all)
            if ~isempty(class_idx_all{kc})
                class_idx{end+1}=class_idx_all{kc};
                class_names{end+1}=class_names_all{kc};
            end
        end
        
        n_classes=numel(class_idx);
        
        % Store in flg_loc
        flg_loc.sediment_class_idx=class_idx;
        in_p.leg_str=class_names;
        in_p.do_area=true;
        
        % Log grouping information
        messageOut(fid_log,sprintf('Grouping %d sediment fractions into %d sediment classes',nf,n_classes));
        for kc=1:n_classes
            messageOut(fid_log,sprintf('  Class %d (%s): %d fractions (indices: %s)',kc,class_names{kc},numel(class_idx{kc}),mat2str(class_idx{kc})));
        end
        
    otherwise
        messageOut(fid_log,sprintf('Warning: Unknown grouping method: %s',flg_loc.group_idx));
end

end %function

%%

function val=group_data(~,flg_loc,val)
%GROUP_DATA Apply grouping to data by summing fractions within each class

%% CHECK CONDITIONS

% Check if grouping indices exist
if ~isfield(flg_loc,'sediment_class_idx') || isempty(flg_loc.sediment_class_idx)
    return
end

%% APPLY GROUPING

class_idx=flg_loc.sediment_class_idx;
n_classes=numel(class_idx);

% Get original data dimensions
[nt,~]=size(val);

% Initialize grouped data
val_grouped=zeros(nt,n_classes);

% Sum fractions within each class
for kc=1:n_classes
    idx=class_idx{kc};
    if numel(idx)==1
        val_grouped(:,kc)=val(:,idx);
    else
        val_grouped(:,kc)=sum(val(:,idx),2);
    end
end

% Replace data with grouped data
val=val_grouped;

end %function
