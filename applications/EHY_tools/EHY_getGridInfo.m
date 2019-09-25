function gridInfo=EHY_getGridInfo(inputFile,varargin)
%% gridInfo=EHY_getGridInfo(inputFile,varargin)
% Get information (specified in varargin{1}) from the provided inputFile
%
% Input Arguments:
% inputFile: 	master definition file (.mdf / .mdu), grid file, outputfile
% varargin{1): 	string or cell array of strings with wanted variables
%               available keyword       returns:
%               no_layers               E.no_layers
%               dimensions              E.MNKmax | no_NetNode & no_NetElem
%               XYcor                   E.Xcor & E.Ycor (=NetNodes)
%               XYcen                   E.Xcen & E.Ycen (=NetElem/faces)
%               layer_model             E.layer_model (sigma-model or z-model)
%               face_nodes_xy           E.face_nodes_x & E.face_nodes_y
%               area                    E.area
%         Zcen (top-view info/depth)    E.Zcen (& E.Zcor)
%         Z    (side-view info/profile) E.Zcen (& E.Zcor), E.Zcen_cen & E.Zcen_int(in NetElem/faces)
%               layer_perc              E.layer_perc (bed to surface), sum=100
%               spherical               E.spherical (0=cartesian,1=spherical)
%
% varargin{2:3) <keyword/value> pair
%               stations                celll array of station names identical to
%                                       specified in input for EHY_getmodeldata
%               m                       horizontal structured grid [m,n] (default = 0, all)
%               n                       horizontal structured grid [m,n] (default = 0, all)
%
% Conventions:  Z                       positive  up  from ref.
%                                       shape of array [time,stations,Z]
%               (water)depth            absolute value (bed to surface)
%               layer info              convention as in provided modelfile, i.e.:
%                                       -dfm        (layer 1 = bed, layer n = surface)
%                                       -d3d-zlayer (layer 1 = bed, layer n = surface)
%                                       -d3d-sigma  (layer n = bed, layer 1 = surface)
%                                       -SIMONA     (layer n = bed, layer 1 = surface)
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018

%% Initialisation
OPT.stations        = '';
OPT.varName         = 'wl';
OPT.mergePartitions = 1; % merge output in case of dfm '_map.nc'-files
OPT.disp            = 1; % display status and message if none of the wanted output was found
OPT.m               = 0; % all (horizontal structured grid [m,n])
OPT.n               = 0; % all (horizontal structured grid [m,n])
OPT                 = setproperty(OPT,varargin{2:end});

%% process input from user
if nargin==0 || isempty(inputFile)
    EHY_getGridInfo_interactive;
    return
else
    if isempty(varargin)
        error('No wanted output specified')
    end
    wantedOutput=cellstr(varargin{1});
end

inputFile = strtrim(inputFile);
if isempty(OPT.m);    OPT.m=0;              end
if isempty(OPT.n);    OPT.n=0;              end
if ~isnumeric(OPT.m); OPT.m=str2num(OPT.m); end
if ~isnumeric(OPT.n); OPT.n=str2num(OPT.n); end

%% determine type of model and type of inputFile
modelType=EHY_getModelType(inputFile);
[typeOfModelFile,typeOfModelFileDetail]=EHY_getTypeOfModelFile(inputFile);
[pathstr, name, ext] = fileparts(lower(inputFile));

if EHY_isPartitioned(inputFile,modelType)
    % partitioned dfm run with *map*.nc-files
else
    OPT.mergePartitions = 0; % do not loop over all partitions
end

if strcmp(modelType,'dfm') && strcmp(typeOfModelFile,'network')
    % if network, treat as outputfile (.nc)
    typeOfModelFile='outputfile';
end

