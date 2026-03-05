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
%

function [sb_pol,sb_def,str_save_sb_pol,npol]=gdm_read_summerbed_polygon_all(fid_log,flg_loc,fdir_mat,fpath_map,ksb)

sb_pol_loc=flg_loc.sb_pol(ksb,:);
ispol=cellfun(@(X)~isempty(X),sb_pol_loc);
npol=sum(ispol);
sb_pol=cell(npol,1);
for kpol=1:npol
    fpath_sb_pol=flg_loc.sb_pol{ksb,kpol};
    [~,sb_pol{kpol},~]=fileparts(fpath_sb_pol);

    sb_def(kpol)=gdm_read_summerbed(flg_loc,fid_log,fdir_mat,fpath_sb_pol,fpath_map);
end

%name of string to create folder
str_save_sb_pol='';
for kpol=1:npol
    str_save_sb_pol=strcat(str_save_sb_pol,sb_pol{kpol},'_');
end
str_save_sb_pol(end)='';

end