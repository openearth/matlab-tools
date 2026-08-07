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
%write cross-section definitions file

%INPUT:
%   -simdef.D3D.dire_sim = path to the folder where to write the file [string]
%   -simdef.csd = structure with cross-sectional info as it must be written (check by reading using S3_read_crosssectiondefinitions)
%
%OUTPUT:
%   -       
%
%NOTES:
%   -'LeveeTransitionHeight is hardcoded'

function D3D_crosssectiondefinitions(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true) %deprecated, use 'overwrite' instead
addOptional(parin,'overwrite',false)
addOptional(parin,'fname','CrossSectionDefinitions.ini')
addOptional(parin,'csd_global',NaN)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;
overwrite=parin.Results.overwrite;
fname=parin.Results.fname;
csd_global=parin.Results.csd_global;

overwrite=overwrite || ~check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;
csd=simdef.csd;  
if isnan(csd_global)
    csd_global=struct();
    csd_global.leveeTransitionHeight=0.75;
end

ncsd=numel(csd);

%% FILE

fname_destiny=fullfile(dire_sim,fname);
[fid,fname_local]=write_local_and_copy('open',fname_destiny,'overwrite',overwrite);

fprintf(fid,'%s\r\n','[General]');
fprintf(fid,'%s\r\n','   fileVersion           = 3.00');
fprintf(fid,'%s\r\n','   fileType              = crossDef');
fprintf(fid,'%s\r\n','');
fprintf(fid,'%s\r\n','[Global]');
fprintf(fid,'   leveeTransitionHeight = %5.2f\r\n',csd_global.leveeTransitionHeight);

%%
for kcsd=1:ncsd
    [type_norm,accepted_fields,required_fields,count_field]=get_csd_type_schema(csd(kcsd));
    validate_required_fields(csd(kcsd),required_fields,kcsd);
    type_raw_display=get_field_ci(csd(kcsd),'type');

    if isempty(count_field)
        nlevels=1;
    else
        nlevels=get_field_ci(csd(kcsd),count_field);
        if ~isscalar(nlevels) || ~isnumeric(nlevels) || ~isfinite(nlevels) || nlevels<1
            error('Cross-section %d has invalid %s for type %s.',kcsd,count_field,type_raw_display)
        end
        nlevels=round(nlevels);
    end

    if strcmp(type_norm,'yz')
        yCoordinates=get_field_ci(csd(kcsd),'yCoordinates');
        zCoordinates=get_field_ci(csd(kcsd),'zCoordinates');
        if numel(yCoordinates)~=nlevels || numel(zCoordinates)~=nlevels
            error('Cross-section %d (type=%s): yCoordinates/zCoordinates length must match yzCount.',kcsd,type_raw_display)
        end
    elseif strcmp(type_norm,'zwriver')
        levels=get_field_ci(csd(kcsd),'levels');
        flowWidths=get_field_ci(csd(kcsd),'flowWidths');
        totalWidths=get_field_ci(csd(kcsd),'totalWidths');
        if numel(levels)~=nlevels || numel(flowWidths)~=nlevels || numel(totalWidths)~=nlevels
            error('Cross-section %d (type=%s): levels/flowWidths/totalWidths length must match numLevels.',kcsd,type_raw_display)
        end
    elseif strcmp(type_norm,'xyz')
        xCoordinates=get_field_ci(csd(kcsd),'xCoordinates');
        yCoordinates=get_field_ci(csd(kcsd),'yCoordinates');
        zCoordinates=get_field_ci(csd(kcsd),'zCoordinates');
        if numel(xCoordinates)~=nlevels || numel(yCoordinates)~=nlevels || numel(zCoordinates)~=nlevels
            error('Cross-section %d (type=%s): x/y/z coordinate lengths must match xyzCount.',kcsd,type_raw_display)
        end
    end
    
    fprintf(fid,'%s\r\n','');
    fprintf(fid,'%s\r\n','[Definition]');
    for kfields=1:numel(accepted_fields)
        fkey=accepted_fields{kfields};
        [is_present,fkey_present]=has_field_ci(csd(kcsd),fkey);
        if ~is_present
            continue
        end
        fval=csd(kcsd).(fkey_present);
        if isempty(fval)
            continue
        end
        if isstring(fval)
            if isscalar(fval)
                fval=char(fval);
            else
                error('Cross-section %d field %s must be scalar when string type is used.',kcsd,fkey)
            end
        end

        if ischar(fval)
            fprintf(fid,'   %s = %s \r\n',fkey,fval);
        elseif isnumeric(fval) || islogical(fval)
            if numel(fval)>1
                if strcmpi(fkey,'frictionPositions')
                    expected_positions=get_expected_friction_positions_count(csd(kcsd),kcsd);
                    if numel(fval)~=expected_positions
                        error('Cross-section %d field %s has %d values but expected %d based on frictionIds.', ...
                            kcsd,fkey,numel(fval),expected_positions)
                    end
                elseif ~isempty(count_field) && numel(fval)~=nlevels
                    error('Cross-section %d field %s has %d values but expected %d.',kcsd,fkey,numel(fval),nlevels)
                end
                aux_str=repmat('%f ',1,numel(fval));
                aux_str2=sprintf('   %s = %s\r\n',fkey,aux_str);
                fprintf(fid,aux_str2,fval);
            else
                if isinteger_precision(double(fval)) %case {'yzCount','sectionCount'}
                    fprintf(fid,'   %s = %d \r\n',fkey,fval);
                else
                    fprintf(fid,'   %s = %f \r\n',fkey,fval);
                end                
            end
        else
            error('Cross-section %d field %s has unsupported class %s.',kcsd,fkey,class(fval))
        end
    end
end

write_local_and_copy('close',fid,fname_local,fname_destiny)

