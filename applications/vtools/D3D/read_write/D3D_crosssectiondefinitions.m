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

addOptional(parin,'check_existing',true)
addOptional(parin,'fname','CrossSectionDefinitions.ini')
addOptional(parin,'csd_global',NaN)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;
fname=parin.Results.fname;
csd_global=parin.Results.csd_global;

%% RENAME

dire_sim=simdef.D3D.dire_sim;
csd=simdef.csd;  
if isnan(csd_global)
    csd_global=struct();
    csd_global.leveeTransitionHeight=0.75;
end

ncsd=numel(csd);
fields_csd=fields(csd);
nfields=numel(fields_csd);

%% FILE

fname_destiny=fullfile(dire_sim,fname);
[fid,fname_local]=write_local_and_copy('open',fname_destiny,'overwrite',~check_existing);

fprintf(fid,'%s\r\n','[General]');
fprintf(fid,'%s\r\n','   fileVersion           = 3.00');
fprintf(fid,'%s\r\n','   fileType              = crossDef');
fprintf(fid,'%s\r\n','');
fprintf(fid,'%s\r\n','[Global]');
fprintf(fid,'   leveeTransitionHeight = %5.2f\r\n',csd_global.leveeTransitionHeight);

%%
for kcsd=1:ncsd
    switch lower(csd(kcsd).type)
        case 'yz'
            nlevels=csd(kcsd).yzCount;
        case 'zwriver'
            nlevels=csd(kcsd).numLevels;
        otherwise
            error('unknown number of levels for type: %s',csd(kcsd).type)
    end
    
    fprintf(fid,'%s\r\n','');
    fprintf(fid,'%s\r\n','[Definition]');
    for kfields=1:nfields
        if isempty(csd(kcsd).(fields_csd{kfields}))
            continue
        end
        if ischar(csd(kcsd).(fields_csd{kfields}))
            fprintf(fid,'   %s = %s \r\n',fields_csd{kfields},csd(kcsd).(fields_csd{kfields}));
        else %double
            if numel(csd(kcsd).(fields_csd{kfields}))>1
                aux_str=repmat('%f ',1,nlevels);
                aux_str2=sprintf('   %s = %s\r\n',fields_csd{kfields},aux_str);
                fprintf(fid,aux_str2,csd(kcsd).(fields_csd{kfields}));  
            else
                if isinteger_precision(csd(kcsd).(fields_csd{kfields})) %case {'yzCount','sectionCount'}
                    fprintf(fid,'   %s = %d \r\n',fields_csd{kfields},csd(kcsd).(fields_csd{kfields}));
                else
                    fprintf(fid,'   %s = %f \r\n',fields_csd{kfields},csd(kcsd).(fields_csd{kfields}));
                end                
            end
        end
    end
end

write_local_and_copy('close',fid,fname_local,fname_destiny)

end %function
