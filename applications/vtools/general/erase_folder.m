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
function erase_folder(dire_in,runid_serie,runid_number)

    time_d=5; %seconds delay
    warning('off','backtrace');
    for kt=time_d:-1:0
        warning('You are going to erase the simulation %s%s in %d seconds',runid_serie,runid_number,kt);
        pause(1)
    end
    warning('on','backtrace');
    fclose all;
    dire=dir(dire_in);
    for kf=3:numel(dire)
        if ispc
            if exist(fullfile(dire_in,dire(kf).name),'dir')==7
                dos(sprintf('RD /S /Q %s',fullfile(dire_in,dire(kf).name)));
            elseif exist(fullfile(dire_in,dire(kf).name),'file')
                dos(sprintf('DEL %s',fullfile(dire_in,dire(kf).name)));
            end
        elseif ismac
            error('Are you seriously using a Mac? Come on... You will have to manually erase the folder and set erase_previous to 0')
        else
            error('You will have to manually erase the folder and set erase_previous to 0')
        end
    end
end