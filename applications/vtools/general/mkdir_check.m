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

function mkdir_check(path_dir)

if exist(path_dir,'dir')~=7
    [status,msg]=mkdir(path_dir);
    if status==1
        messageOut(NaN,sprintf('folder created: %s',path_dir))
    else
        fprintf('Could not create folder %s because %s \n',path_dir,msg);
    end
end

end