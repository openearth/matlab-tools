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
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function addOET(path_v_gen)

if exist('oetsettings','file')~=2
    
    %% parse

    path_oet=fullfile(path_v_gen,'../','../','../','oetsettings.m');
    path_oet=strrep(path_oet,'\','/');

    %% modify path
    
    %when running in Cartesius, the path needed to be modified. 
    %if necessary, uncomment and clean this part of the code
    %making it general enough
    
%     switch path_oet(1)
%         case 'p'
%     end
% 
%     [~,name]=system('hostname');
%     if ispc
%     %     path_drive_p='p:\';
%     elseif isunix        
%         if contains(name,'bullx') %cartesius
%             path_oet(1:3)='';
%             path_oet=fullfile('/projects/0/hisigem/',path_oet);
%         end
%     else
%         error('adapt the paths')
%     end

    %% add repository
    
    fprintf('Start adding repository at %s \n',path_oet);
    run(path_oet);
else
    path_oet=which('oetsettings');
end

fprintf('Using repository at %s \n',path_oet)

end %function