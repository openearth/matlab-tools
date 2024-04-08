%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19511 $
%$Date: 2024-04-02 12:11:51 +0200 (Tue, 02 Apr 2024) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19511 2024-04-02 10:11:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Scans for a parameter in a folder with one simulations in it. 

function D3D_scan_parameter_in_mdf(fpath_mdf,param)

mdf=D3D_io_input('read',fpath_mdf);

fn=fieldnames(mdf);
ng=numel(fn);
for kg=1:ng
    fn2=fieldnames(mdf.(fn{kg}));
    nf2=numel(fn2);
    for kg2=1:nf2
        if strcmpi(fn2{kg2},param)
            val=mdf.(fn{kg}).(fn2{kg2});
            if ischar(val)
                fprintf('%s = %s, %s \n',param,val,fpath_mdf);
            else
                fprintf('%s = %f, %s \n',param,val,fpath_mdf);
            end
        end
    end
end

end %function

%%
%% FUNCTIONS
%%

