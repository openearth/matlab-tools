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
%Given a simulation, writes an mdu-file with an additional observation 
%cross-section and the request to write observation cross-sections as
%shp-files. 
%
%INPUT:
%   - fdir_in = full path to input simulation; [char]
%   - fdir_out = full path to output location (where to copy the input simulation); [char]
%   - fpath_crs = full path to observation cross-section file to add to simulation; [char] 
%
%OUTPUT:
%
%OPTIONAL PAIR INPUT:
%   - reuse = if `true`, the input simulation is not copied to create the output
%   simulation and the output simulation is reused; [boolean]
%

function D3D_run_dimr(fdir_work,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_exe','c:\Program Files\Deltares\Delft3D FM Suite 2024.03 HMWQ\plugins\DeltaShell.Dimr\kernels\x64\bin\run_dimr.bat');
addOptional(parin,'fpath_xml','');

parse(parin,varargin{:});

fpath_exe=parin.Results.fpath_exe;
fpath_xml=parin.Results.fpath_xml;

%% CALC

fdir_now=pwd;
cd(fdir_work)
if ~exist(fpath_exe,'file')
    error('There is no <run_dimr.bat> here: %s',fpath_exe)
end
if ~isempty(fpath_xml)
    [status]=system(sprintf('call "%s" "%s"',fpath_exe,fpath_xml));
else
    [status]=system(sprintf('call "%s"',fpath_exe)); %for some reason the execute does not work when the path has a space, although it did before. If default name is <dimr_config> is used, there is no ptoblem. 
end
cd(fdir_now);
if status~=0
    error('something went wrong when executing')
end

end %function