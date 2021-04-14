%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17028 $
%$Date: 2021-02-01 13:22:57 +0100 (Mon, 01 Feb 2021) $
%$Author: chavarri $
%$Id: fprintflatex.m 17028 2021-02-01 12:22:57Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/fprintflatex.m $
%
%get data in a 3D array

function [z_m,m_1,m_2,m_3,nodes]=get_cube_data(edg_1,edg_2,edg_3,tt_val,idx_z,idx_1,idx_2,idx_3)

[~,~,nodes]=meshgridNodes(edg_1,edg_2);
[m_1,m_2,m_3]=meshgrid(edg_1,edg_2,edg_3);

n1=numel(edg_1)-1;
n2=numel(edg_2)-1;
n3=numel(edg_3)-1;

z_m=NaN(n2,n1,n3,4);

for k1=1:n1
    for k2=1:n2
        for k3=1:n3
            bol_1=tt_val(:,idx_1)>m_1(k2,k1,k3)&tt_val(:,idx_1)<m_1(k2  ,k1+1,k3  );
            bol_2=tt_val(:,idx_2)>m_2(k2,k1,k3)&tt_val(:,idx_2)<m_2(k2+1,k1  ,k3  );
            bol_3=tt_val(:,idx_3)>m_3(k2,k1,k3)&tt_val(:,idx_3)<m_3(k2  ,k1  ,k3+1);

            val_z=tt_val(bol_1&bol_2&bol_3,idx_z);
            nel=numel(val_z);

            if nel>0
                z_m(k2,k1,k3,1)=nel;
                z_m(k2,k1,k3,2)=mean(val_z);
                z_m(k2,k1,k3,3)=max(val_z);
                z_m(k2,k1,k3,4)=std(val_z);
            end

        end %kchagq
    end %kcetaw
    fprintf('done %4.2f %% \n',k1/n1*100)
end %kcq