%% check if output data is in several partitions and merge if necessary
if OPT.mergePartitions==1 && EHY_isPartitioned(inputFile,modelType)
    mapFiles=dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    try % temp fix for e.g. RMM_dflowfm_0007_0007_numlimdt.xyz
        if ~isempty(str2num(inputFile(end-15:end-12)))
            mapFiles=dir([inputFile(1:end-16) '*' inputFile(end-6:end)]);
        end
    end
    for iM=1:length(mapFiles)
        if OPT.disp
            disp(['Reading and merging grid info data from partitions: ' num2str(iM) '/' num2str(length(mapFiles))])
        end
        mapFile=[fileparts(inputFile) filesep mapFiles(iM).name];
        gridInfoPart=EHY_getGridInfo(mapFile,varargin{1},'mergePartitions',0);
        if iM==1
            gridInfo=gridInfoPart;
            fn=fieldnames(gridInfoPart);
            ind=strmatch('face_nodes',fn,'exact');
            fn=[fn(ind); fn];
            fn(ind+1)=[];
        else
            for iFN=1:length(fn)
                if any(strcmp(fn{iFN},{'face_nodes','face_nodes_x','face_nodes_y'}))
                    % some partitions only contain triangles,squares, ..
                    nrRows=size(gridInfo.(fn{iFN}),1);
                    nrRowsPart=size(gridInfoPart.(fn{iFN}),1);
                    if nrRowsPart>nrRows
                        gridInfo.(fn{iFN})(nrRows+1:nrRowsPart,:)=NaN;
                    elseif nrRowsPart<nrRows
                        gridInfoPart.(fn{iFN})(nrRowsPart+1:nrRows,:)=NaN;
                    end
                end
                
                if any(strcmp(fn{iFN},{'face_nodes_x','face_nodes_y'}))
                    gridInfo.(fn{iFN})=[gridInfo.(fn{iFN}) gridInfoPart.(fn{iFN})];
                elseif strcmp(fn{iFN},{'face_nodes'})
                    gridInfo.(fn{iFN})=[gridInfo.(fn{iFN}) length(gridInfo.Xcor)+gridInfoPart.(fn{iFN})];
                elseif any(strcmp(fn{iFN},{'Xcor','Xcen','Ycor','Ycen','Zcor','Zcen'}))
                    gridInfo.(fn{iFN})=[gridInfo.(fn{iFN}); gridInfoPart.(fn{iFN})];
                elseif any(strcmp(fn{iFN},{'no_NetNode','no_NetElem'}))
                    gridInfo.(fn{iFN})=gridInfo.(fn{iFN})+gridInfoPart.(fn{iFN});
                else
                    % skip, info is the same in all partitions
                end
            end
        end
    end
    gridInfo.inputFile=[inputFile(1:end-11) '*' inputFile(end-6:end)];
    return
end

