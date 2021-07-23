%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17427 $
%$Date: 2021-07-22 12:14:33 +0200 (Thu, 22 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_create_etab_perturbation_files.m 17427 2021-07-22 10:14:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_create_etab_perturbation_files.m $
%
%copy file with check

function [sts,msg]=copyfile_check(source_f,destin_f)

    messageOut(NaN,sprintf('starting to copy file: %s',source_f));
    [sts,msg]=copyfile(source_f,destin_f);
    if ~sts
        fprintf('%s \n',msg);
    else
        messageOut(NaN,sprintf('file copied to: %s',destin_f));
    end
    
end %function
