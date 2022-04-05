%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17593 $
%$Date: 2021-11-16 10:28:04 +0100 (Tue, 16 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_create_variation_simulations.m 17593 2021-11-16 09:28:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_create_variation_simulations.m $
%

function mdf_loc=D3D_modify_mdu(mdf,input_m_mdf_ksim,path_sim_loc)
    
mdf_loc=mdf;
mdf_loc=D3D_modify_input_structure(mdf_loc,input_m_mdf_ksim);

%special case of grid change->copy to simulation folder
if isfield(input_m_mdf_ksim,'NetFile')
    [~,fname_grd,fext_grd]=fileparts(input_m_mdf_ksim.NetFile);
    fnameext_grd=sprintf('%s%s',fname_grd,fext_grd);
    fpath_grd=fullfile(path_sim_loc,fnameext_grd);
    sts=copyfile_check(input_m_mdf_ksim.NetFile,fpath_grd);
    if ~sts
%         fclose(fid_win);
%         fclose(fid_lin);
        error('I cannot find the grid to be copied: %s',input_m_mdf_ksim.NetFile)
    end
    mdf_loc.geometry.NetFile=fnameext_grd;
end

end %function