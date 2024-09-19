%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19781 $
%$Date: 2024-09-16 13:55:52 +0200 (Mon, 16 Sep 2024) $
%$Author: chavarri $
%$Id: gdm_parse_his.m 19781 2024-09-16 11:55:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_his.m $
%
%Check if a structure is empty. 

function isemp=isempty_struct(struct)

fn=fieldnames(struct);
nfn=numel(fn);
isemp=false;
if nfn==0
    isemp=true;
end

end %function