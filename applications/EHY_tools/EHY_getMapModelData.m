function varargout = EHY_getMapModelData(outputfile,varargin)
% Extracts top view data (of water levels/salinity/temperature) from output of different models
%
% Running 'EHY_getMapModelData_interactive' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getMapModelData-function with input arguments.
%
% Input Arguments:
% outputfile: Output file with simulation results
%
% Optional input arguments:
% varName   : Name of variable, choose from: 'wl','sal',tem'
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
%
% Output:
% Data.times              : (matlab) times belonging with the series
% Data.val                : requested data
% Data.dimensions         : Dimensions of requested data (time,spatial_dims,lyrs)
% Data.OPT                : Structure with optional user settings used
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018

if ~exist('outputfile','var')
    EHY_getMapModelData_interactive
    return
end

OPT.varName = 'wl';
OPT.t0 = '';
OPT.tend = '';
OPT.layer = 0; % all

OPT         = setproperty(OPT,varargin);

%% modify input
if ~isempty(OPT.t0); OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend); OPT.tend=datenum(OPT.tend); end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end

%% Get the computational data
modelType=EHY_getModelType(outputfile);
switch modelType

    case 'dfm'
        %% Delft3D-Flexible Mesh
        % open data file
        gridInfo=EHY_getGridInfo(outputfile,{'no_layers','dimensions'});
        infonc=ncinfo(outputfile);
        OPT=EHY_getmodeldata_layer_index(OPT,gridInfo.no_layers);

            % time info
            Data.times=EHY_getmodeldata_getDatenumsFromOutputfile(outputfile);
            [Data,time_index,select]=EHY_getmodeldata_time_index(Data,OPT);
            if time_index==0; time_index=1; end % 0 = d3d style
            nr_times_clip = length(Data.times);

        % allocate variable 'value'
        if length(OPT.layer==1)
            Data.value = nan(nr_times_clip,gridInfo.no_NetElem);
        else
            Data.value = nan(nr_times_clip,gridInfo.no_NetElem,length(OPT.layer));
        end

        switch OPT.varName
            case 'wl'
                Data.value = ncread(outputfile,'s1',[1 time_index(1)],[Inf nr_times_clip])';
            case {'wd','water depth'}
                Data.value = ncread(outputfile,'waterdepth',[1 time_index(1)],[Inf nr_times_clip])';
            case 'sal'
                if gridInfo.no_layers==1 % 2DH model
                    Data.value = ncread(outputfile,'sa1',[1 time_index(1)],[Inf nr_times_clip])';
                else
                    Data.value = permute(ncread(outputfile,'sa1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                end
            case 'tem'
                if gridInfo.no_layers==1 % 2DH model
                    Data.value = ncread(outputfile,'tem1',[1 time_index(1)],[Inf nr_times_clip])';
                else
                    Data.value = permute(ncread(outputfile,'tem1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                end
        end

    case 'd3d'
        %% Delft3D 4
        % to be implemented
        
    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % to be implemented
        
end

% dimension information
fn=fieldnames(Data);
if length(size(Data.(fn{end})))==2
    Data.dimensions='[times,netElem]';
elseif length(size(Data.(fn{end})))==3
    Data.dimensions='[times,netElem,layers]';
end

Data.OPT=OPT;

if nargout==1
    varargout{1}=Data;
end
EHYs(mfilename);
end
