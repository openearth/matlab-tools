%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: regexp_layout.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/regexp_layout.m $
%
%writes reference in tex file

function [xyz_all,err]=read_xyz(fname)

err=0;
fid=fopen(fname,'r');
kl=0;
npreall=1000;
while ~feof(fid)
    kl=kl+1;
    lin=fgetl(fid);
    tok=regexp(lin,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens');
    if isempty(tok)
        messageOut(NaN,'Cannot read the file, sorry.')
        err=1;
        break 
    end
    xyz=cellfun(@(X)str2double(X),tok);
    if kl==1
        nc=numel(xyz);
        xyz_all=NaN(npreall,nc);
        nr=size(xyz_all,1);
    elseif kl==nr
        xyz_all=cat(1,xyz_all,NaN(npreall,nc));
        nr=size(xyz_all,1);
    end
    xyz_all(kl,:)=xyz;
end
xyz_all=xyz_all(1:kl,:);

end