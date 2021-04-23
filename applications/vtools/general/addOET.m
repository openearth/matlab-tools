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

%     %default
% use_drive_default=1; %1=C; 2=P;
% path_oet_c_default='c:\Users\chavarri\checkouts\openearthtools_matlab\oetsettings.m';
% % path_oet_p_default=fullfile('11205258-016-kpp2020rmm-3d','E_Software_Scripts','repositories','openearthtools_matlab','oetsettings.m');
% path_oet_p_default=fullfile('dflowfm','projects','2020_d-morphology','modellen','checkout','openearthtools_matlab','oetsettings.m');
% 
%     %parse
% parin=inputParser;
% 
% addOptional(parin,'use_drive',use_drive_default,@isnumeric)
% addOptional(parin,'path_oet_c',path_oet_c_default,@ischar)
% addOptional(parin,'path_oet_p',path_oet_p_default,@ischar)
% 
% parse(parin,varargin{:});
% 
% use_drive=parin.Results.use_drive;
% path_oet_c=parin.Results.path_oet_c;
% path_oet_p=parin.Results.path_oet_p;

    %% who am I?
    
switch path_oet(1)
    case 'p'
end

[~,name]=system('hostname');
if ispc
%     path_drive_p='p:\';
elseif isunix        
    if contains(name,'bullx') %cartesius
        path_oet(1:3)='';
        path_oet=fullfile('/projects/0/hisigem/',path_oet);
    end
else
    error('adapt the paths')
end

    
    %% add paths


%     switch use_drive
%         case 1
%             fprintf('Using repository at %s \n',path_oet_c)
%             path_oet=path_oet_c;
%         case 2
%             fprintf('Using repository at %s \n',path_oet_p)
%             path_oet=path_oet_p;
%         otherwise
%             error('ups...')
%     end

    fprintf('Start adding repository at %s \n',path_oet);
    run(path_oet);
else
    path_oet=which('oetsettings');
end

fprintf('Using repository at %s \n',path_oet)

end %function