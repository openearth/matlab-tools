%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19009 $
%$Date: 2023-06-20 07:14:19 +0200 (Tue, 20 Jun 2023) $
%$Author: chavarri $
%$Id: rkm_of_pol.m 19009 2023-06-20 05:14:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/rkm_of_pol.m $
%
%

function [rkm_query_corrected,cutoff]=correct_for_bendcutoff(rkm_query,rkm_centre,br,ds_pol)

tol=10/1000; 
rkm_query_corrected=rkm_query;
cutoff=false;
switch br
    case 'IJ'
        rkm_cut=[...         %last rkm existing
            891.9,896.0;...
            902.5,903.0;...
            905.3,910.0 ...
            ]; 
        bol_cut=rkm_query>rkm_cut(:,1)+tol & rkm_query<rkm_cut(:,2)-tol;
        if any(bol_cut)
            rkm_loc=rkm_cut(bol_cut,:); 
            if rkm_query>rkm_centre
                rkm_1=rkm_loc(1);
                rkm_2=rkm_loc(2);
                sign_corr=-1;
            else
                rkm_1=rkm_loc(2);
                rkm_2=rkm_loc(1);
                sign_corr=+1;
            end
            rkm_query_corrected=rkm_2+(rkm_query-rkm_1);
            %This is tricky. We have to correct for the size of the polygon.
            %existing polygon rkm
            %891.5 | 891.6 | 891.7 | 891.8 | 891.9 | 896.0 | 896.1 |
            %query points centered around 896.0. 
            %895.5 | 895.6 | 895.7 | 895.8 | 895.9 | 896.0 |
            %if we request 896.0-0.5=895.5 we want to get 891.5 but we get 891.9-0.5=891.4 if we do not correct for the polygon size.
            rkm_query_corrected=rkm_query_corrected+sign_corr*ds_pol; 
            cutoff=true;
        end
end