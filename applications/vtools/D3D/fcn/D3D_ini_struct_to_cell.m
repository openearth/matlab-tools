%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20320 $
%$Date: 2025-09-15 08:29:13 +0200 (Mon, 15 Sep 2025) $
%$Author: chavarri $
%$Id: D3D_crosssectionlocation.m 20320 2025-09-15 06:29:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_crosssectionlocation.m $
%
%Convert ini data from structure to cell format.

function ini_cell=D3D_ini_struct_to_cell(stru_in)

fn1=fieldnames(stru_in);
nf1=numel(fn1);


ini_cell.FileName='';
ini_cell.FileType='INI file';
ini_cell.Blank='valid';
ini_cell.Data=cell(nf1,2);

for kf1=1:nf1
    fn1_loc=fn1{kf1};
    fn2_loc_clean=regexprep(fn1_loc,'\d+$','');

    stru_in_1=stru_in.(fn1{kf1});
    fn2=fieldnames(stru_in_1);
    nf2=numel(fn2);

    ini_cell.Data{kf1,1}=fn2_loc_clean;
    ini_cell.Data{kf1,2}=cell(nf2,2);
    for kf2=1:nf2
        data=stru_in_1.(fn2{kf2});
        ini_cell.Data{kf1,2}{kf2,1}=fn2{kf2};
        if ischar(data)
            ini_cell.Data{kf1,2}{kf2,2}=data;
        else
            if isinteger_precision(data)
                ini_cell.Data{kf1,2}{kf2,2}=sprintf('%d ',data);
            else
                ini_cell.Data{kf1,2}{kf2,2}=sprintf('%15.13E ',data);
            end
        end
    end %k2
end %kf2

end %function
