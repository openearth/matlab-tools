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
%morphological initial file creation

%INPUT:
%
%OUTPUT:
%   

function D3D_crosssectiondefinitions(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
csd=simdef.csd;  

ncsd=numel(csd);
fields_csd=fields(csd);
nfields=numel(fields_csd);

%% FILE

kl=1;
%%
data{kl,1}=        '[General]'; kl=kl+1;
data{kl,1}=        '   fileVersion           = 3.00'; kl=kl+1;
data{kl,1}=        '   fileType              = crossDef'; kl=kl+1;
%% 
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Global]'; kl=kl+1;
data{kl,1}=        '   leveeTransitionHeight = 0.75'; kl=kl+1;
%%
for kcsd=1:ncsd
    nlevels=csd(kcsd).numLevels;
    
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Definition]'; kl=kl+1;
    for kfields=1:nfields
        if ischar(csd(kcsd).(fields_csd{kfields}))
            switch fields_csd{kfields}
                case 'id'
                    data{kl,1}=sprintf('   %s = #%s# ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
                otherwise
                    data{kl,1}=sprintf('   %s = %s ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            end
        else %double
            if numel(csd(kcsd).(fields_csd{kfields}))>1
                aux_str=repmat('%f ',1,nlevels);
                aux_str2=sprintf('   %s = %s ',fields_csd{kfields},aux_str);
                data{kl,1}=sprintf(aux_str2,csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            else
                data{kl,1}=sprintf('   %s = %f ',fields_csd{kfields},csd(kcsd).(fields_csd{kfields})); kl=kl+1;
            end
            
        end
    end
end

%% WRITE

file_name=fullfile(dire_sim,'CrossSectionDefinitions.ini');
writetxt(file_name,data)
