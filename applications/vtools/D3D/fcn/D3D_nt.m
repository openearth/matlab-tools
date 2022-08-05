%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 11:17:04 +0200 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: NC_nt.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_nt.m $
%
%

function nt=D3D_nt(fpath_res)

[~,~,ext]=fileparts(fpath_res);
switch ext
    case '.nc'
        nt=NC_nt(fpath_res);
    case '.dat'
        NFStruct=vs_use(fpath_res,'quiet');
        ITMAPC=vs_let(NFStruct,'map-info-series','ITMAPC','quiet'); %results time vector
        nt=numel(ITMAPC); %there must be a better way... ask Bert!
        
end 