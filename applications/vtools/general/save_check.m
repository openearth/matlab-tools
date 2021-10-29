%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17498 $
%$Date: 2021-09-29 08:53:15 +0200 (Wed, 29 Sep 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17498 2021-09-29 06:53:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function save_check(fpath_mat,str_save)

[fdir,fname,fext]=fileparts(fpath_mat);
mkdir_check(fdir);
if isempty(fname)
    fpath_mat=fullfile(fdir,sprintf('matfile_%f.mat',datenum(datetime('now'))));
end
if strcmp(fext,'.mat')==0
    messageOut(NaN,'extension is not .mat and has been changed')
end

aux_var=evalin('caller',str_save); %variable value in the main function corresponding to the variable name
feval(@()assignin('caller',str_save,aux_var)) %rename such that the variable name goes with its variable value
save(fpath_mat,str_save)
messageOut(NaN,sprintf('file saved: %s',fpath_mat));

end