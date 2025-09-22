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
%Convert the FLORIS data about structures, which are located at nodes, to
%Delft3D data about structures, which are located at a chainage in a
%branch.

function [bc_pump,structures]=floris_to_fm_bc_pump(structures,time_unit,varargin) %time series of pumps

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log;

%%

kpump=0;
fnames=fieldnames(structures);
nstructures=numel(fnames);

bc_pump=struct(); %not really a good preallocation, but something gets out even if there is no pump.

for ks=1:nstructures

    structures_chapter=structures.(fnames{ks});

    if ~isfield(structures_chapter,'type')
        continue
    end
    if ~strcmp(structures_chapter.type,'pump')
        continue
    end
    kpump=kpump+1;
    bc_pump(kpump).name=structures_chapter.name;
    bc_pump(kpump).function='timeseries';
    bc_pump(kpump).time_interpolation='linear';
    bc_pump(kpump).quantity={'time','pump_capacity'};
    bc_pump(kpump).unit={sprintf('%s since 2000-01-01 00:00:00 +00:00',time_unit),'m³/s'};
    bc_pump(kpump).val=structures_chapter.time_series;

    %remove the temporary field used for storing the timeseries
    structures.(fnames{ks})=rmfield(structures.(fnames{ks}),'time_series');

end %nstructures

end %function