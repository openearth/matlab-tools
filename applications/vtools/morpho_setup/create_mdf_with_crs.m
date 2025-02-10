%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19877 $
%$Date: 2024-11-07 12:42:34 +0100 (Thu, 07 Nov 2024) $
%$Author: ottevan $
%$Id: write_subdomain_bc.m 19877 2024-11-07 11:42:34Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/write_subdomain_bc.m $
%
%Given a simulation, writes an mdu-file with an additional observation 
%cross-section and the request to write observation cross-sections as
%shp-files. The output is written in a folder at the same level as the
%original simulation. This is necessary because there may be some input
%(e.g., enclosure file) which is set as a relative path.
%
%INPUT:
%   - fdir_in = full path to input simulation; [char]
%   - fdir_name_out = name of the directory where to where to copy the input simulation; [char]
%   - fpath_crs = full path to observation cross-section file to add to simulation; [char] 
%
%OUTPUT:
%
%OPTIONAL PAIR INPUT:
%   - reuse = if `true`, the input simulation is not copied to create the output
%   simulation and the output simulation is reused; [boolean]
%
%HISTORY:
%
%This function stems from `create_run_all`, which was a function within the
%script `main01_add_crs_to_simulation.m` in
%<28_get_partition_pli_grave_lith>.

function fdir_out=create_mdf_with_crs(fdir_in,fdir_name_out,fpath_crs,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'reuse',false);

parse(parin,varargin{:});

reuse=parin.Results.reuse;

fup=folderUp(fdir_in);
fdir_out=fullfile(fup,fdir_name_out);

if reuse && ~isfolder(fdir_out)
    messageOut(NaN,'If you reuse the output folder, this must exist and contain a simulation.')
end

%% CALC

if ~reuse 
    if ~isfolder(fdir_in)
        error('Folder does not exist: %s',fdir_in)
    end
    copyfile_check(fdir_in,fdir_out,1);
end

simdef=D3D_simpath(fdir_out);

%copy crsfile to outputdir 
[~,filename,~] = fileparts(fpath_crs);
fname_crs=sprintf('%s.pli',filename);
fpath_crs_out=fullfile(fdir_out,fname_crs); %the extension of the input may be .pol, but it must be .pli for being treated as a cross-section.
copyfile_check(fpath_crs, fpath_crs_out); %copied at same level as mdu-file

%% modify mdf-file

mdf=D3D_io_input('read',simdef.file.mdf);

mdf.output.Wrishp_crs = 1;  %write shape file
mdf.output.CrsFile = fname_crs; %[mdf_main.output.CrsFile '    ' crsfile] %write only crs file % Add crsfile to mdf
mdf.output.ObsFile = ''; 
mdf.output.FouFile = '';   %Leaving out Foufile
mdf.time.TStop = 1;  %Only one time step is needed
%mdf.geometry.GridEnclosureFile = '';  use full maas enclosure to prevent missing water level locations
mdf.geometry.DryPointsFile = '';
mdf.geometry.ThinDamFile = '';
mdf.geometry.FixedWeirFile = '';
mdf.geometry.PillarFile = '';
mdf.geometry.StructureFile = '';
mdf.geometry.IniFieldFile = '';
mdf.geometry.WaterLevIni=5;
mdf.geometry.BedlevUni=-5;
mdf.geometry.UseCaching=0;
mdf.trachytopes.TrtRou = 'N';
mdf.calibration.UseCalibration = 0;
mdf.external_forcing.ExtForceFile = ''; 
mdf.external_forcing.ExtForceFileNew = '';

%% write mdf-file

D3D_io_input('write',simdef.file.mdf,mdf);

end %function
