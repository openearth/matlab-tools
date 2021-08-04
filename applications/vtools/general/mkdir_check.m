%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17305 $
%$Date: 2021-05-20 22:33:45 +0200 (Thu, 20 May 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17305 2021-05-20 20:33:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
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