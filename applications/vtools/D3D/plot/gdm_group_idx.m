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
        varname=[];
        if numel(varargin)>1
            varname=varargin{2};
        end
        varargout{1}=group_data(fid_log,flg_loc,varargin{1},varname);
        
    otherwise
        error('Unknown method: %s',method);
end

end %function

%%
%% SUBFUNCTIONS
%%

function [flg_loc,in_p]=initialize_grouping(fid_log,flg_loc,simdef,varname,in_p)
%INITIALIZE_GROUPING Determine grouping indices based on grain sizes

% Clear per-variable grouping state left by a previous variable.
if isfield(flg_loc,'sediment_class_idx')
    flg_loc=rmfield(flg_loc,'sediment_class_idx');
end
if isfield(flg_loc,'sediment_class_names')
    flg_loc=rmfield(flg_loc,'sediment_class_names');
end
if isfield(in_p,'group_idx_classes')
    previous_classes=in_p.group_idx_classes;
    if isfield(in_p,'leg_str') && isequal(in_p.leg_str,previous_classes)
        in_p.leg_str=[];
    end
end
in_p.group_idx_classes={};

%% CHECK CONDITIONS

% Check if grouping is requested
if ~isfield(flg_loc,'group_idx') || isempty(flg_loc.group_idx)
    return
end

% Preserve the original HIS behavior unless the user specifies variables.
if ~is_grouped_variable(flg_loc,varname)
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
        
        % User-provided limits are in meters and class names map to the
        % intervals defined by those limits.
        default_limits=[0.002,8.00e-03,3.15e-02,6.30e-02,2.56e-01];
        default_names={'sand','fine gravel','coarse gravel','very coarse gravel','cobbles','boulders'};
        custom_limits=isfield(flg_loc,'group_idx_limits') && ~isempty(flg_loc.group_idx_limits);
        if custom_limits
            class_limits=flg_loc.group_idx_limits;
        else
            class_limits=default_limits;
        end
        if isfield(flg_loc,'group_idx_classes') && ~isempty(flg_loc.group_idx_classes)
            class_names_all=flg_loc.group_idx_classes;
        else
            class_names_all=default_names;
        end

        if ~isnumeric(class_limits) || ~isvector(class_limits) || isempty(class_limits) || ...
                any(~isfinite(class_limits)) || any(class_limits<=0) || any(diff(class_limits)<=0)
            error('group_idx_limits must be a strictly increasing vector of positive grain diameters in meters.')
        end
        class_limits=double(class_limits(:)');

        if isstring(class_names_all)
            class_names_all=cellstr(class_names_all(:)');
        end
        if ~iscellstr(class_names_all) || numel(class_names_all)~=numel(class_limits)+1 || ...
                any(cellfun(@isempty,class_names_all))
            error('group_idx_classes must contain one non-empty class name per interval (numel(group_idx_limits)+1).')
        end
        class_names_all=reshape(class_names_all,1,[]);

        class_idx_all=cell(1,numel(class_names_all));
        if custom_limits
            class_idx_all{1}=find(dk<class_limits(1));
            if numel(class_names_all)==2
                class_idx_all{2}=find(dk>=class_limits(1));
            else
                for kc=2:numel(class_names_all)-1
                    if kc==numel(class_names_all)-1
                        class_idx_all{kc}=find(dk>=class_limits(kc-1) & dk<=class_limits(kc));
                    else
                        class_idx_all{kc}=find(dk>=class_limits(kc-1) & dk<class_limits(kc));
                    end
                end
                class_idx_all{end}=find(dk>class_limits(end));
            end
        else
            % Keep the original upper-exclusive boundaries for HIS plots.
            for kf=1:nf
                kc=find(dk(kf)<class_limits,1,'first');
                if isempty(kc)
                    kc=numel(class_limits)+1;
                end
                class_idx_all{kc}(end+1)=kf;
            end
        end
        
        % Store class indices (only non-empty classes)
        class_idx=cell(1,numel(class_idx_all));
        class_names=cell(1,numel(class_idx_all));
        n_classes=0;
        for kc=1:numel(class_idx_all)
            if ~isempty(class_idx_all{kc})
                n_classes=n_classes+1;
                class_idx{n_classes}=class_idx_all{kc};
                class_names{n_classes}=class_names_all{kc};
            end
        end
        class_idx=class_idx(1:n_classes);
        class_names=class_names(1:n_classes);
        
        n_classes=numel(class_idx);
        
        % Store in flg_loc
        flg_loc.sediment_class_idx=class_idx;
        flg_loc.sediment_class_names=class_names;
        in_p.group_idx_classes=class_names;
        in_p.leg_str=class_names;
        in_p.do_area=true;
        in_p.frac=[];
        
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

function val=group_data(~,flg_loc,val,varname)
%GROUP_DATA Apply grouping to data by summing fractions within each class

%% CHECK CONDITIONS

if nargin>3 && ~isempty(varname) && ~is_grouped_variable(flg_loc,varname)
    return
end

% Check if grouping indices exist
if ~isfield(flg_loc,'sediment_class_idx') || isempty(flg_loc.sediment_class_idx)
    return
end

%% APPLY GROUPING

class_idx=flg_loc.sediment_class_idx;

if isstruct(val)
    fn=fieldnames(val);
    for kv=1:numel(val)
        for kf=1:numel(fn)
            val_field=val(kv).(fn{kf});
            if isnumeric(val_field)
                val(kv).(fn{kf})=group_numeric_data(val_field,class_idx,varname);
            end
        end
    end
    return
end

val=group_numeric_data(val,class_idx,varname);

end %function

%%

function val=group_numeric_data(val,class_idx,varname)

val=squeeze(val);

if ~isnumeric(val) || ~ismatrix(val)
    error('Sediment class grouping expects a numeric 2-D data array.')
end

n_classes=numel(class_idx);
max_idx=max(cellfun(@max,class_idx));
if size(val,2)~=max_idx
    if isempty(varname)
        varname='unknown';
    end
    error('Cannot group %s data: expected %d fraction columns but received %d.',varname,max_idx,size(val,2))
end

% Get original data dimensions
[nt,~]=size(val);

% Initialize grouped data
val_grouped=zeros(nt,n_classes);

% Sum fractions within each class
for kc=1:n_classes
    idx=class_idx{kc};
    if isscalar(idx)
        val_grouped(:,kc)=val(:,idx);
    else
        val_grouped(:,kc)=sum(val(:,idx),2);
    end
end

% Replace data with grouped data
val=val_grouped;
end %function
%%

function do_group=is_grouped_variable(flg_loc,varname)

if isfield(flg_loc,'group_idx_var')
    group_var=flg_loc.group_idx_var;
    if isempty(group_var)
        do_group=false;
        return
    end
    if ischar(group_var)
        group_var={group_var};
    elseif isstring(group_var)
        group_var=cellstr(group_var(:)');
    end
    if ~iscellstr(group_var)
        error('group_idx_var must be a character vector, string array, or cell array of character vectors.')
    end
    do_group=any(strcmp(varname,group_var));
else
    do_group=strcmp(varname,'scum');
end

end %function