end %function

%%
function [type_norm,accepted_fields,required_fields,count_field]=get_csd_type_schema(csd_item)
%GET_CSD_TYPE_SCHEMA Normalize type and return accepted/required fields.

[has_type,fkey_type]=has_field_ci(csd_item,'type');
if ~has_type || isempty(csd_item.(fkey_type))
    error('Cross-section definitions require non-empty field "type" for every section.')
end

type_value=csd_item.(fkey_type);
if isstring(type_value)
    if ~isscalar(type_value)
        error('Cross-section field "type" must be a scalar string/char.')
    end
    type_raw=char(type_value);
else
    type_raw=type_value;
end

if ~ischar(type_raw)
    error('Cross-section field "type" must be char or scalar string.')
end

type_norm=lower(strtrim(type_raw));
switch type_norm
    case {'zwriver','zw'}
        type_norm='zwriver';
        accepted_fields={ ...
            'id','type','thalweg','numLevels','levels','flowWidths','totalWidths', ...
            'leveeCrestLevel','leveeFlowArea','leveeTotalArea','leveeBaseLevel', ...
            'mainWidth','fp1Width','fp2Width','isShared','frictionIds'};
        required_fields={'id','type','thalweg','numLevels','levels','flowWidths','totalWidths'};
        count_field='numLevels';
    case 'yz'
        accepted_fields={'id','type','thalweg','yzCount','yCoordinates','zCoordinates','conveyance','sectionCount','frictionIds','frictionPositions','singleValuedZ'};
        required_fields={'id','type','thalweg','yzCount','yCoordinates','zCoordinates'};
        count_field='yzCount';
    case 'xyz'
        accepted_fields={'id','type','thalweg','xyzCount','xCoordinates','yCoordinates','zCoordinates','conveyance','sectionCount','frictionIds'};
        required_fields={'id','type','thalweg','xyzCount','xCoordinates','yCoordinates','zCoordinates'};
        count_field='xyzCount';
    case 'rectangle'
        accepted_fields={'id','type','thalweg','width','height','closed'};
        required_fields={'id','type','thalweg','width','height'};
        count_field='';
    case 'circle'
        accepted_fields={'id','type','thalweg','diameter','frictionId'};
        required_fields={'id','type','diameter'};
        count_field='';
    otherwise
        error('Unsupported cross-section type "%s". Supported types: zw, zwriver, yz, xyz, rectangle, circle.',type_raw)
end

end %function get_csd_type_schema

%%
function validate_required_fields(csd_item,required_fields,kcsd)
%VALIDATE_REQUIRED_FIELDS Ensure required fields exist and are non-empty.

missing=cell(0,1);
present_fields=fieldnames(csd_item);

for k=1:numel(required_fields)
    fkey_required=required_fields{k};
    idx_match=find(strcmpi(fkey_required,present_fields),1,'first');

    if isempty(idx_match)
        missing{end+1,1}=fkey_required; %#ok<AGROW>
        continue
    end

    fkey_present=present_fields{idx_match};
    if isempty(csd_item.(fkey_present))
        missing{end+1,1}=fkey_required; %#ok<AGROW>
    end
end

if ~isempty(missing)
    type_text='<unknown>';
    [has_type,fkey_type]=has_field_ci(csd_item,'type');
    if has_type && ~isempty(csd_item.(fkey_type))
        type_text=csd_item.(fkey_type);
        if isstring(type_text) && isscalar(type_text)
            type_text=char(type_text);
        end
    end

    error('Cross-section %d (type=%s) missing required fields: %s', ...
        kcsd,type_text,strjoin(missing,', '))
end

end %function validate_required_fields

%%
function [is_present,field_name_present]=has_field_ci(st,field_name)
%HAS_FIELD_CI Return case-insensitive field existence and actual name.

field_name_present='';
is_present=false;
if ~isstruct(st)
    return
end

fnames=fieldnames(st);
idx=find(strcmpi(field_name,fnames),1,'first');
if isempty(idx)
    return
end

is_present=true;
field_name_present=fnames{idx};

end %function has_field_ci

%%
function field_value=get_field_ci(st,field_name)
%GET_FIELD_CI Read a field value using case-insensitive lookup.

[is_present,field_name_present]=has_field_ci(st,field_name);
if ~is_present
    error('Field "%s" was not found (case-insensitive lookup).',field_name)
end

field_value=st.(field_name_present);

end %function get_field_ci

%%
function expected_positions=get_expected_friction_positions_count(csd_item,kcsd)
%GET_EXPECTED_FRICTION_POSITIONS_COUNT Return expected number of positions.

[has_friction_ids,fkey_ids]=has_field_ci(csd_item,'frictionIds');
if ~has_friction_ids || isempty(csd_item.(fkey_ids))
    error('Cross-section %d has frictionPositions but missing frictionIds.',kcsd)
end

friction_ids_raw=csd_item.(fkey_ids);
if isstring(friction_ids_raw)
    if ~isscalar(friction_ids_raw)
        error('Cross-section %d field frictionIds must be scalar when string type is used.',kcsd)
    end
    friction_ids_raw=char(friction_ids_raw);
end

if ~ischar(friction_ids_raw)
    error('Cross-section %d field frictionIds must be char or scalar string.',kcsd)
end

friction_ids_split=strsplit(strtrim(friction_ids_raw),';');
friction_ids_split=friction_ids_split(~cellfun(@isempty,strtrim(friction_ids_split)));
if isempty(friction_ids_split)
    error('Cross-section %d field frictionIds does not contain valid IDs.',kcsd)
end

% frictionPositions defines boundaries, so it has one more element than IDs.
expected_positions=numel(friction_ids_split)+1;

end %function get_expected_friction_positions_count
