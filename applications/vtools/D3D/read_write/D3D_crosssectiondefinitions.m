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

    if isempty(count_field)
        nlevels=1;
    else
        nlevels=csd(kcsd).(count_field);
        if ~isscalar(nlevels) || ~isnumeric(nlevels) || ~isfinite(nlevels) || nlevels<1
            error('Cross-section %d has invalid %s for type %s.',kcsd,count_field,csd(kcsd).type)
        end
        nlevels=round(nlevels);
    end

    if strcmp(type_norm,'yz')
        if numel(csd(kcsd).yCoordinates)~=nlevels || numel(csd(kcsd).zCoordinates)~=nlevels
            error('Cross-section %d (type=%s): yCoordinates/zCoordinates length must match yzCount.',kcsd,csd(kcsd).type)
        end
    elseif strcmp(type_norm,'zwriver')
        if numel(csd(kcsd).levels)~=nlevels || numel(csd(kcsd).flowWidths)~=nlevels || numel(csd(kcsd).totalWidths)~=nlevels
            error('Cross-section %d (type=%s): levels/flowWidths/totalWidths length must match numLevels.',kcsd,csd(kcsd).type)
        end
    elseif strcmp(type_norm,'xyz')
        if numel(csd(kcsd).xCoordinates)~=nlevels || numel(csd(kcsd).yCoordinates)~=nlevels || numel(csd(kcsd).zCoordinates)~=nlevels
            error('Cross-section %d (type=%s): x/y/z coordinate lengths must match xyzCount.',kcsd,csd(kcsd).type)
        end
    end
    
    fprintf(fid,'%s\r\n','');
    fprintf(fid,'%s\r\n','[Definition]');
    for kfields=1:numel(accepted_fields)
        fkey=accepted_fields{kfields};
        if ~isfield(csd(kcsd),fkey)
            continue
        end
        fval=csd(kcsd).(fkey);
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
                if ~isempty(count_field) && numel(fval)~=nlevels
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

if ~isfield(csd_item,'type') || isempty(csd_item.type)
    error('Cross-section definitions require non-empty field "type" for every section.')
end

if isstring(csd_item.type)
    if ~isscalar(csd_item.type)
        error('Cross-section field "type" must be a scalar string/char.')
    end
    type_raw=char(csd_item.type);
else
    type_raw=csd_item.type;
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
        accepted_fields={'id','type','thalweg','yzCount','yCoordinates','zCoordinates','conveyance','sectionCount','frictionIds'};
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
for k=1:numel(required_fields)
    fkey=required_fields{k};
    if ~isfield(csd_item,fkey) || isempty(csd_item.(fkey))
        missing{end+1,1}=fkey; %#ok<AGROW>
    end
end

if ~isempty(missing)
    error('Cross-section %d (type=%s) missing required fields: %s', ...
        kcsd,csd_item.type,strjoin(missing,', '))
end

end %function validate_required_fields