%% get grid info
% order modelType:          dfm, d3d, simona
% order typeOfModelFile:    mdFile,grid/network,
switch modelType
    case 'dfm'
        
        if  ~strcmp(typeOfModelFileDetail,'map_nc') || ~OPT.mergePartitions
            
            switch typeOfModelFile
                
                case 'mdFile'
                    mdu=dflowfm_io_mdu('read',inputFile);
                    fn=fieldnames(mdu.geometry);
                    for iFN=1:length(fn)
                        % make all variabels names also available in lower-case
                        mdu.geometry.(lower(fn{iFN}))=mdu.geometry.(fn{iFN});
                    end
                    if ismember('no_layers',wantedOutput)
                        tmp=EHY_getGridInfo(inputFile,{'layer_model'},'disp',0);
                        if strcmp(tmp.layer_model,'z-model')
                            disp('''no_layers'' taken from .mdu-file (keyword kmx), but z-layer model so could be different/overwritten.')
                            disp('For actual number used, please check a model output file.')
                        end
                        E.no_layers=mdu.geometry.kmx;
                        if E.no_layers==0
                            E.no_layers=1;
                        end
                    end
                    if ismember('dimensions',wantedOutput)
                        netFile=EHY_path([fileparts(inputFile) filesep mdu.geometry.netfile]);
                        F=EHY_getGridInfo(netFile,'dimensions');
                        fldnames=fieldnames(F);
                        for iF=1:length(fldnames)
                            E.(fldnames{iF})=F.(fldnames{iF});
                        end
                    end
                    if ismember('layer_model',wantedOutput)
                        if mdu.geometry.layertype==1
                            E.layer_model='sigma-model';
                        elseif mdu.geometry.layertype==2
                            E.layer_model='z-model';
                        end
                    end
                    if ismember('layer_perc',wantedOutput)
                        if isfield(mdu.geometry,'StretchCoef')
                            E.layer_perc=mdu.geometry.stretchcoef;
                        else
                            % assume uniform distribution
                            lyrs=mdu.geometry.kmx;
                            E.layer_perc=repmat(1/lyrs,lyrs,1);
                        end
                    end
                    if ismember('Z',wantedOutput)
                        tmp=EHY_getGridInfo(inputFile,{'layer_model','layer_perc'},'disp',0);
                        if strcmp(tmp.layer_model,'z-model')
                            if isfield(mdu.geometry,'zlaytop')
                                dh=mdu.geometry.ZlayTop-mdu.geometry.ZlayBot;
                                E.Zcen_int=mdu.geometry.ZlayBot+cumsum([0 tmp.layer_perc]/100*dh);
                                E.Zcen_cen=E.Zcen_int(1:end-1)+diff(E.Zcen_int)/2;
                            elseif isfield(mdu.geometry,'floorlevtoplay')
                                %                                 E.Zcen_int=[mdu.geometry.floorlevtoplay:-mdu.geometry.dztop:mdu.geometry.dztopuniabovez ...
                                %                                    <part with sigmagrowthfactor to maximum depth ...> ]
                                % to be correctly implemented
                            end
                        end
                    end
                    
                case 'outputfile'
                    infonc = ncinfo(inputFile);
                    if ismember('no_layers',wantedOutput)
                        varName = EHY_nameOnFile(inputFile,'mesh2d_nLayers');
                        ncVarInd = strmatch(varName,{infonc.Dimensions.Name},'exact');
                        if ~isempty(ncVarInd)
                            E.no_layers = infonc.Dimensions(ncVarInd).Length;
                        else
                            E.no_layers=1;
                        end
                    end
                    if ismember('XYcor',wantedOutput)
                        varName = EHY_nameOnFile(inputFile,'mesh2d_node_x');
                        E.Xcor = ncread(inputFile,varName);
                        E.Ycor = ncread(inputFile,strrep(varName,'x','y'));
                    end
                    if ismember('XYcen',wantedOutput)
                        varName = EHY_nameOnFile(inputFile,'FlowElem_xcc');
                        if nc_isvar(inputFile,varName)
                            E.Xcen = ncread(inputFile,varName);
                            E.Ycen = ncread(inputFile,strrep(varName,'x','y'));
                        else
                            disp('Cell center info not found in network. Import grid>export grid in RGFGRID and try again')
                        end
                    end
                    
                    if ismember('Zcen',wantedOutput) || ismember('Z',wantedOutput) % top-view information
                        if strcmp(typeOfModelFileDetail,'his_nc') % his file
                            if nc_isvar(inputFile,'bedlevel')
                                E.Zcen=ncread(inputFile,'bedlevel')';
                            elseif nc_isvar(inputFile,'waterlevel') && nc_isvar(inputFile,'Waterdepth')
                                wl     = ncread(inputFile,'waterlevel',[1 1],[Inf 1]);
                                wd     = ncread(inputFile,'Waterdepth',[1 1],[Inf 1]);
                                E.Zcen = wl - wd;
                            elseif nc_isvar(inputFile,'zcoordinate_w')
                                tmp    = ncread(inputFile,'zcoordinate_w',[1 1 1],[1 Inf Inf]);
                                E.Zcen = tmp(:,end);
                            elseif nc_isvar(inputFile,'zcoordinate_c') && nc_isvar(inputFile,'waterlevel')
                                % Re construct depth based on water levels and centre coordinates
                                E.Zcen = ncread(inputFile,'waterlevel',[1 1],[Inf 1]);
                                tmp    = ncread(inputFile,'zcoordinate_c',[1 1 1],[Inf Inf 1])';
                                for i_lay = E.no_layers:-1:1
                                    E.Zcen = E.Zcen -2*(E.Zcen- tmp(:,i_lay));
                                end
                            else
                                E.Zcen = NaN;
                            end
                        elseif strcmp(typeOfModelFileDetail,'map_nc') || strcmp(typeOfModelFileDetail,'net_nc') % map/nc file
                            varName = EHY_nameOnFile(inputFile,'mesh2d_node_z');
                            E.Zcor = ncread(inputFile,varName);
                            try % depth at center not always available
                                varName = EHY_nameOnFile(inputFile,'mesh2d_flowelem_bl');
                                E.Zcen=ncread(inputFile,varName);
                            end
                        end
                    end
                    
                    if any(ismember({'Z','Zcen_cen','Zcen_int'},wantedOutput)) % side-view information
                        if strcmp(typeOfModelFileDetail,'his_nc') % his file
                            if nc_isvar(inputFile,'zcoordinate_c')
                                tmp        = EHY_getmodeldata(inputFile,{},modelType,'varName','zcoordinate_c');
                                E.Zcen_cen = tmp.val;
                                if nc_isvar(inputFile,'zcoordinate_w')
                                    tmp        = EHY_getmodeldata(inputFile,{},modelType,'varName','zcoordinate_w');
                                    E.Zcen_int = tmp.val;
                                else
                                    % Retrieve interfaces from water level end centre information
                                    warning(['Reconstructing position of interfaces from water level and centres.' newline    ...
                                        'Can be time consuming. Consider writing interface information to history file!']);
                                    tmp                              = EHY_getmodeldata(inputFile,{},modelType,'varName','wl');
                                    
                                    if isfield(E,'no_layers')
                                        no_layers = E.no_layers;
                                    else
                                        tmpNOL = EHY_getGridInfo(inputFile,'no_layers');
                                        no_layers = tmpNOL.no_layers;
                                    end
                                    
                                    E.Zcen_int(:,:,no_layers + 1) = tmp.val;
                                    for i_lay = no_layers:-1:1
                                        E.Zcen_int(:,:,i_lay) = E.Zcen_int(:,:,i_lay + 1) -2*(E.Zcen_int(:,:,i_lay + 1) - E.Zcen_cen(:,:,i_lay));
                                    end
                                end
                            elseif nc_isvar(inputFile,'bedlevel')
                                E.Zcen_int(:,:,2) = ncread(inputFile,'waterlevel')';
                                no_times          = size(E.Zcen_int,1);
                                E.Zcen_int(:,:,1) = repmat(ncread(inputFile,'bedlevel'  )',no_times,1);
                                E.Zcen_int(:,:,2) = ncread(inputFile,'waterlevel')';
                                E.Zcen_cen(:,:,1) = 0.5*(E.Zcen_int(:,:,1) + E.Zcen_int(:,:,2));
                            elseif nc_isvar(inputFile,'waterlevel') && nc_isvar(inputFile,'Waterdepth')
                                wl = ncread(inputFile,'waterlevel')';
                                wd = ncread(inputFile,'Waterdepth')';
                                E.Zcen_int(:,:,2) = wl;
                                E.Zcen_int(:,:,1) = -wd + wl;
                                E.Zcen_cen(:,:,1) = 0.5*(E.Zcen_int(:,:,1) + E.Zcen_int(:,:,2));
                            end
                            if ~isfield(E,'Zcen_cen')
                                try % try to get this info from mdFile
                                    mdFile=EHY_getMdFile(inputFile);
                                    tmp = EHY_getGridInfo(mdFile,'Z','disp',0);
                                    E.Zcen_int = tmp.Zcen_int;
                                    E.Zcen_cen = tmp.Zcen_cen;
                                end
                            end
                        elseif strcmp(typeOfModelFileDetail,'map_nc') || strcmp(typeOfModelFileDetail,'net_nc') % map/nc file
                            if nc_isvar(inputFile,'mesh2d_layer_z') % z-layer info
                                E.Zcen_cen=ncread(inputFile,'mesh2d_layer_z')';
                                E.Zcen_int=ncread(inputFile,'mesh2d_interface_z')';
                            elseif nc_isvar(inputFile,'mesh2d_layer_sigma')
                                perc=ncread(inputFile,'mesh2d_interface_sigma');
                                bl=ncread(inputFile,'mesh2d_flowelem_bl');
                                E.Zcen_int=-repmat(bl,1,length(perc)).*repmat(perc',length(bl),1);
                                E.Zcen_cen=(E.Zcen_int (:,2:end)+E.Zcen_int(:,1:end-1))/2;
                            elseif nc_isvar(inputFile,'LayCoord_cc')
                                E.Zcen_cen=ncread(inputFile,'LayCoord_cc');
                                E.Zcen_int=ncread(inputFile,'LayCoord_w');
                            end
                            if isfield(E,'Zcen_int')
                                E.thickness=diff(E.Zcen_int,[],2);
                            end
                        end
                    end
                    if ismember('layer_model',wantedOutput)
                        tmp=EHY_getGridInfo(inputFile,'no_layers','disp',0,'mergePartitions',0);
                        if tmp.no_layers==1
                            E.layer_model='-';
                        else
                            if nc_isvar(inputFile,'mesh2d_layer_z') % _map.nc
                                E.layer_model='z-model';
                            elseif nc_isvar(inputFile,'mesh2d_layer_sigma') % _map.nc
                                E.layer_model='sigma-model';
                            else
                                % work-around1: try to get this info from mdFile
                                mdFile=EHY_getMdFile(inputFile);
                                if ~isempty(mdFile)
                                    gridInfo=EHY_getGridInfo(mdFile,'layer_model');
                                    E.layer_model=gridInfo.layer_model;
                                end
                                % word-around2: try to retrieve layer_model
                                % from z coordinate information (first 2 stations, first time step)
                                if ~isfield(E,'layer_model')
                                    tmp_c  = ncread(inputFile,'zcoordinate_c',[1 1 1],[inf 2 1]);
                                    if tmp_c(2,1) -  tmp_c(1,1) ~= tmp_c(2,2) -  tmp_c(1,2)
                                        E.layer_model = 'sigma-model';
                                    else
                                        E.layer_model = 'z-model';
                                    end
                                end
                            end
                        end
                    end
                    if ismember('layer_perc',wantedOutput)
                        tmp       = EHY_getGridInfo(inputFile,{'no_layers','layer_model'},'disp',0,'mergePartitions',0);
                        no_layers = tmp.no_layers;
                        layer_model = tmp.layer_model;
                        if no_layers == 1
                            E.layer_perc = 1.0;
                        else
                            if nc_isvar(inputFile,'mesh2d_layer_sigma')
                                E.layer_perc=diff(ncread(inputFile,'mesh2d_interface_sigma'));
                            elseif nc_isvar(inputFile,'zcoordinate_w') && strcmp(layer_model,'sigma-model')
                                % reconstruct thickness based upon z-coordinates first station, first timestep
                                % for sigma-models only
                                tmp = ncread(inputFile,'zcoordinate_w',[1 1 1],[inf 1 1]);
                                for i_lay = 1: no_layers
                                    E.layer_perc(i_lay) = (tmp(i_lay + 1) - tmp(i_lay))/(tmp(end) - tmp(1));
                                end
                            elseif nc_isvar(inputFile,'zcoordinate_c') && strcmp(layer_model,'sigma-model') && nc_isvar(inputFile,'waterlevel')
                                
                                % Reconstruct interfaces
                                tmp_c  = ncread(inputFile,'zcoordinate_c',[1 1 1],[inf 1 1]);
                                surf   = ncread(inputFile,'waterlevel'   ,[1 1  ],[  1 1  ]);
                                tmp_i(no_layers+1) = surf;
                                for i_lay = no_layers:-1:1
                                    tmp_i(i_lay) = tmp_c(i_lay) - (tmp_i(i_lay + 1) - tmp_c(i_lay));
                                end
                                
                                % determine layer percentages
                                for i_lay = 1: no_layers
                                    E.layer_perc(i_lay) = (tmp_i(i_lay + 1) - tmp_i(i_lay))/(tmp_i(end) - tmp_i(1));
                                end
                                
                            else % try to get this info from mdFile
                                mdFile=EHY_getMdFile(inputFile);
                                if ~isempty(mdFile)
                                    mdFile=EHY_getMdFile(inputFile);
                                    gridInfo=EHY_getGridInfo(mdFile,'layer_perc','disp',0);
                                    E.layer_perc=gridInfo.layer_perc;
                                else
                                    % Could not retrieve layer info, set to NaN
                                    E.layer_perc(1:no_layers) = NaN;
                                end
                            end
                        end
                    end
                    if ismember('face_nodes',wantedOutput)
                        E.face_nodes=ncread(inputFile,'mesh2d_face_nodes');
                    end
                    if ismember('face_nodes_xy',wantedOutput)
                        varName = EHY_nameOnFile(inputFile,'mesh2d_face_x_bnd');
                        if nc_isvar(inputFile,varName)
                            E.face_nodes_x = ncread(inputFile,varName);
                            E.face_nodes_y = ncread(inputFile,strrep(varName,'x','y'));
                        else
                            disp('Face_x_bnd-info not found in network. Import grid>export grid in RGFGRID and try again')
                        end
                    end
                    if ismember('dimensions',wantedOutput)
                        % no_NetNode
                        dimName = EHY_nameOnFile(inputFile,'mesh2d_nNodes');
                        ind = strmatch(dimName,{infonc.Dimensions.Name},'exact');
                        if ~isempty(ind)
                            E.no_NetNode = infonc.Dimensions(ind).Length;
                        end
                        % no_NetElem
                        dimName = EHY_nameOnFile(inputFile,'mesh2d_nFaces');
                        ind = strmatch(dimName,{infonc.Dimensions.Name},'exact');
                        if ~isempty(ind)
                            E.no_NetElem = infonc.Dimensions(ind).Length;
                            if E.no_NetElem == 0
                                E.no_NetElem = NaN;
                            end
                        end
                    end
                    if ismember('area',wantedOutput)
                        varName = EHY_nameOnFile(inputFile,'mesh2d_flowelem_ba');
                        if nc_isvar(inputFile,varName)
                            E.area=ncread(inputFile,varName);
                        end
                    end
                    if ismember('spherical', wantedOutput)
                        if nc_isvar(inputFile,'wgs84')
                            E.spherical = 1;
                        else
                            E.spherical = 0;
                        end
                    end
                    
                    % If partitioned run, delete ghost cells
                    [~, name]=fileparts(inputFile);
                    varName = EHY_nameOnFile(inputFile,'FlowElemDomain');
                    if length(name)>=10 && all(ismember(name(end-7:end-4),'0123456789')) && nc_isvar(inputFile,varName)
                        domainNr = str2num(name(end-7:end-4));
                        FlowElemDomain = ncread(inputFile,varName);

                        % FlowElemGlobal(ghostCellsCenter)
                        ghostCellsCenter=FlowElemDomain~=domainNr;
                        % to be implemenetd for ghostCellsCorner
                        %                         face_nodes=ncread(inputFile,'mesh2d_face_nodes')';
                        %                         ghostCellsCorner=unique(face_nodes(ghostCellsCenter,:));
                        %                         % delete ghostCellsCorner
                        %                         if ismember('XYcor',wantedOutput)
                        %                             E.Xcor(ghostCellsCorner)=[];
                        %                             E.Ycor(ghostCellsCorner)=[];
                        %                         end
                        
                        % delete ghostCellsCenter
                        if ismember('face_nodes',wantedOutput)
                            E.face_nodes(:,ghostCellsCenter)=[];
                        end
                        if ismember('face_nodes_xy',wantedOutput)
                            E.face_nodes_x(:,ghostCellsCenter)=[];
                            E.face_nodes_y(:,ghostCellsCenter)=[];
                        end
                        if ismember('XYcen',wantedOutput)
                            E.Xcen(ghostCellsCenter)=[];
                            E.Ycen(ghostCellsCenter)=[];
                        end
                        if isfield(E,'no_NetElem')
                            E.no_NetElem=sum(FlowElemDomain==domainNr);
                        end
                        if isfield(E,'no_NetNode')
                            % warning: Number of NetNodes is prob. too large due to flowlinks in ghostcells
                        end
                        if isfield(E,'Zcen')
                            E.Zcen(ghostCellsCenter)=[];
                        end
                    end
                    
            end % typeOfModelFile
            
        end % OPT.mergePartitions
        
    case 'd3d'
        switch typeOfModelFile
            
            case 'mdFile'
                mdf=delft3d_io_mdf('read',inputFile);
                
                if ismember('no_layers',wantedOutput)
                    E.no_layers=mdf.keywords.mnkmax(3);
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=mdf.keywords.mnkmax;
                end
                if ismember('layer_model',wantedOutput)
                    if isfield(mdf.keywords,'zmodel') && strcmpi(mdf.keywords.zmodel,'y')
                        E.layer_model='z-model';
                    else
                        E.layer_model='sigma-model';
                    end
                end
                if ismember('layer_perc',wantedOutput)
                    E.layer_perc=mdf.keywords.thick;
                end
                if ismember('Z',wantedOutput)
                    tmp=EHY_getGridInfo(inputFile,{'layer_model','layer_perc'},'disp',0);
                    if strcmp(tmp.layer_model,'z-model')
                        dh=mdf.keywords.ztop-mdf.keywords.zbot;
                        E.Zcen_int=mdf.keywords.zbot+cumsum([0 tmp.layer_perc]/100*dh);
                        E.Zcen_cen=E.Zcen_int(1:end-1)+diff(E.Zcen_int)/2;
                    end
                end
                
            case {'grid','network'}
                if ismember('XY',wantedOutput)
                    if strcmp(ext,'.grd')
                        grd=delft3d_io_grd('read',inputFile);
                        E.mmax=grd.mmax;
                        E.nmax=grd.nmax;
                        E.xcor=grd.cor.x;
                        E.ycor=grd.cor.y;
                        E.xcen=grd.cen.x;
                        E.ycen=grd.cen.y;
                        E.xu=grd.u.x;
                        E.yu=grd.u.y;
                        E.xv=grd.v.x;
                        E.yv=grd.v.y;
                    end
                end
                
            case 'outputfile'
                
                if ~isempty(strfind(name,'trih-'))
                    % TRIH
                    trih=vs_use(inputFile,'quiet');
                    if ismember('no_layers',wantedOutput)
                        E.no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                    end
                    
                    if ismember('dimensions',wantedOutput)
                        E.MNKmax=[vs_get(trih,'his-const',{1},'MMAX','quiet') ...
                            vs_get(trih,'his-const',{1},'NMAX','quiet') ...
                            vs_get(trih,'his-const',{1},'KMAX','quiet')];
                    end
                    
                    if ismember('layer_model', wantedOutput)
                        E.layer_model = lower(strtrim(vs_get(trih,'his-const' ,'LAYER_MODEL','quiet')));
                    end
                    
                    if ismember('layer_perc', wantedOutput)
                        E.layer_perc = 100*flipud(vs_let(trih,'his-const','THICK','quiet'));
                    end
                    
                    if ismember('Zcen', wantedOutput) ||  ismember('Z', wantedOutput)
                        E.Zcen     = -1*vs_let(trih,'his-const','DPS','quiet');
                        E.Zcen     = E.Zcen';
                    end
                    
                    if ismember('Z', wantedOutput)
                        tmp        = EHY_getmodeldata(inputFile,{},modelType,'varName','Zcen');
                        E.Zcen_cen = flip(tmp.val,3);
                        tmp        = EHY_getmodeldata(inputFile,{},modelType,'varName','Zint');
                        E.Zcen_int = flip(tmp.val,3);
                    end
                    
                elseif ~isempty(strfind(name,'trim-'))
                    % TRIM
                    trim=vs_use(inputFile,'quiet');
                    
                    if ismember('no_layers',wantedOutput)
                        E.no_layers=vs_let(trim, 'map-const' ,'KMAX','quiet');
                    end
                    
                    if ismember('dimensions',wantedOutput)
                        E.MNKmax=[vs_get(trim,'map-const',{1},'MMAX','quiet') ...
                            vs_get(trim,'map-const',{1},'NMAX','quiet') ...
                            vs_get(trim,'map-const',{1},'KMAX','quiet')];
                    end
                    
                    if any(ismember({'XYcor','XYcen','Z'},wantedOutput))
                        G = vs_meshgrid2dcorcen(trim);
                    end
                    
                    if ismember('XYcor',wantedOutput)
                        E.Xcor = G.cor.x.*G.cor.mask;
                        E.Ycor = G.cor.y.*G.cor.mask;
                    end
                    
                    if ismember('XYcen',wantedOutput)
                        E.Xcen = G.cen.x.*G.cen.mask;
                        E.Ycen = G.cen.y.*G.cen.mask;
                    end
                    
                    if ismember('layer_model', wantedOutput)
                        E.layer_model=lower(strtrim(squeeze(vs_let(trim, 'map-const' ,'LAYER_MODEL','quiet'))'));
                    end
                    
                    if ismember('Z', wantedOutput)
                        tmp=EHY_getGridInfo(inputFile,{'layer_model'},'disp',0);
                        if strcmp(tmp.layer_model,'z-model')
                            E.Zcen = G.cen.dep;
                            E.Zcen_int = vs_let(trim,'map-const','ZK','quiet');
                        end
                    end
                    
                    if ismember('layer_perc',wantedOutput)
                        E.layer_perc = vs_let(trim,'map-const','THICK','quiet');
                    end
                    
                    if ismember('spherical', wantedOutput)
                        coordinates = vs_let(trim, 'map-const' ,'COORDINATES'       ,'quiet');
                        if strcmp(deblank(squeeze(coordinates)'), 'CARTESIAN') || strcmp(deblank(squeeze(coordinates)'), 'CARTHESIAN')
                            E.spherical = 0;
                        else
                            E.spherical = 1;
                        end
                    end
                    
                end
        end % typeOfModelFile
        
    case 'simona'
        switch typeOfModelFile
            
            case 'mdFile'
                siminp=readsiminp(pathstr,[name ext]);
                siminp.File=lower(siminp.File);
                if ismember('no_layers',wantedOutput)
                    lineInd=find(~cellfun(@isempty,strfind(siminp.File,'kmax')));
                    line=regexp(siminp.File(lineInd),'\s+','split');
                    lineInd2=find(~cellfun(@isempty,strfind(line{1,1},'kmax')));
                    E.no_layers=str2num(line{1,1}{lineInd2+1});
                end
                if ismember('dimensions',wantedOutput)
                    keywords={'mmax','nmax','kmax'};
                    for iK=1:length(keywords)
                        lineInd=find(~cellfun(@isempty,strfind(siminp.File,keywords{iK})));
                        line=regexp(siminp.File(lineInd),'\s+','split');
                        lineInd2=find(~cellfun(@isempty,strfind(line{1,1},keywords{iK})));
                        E.MNKmax(1,iK)=str2num(line{1,1}{lineInd2+1});
                    end
                end
            case 'outputfile'
                sds  = qpfopen(inputFile);
                dimen= waqua('readsds',sds,[],'MESH_IDIMEN');
                kmax = dimen(18);
                if ismember('no_layers',wantedOutput)
                    E.no_layers   = kmax;
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=[dimen(2) dimen(3) kmax];
                end
                if ismember('layer_model', wantedOutput)
                    E.layer_model = 'sigma-model';
                end
                if ismember('Zcen', wantedOutput)
                    mn = waquaio(sds,'','wl-mn');
                    if kmax == 1
                        z  = waquaio(sds,'','depth_wl_points');
                        for i_stat = 1: size(mn,1)
                            E.Zcen(i_stat) = -1.*z(mn(i_stat,2),mn(i_stat,1));
                        end
                        E.Zcen = E.Zcen';
                    else
                        [~,~,z] = waquaio(sds,'','zgrid3di');
                        for i_stat = 1: size(mn,1)
                            E.Zcen(i_stat) = z(mn(i_stat,2),mn(i_stat,1),kmax + 1);
                        end
                    end
                end
                if ismember('Z', wantedOutput)
                    % Fill only interface 1 for the first time step with depths
                    mn = waquaio(sds,'','wl-mn');
                    if kmax == 1
                        dps = waquaio(sds,'','depth_wl_points');
                        for i_stat = 1: size(mn,1)
                            E.Zcen_int(1,i_stat,1) = -1.*dps(mn(i_stat,2),mn(i_stat,1));
                        end
                    else
                        [~,~,z] = waquaio(sds,'','zgrid3di');
                        for i_stat = 1: size(mn,1)
                            E.Zcen_int(1,i_stat,1) = z(mn(i_stat,2),mn(i_stat,1),kmax + 1);
                        end
                    end
                end
                if ismember('layer_perc',wantedOutput)
                    mn = waquaio(sds,'','wl-mn');
                    m = mn(1,1);
                    n = mn(1,2);
                    if kmax == 1
                        E.layer_perc = 1.;
                    else
                        % derive from first station
                        [~,~,z] = waquaio(sds,'','zgrid3di');
                        for k = 1: kmax
                            E.layer_perc(k) = (z(n,m,k + 1) - z(n,m,k))/(z(n,m,kmax + 1) - z(n,m,1));
                        end
                        E.layer_perc = flipud(E.layer_perc);      % dfm convention, numbering from bed to surface
                    end
                end
        end % typeOfModelFile
        
    case {'sobek3' 'sobek3_new' 'implic'}
        E.layer_model = '';
        E.no_layers   = 1;
        
    case 'delwaq'
        switch typeOfModelFile
            case 'grid'
                dw = delwaq('open',inputFile);
                if ismember('dimensions',wantedOutput)
                    E.MNKmax = dw.MNK;
                end
                if ismember('XYcor',wantedOutput)
                    E.Xcor = dw.X;
                    E.Ycor = dw.Y;
                end
        end % typeOfModelFile
  
end % modelType

%% If selection of stations is specified, reduce output to specified stations only
if ~isempty(OPT.stations)
    [Data,stationNrNoNan] = EHY_getRequestedStations(inputFile,OPT.stations,modelType,'varName',OPT.varName);
    vars = intersect(fieldnames(E),{'Zcen_cen','Zcen_int','Zcen'});
    for iV = 1:length(vars)
        if size(E.(vars{iV}),2)>1 % for z-layer model only 1 'station'
            E.(vars{iV}) = E.(vars{iV})(:,stationNrNoNan,:); % [times,stations,Z]
        end
    end
end

%% If [m,n]-selection is specified for structured grid, reduce output to specified grid cells only
if strcmp(modelType,'d3d') && strcmp(typeOfModelFileDetail,'trim')
    % deal with ghost-cells start of grid
    if ~ismember(OPT.m(1),[0 1]); OPT.m = [OPT.m(1)-1 OPT.m]; end
    if ~ismember(OPT.n(1),[0 1]); OPT.n = [OPT.n(1)-1 OPT.n]; end
    vars = intersect(fieldnames(E),{'Xcor','Ycor','Xcen','Ycen'});
    for iV = 1:length(vars)
        if all(OPT.n==0) && all(OPT.m==0)
            % do nothing
        elseif all(OPT.n==0)
            E.(vars{iV}) = E.(vars{iV})(:,OPT.m);
        elseif all(OPT.m==0)
            E.(vars{iV}) = E.(vars{iV})(OPT.n,:);
        else
            E.(vars{iV}) = E.(vars{iV})(OPT.n,OPT.m);
        end
    end
    
    % deal with ghost-cells end of grid
    vars = intersect(fieldnames(E),{'Xcor','Ycor','Xcen','Ycen','Zcen'});
    for iV = 1:length(vars)
        if all(OPT.n==0)
            E.(vars{iV})(end+1,:)=NaN;
        end
        if all(OPT.m==0)
            E.(vars{iV})(:,end+1)=NaN;
        end
    end
end

%% Output structure E
if ~exist('E','var') && OPT.disp
    disp('Could not find any of this data in the provided file');
end
E.inputFile=inputFile;
gridInfo=E;

end

function EHY_getGridInfo_interactive
% get inputFile
disp('Open a grid, model inputfile or model outputfile')
[filename, pathname]=uigetfile('*.*','Open a grid, model inputfile or model outputfile');
if isnumeric(filename); disp('EHY_getGridInfo_interactive stopped by user.'); return; end
inputFile=[pathname filename];

% wanted output
outputParameters={'no_layers','dimensions','XYcor','XYcen','layer_model','face_nodes_xy','area','Zcen','Z','layer_perc'};
option=listdlg('PromptString','Choose wanted output parameters (Use CTRL to select multiple options):','ListString',...
    outputParameters,'ListSize',[300 200]);
if isempty(option); disp('EHY_getGridInfo_interactive was stopped by user');return; end
varargin{1}=outputParameters(option);

% mergePartitions
modelType=EHY_getModelType(inputFile);
if EHY_isPartitioned(inputFile,modelType)
    option=listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 100]);
    if option==2
        OPT.mergePartitions=0;
    end
end

%% display example line
% wanted variables // varargin{1}
vararginStr='';
for iV=1:length(varargin{1})
    vararginStr=[vararginStr '''' varargin{1}{iV} ''','];
end
vararginStr=['{' vararginStr(1:end-1) '}' ];

% wanted OPT // varargin{2:3, ...}
extraText='';
if exist('OPT','var')
    fn=fieldnames(OPT);
    for iF=1:length(fn)
        if ischar(OPT.(fn{iF}))
            extraText=[extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
        elseif isnumeric(OPT.(fn{iF}))
            extraText=[extraText ',''' fn{iF} ''',' num2str(OPT.(fn{iF}))];
        end
    end
end
vararginStr=[vararginStr extraText];

% disp output
disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['gridInfo = EHY_getGridInfo(''' inputFile ''',' vararginStr ');'])

disp('start retrieving the grid info...')

if exist('OPT','var');
    gridInfo = EHY_getGridInfo(inputFile,varargin{:},OPT);
else
    gridInfo = EHY_getGridInfo(inputFile,varargin{:});
end

disp('Finished retrieving the grid info!')
assignin('base','gridInfo',gridInfo);
open gridInfo
disp('Variable ''gridInfo'' created by EHY_getGridInfo_interactive')
end
