function [zcen_int,zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT)

% This function uses the order of dimensions: [times,cells,layers]

%% CMEMS?
if EHY_isCMEMS(inputFile)
    [zcen_int,zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_CMEMS(inputFile,OPT);
    return
end

%%
gridInfo = EHY_getGridInfo(inputFile,{'no_layers','layer_model'},'mergePartitions',0);
no_lay   = gridInfo.no_layers;
OPT.varName = 'waterlevel';
OPT.disp = 0;
DataWL   = EHY_getMapModelData(inputFile,OPT);
wl       = DataWL.val;

%% from [m,n] to cells (like FM)
if strcmp(modelType,'d3d')
    modelSize = size(wl);
    wl = reshape(wl,[modelSize(1) prod(modelSize(2:3))]);
end

%%
cen = NaN([size(wl) no_lay]);
int = NaN([size(wl) no_lay+1]);

switch gridInfo.layer_model
    case 'sigma-model'
        gridInfo = EHY_getGridInfo(inputFile,{'layer_perc'},'mergePartitions',0);
        
        % determine bed level
        DataBED = EHY_getMapModelData(inputFile,OPT,'varName','bedlevel');
        bl      = DataBED.val;
        if strcmp(modelType,'d3d')
            bl = reshape(bl,[1 prod(modelSize(2:3))]); % from [m,n] to cells (like FM)
        else
            bl = reshape(bl,1,length(bl));
        end
        
        if strcmp(modelType,'dfm')
            % vertical interfaces at cell center
            int(:,:,1) = repmat(bl,length(DataWL.times),1);
            for i_lay = 1:no_lay-1
                int(:,:,i_lay+1) = int(:,:,1) + (sum(gridInfo.layer_perc(1:i_lay)) * (wl - bl));
            end
            int(:,:,no_lay+1) = wl;
        elseif strcmp(modelType,'d3d')  % sigma model numbers from surface to bed!
            % vertical interfaces at cell center
            bl_tmp     = repmat(bl,length(DataWL.times),1);
            int(:,:,1) = wl;
            for i_lay = 1:no_lay
                int(:,:,i_lay+1) = int(:,:,1) - (sum(gridInfo.layer_perc(1:i_lay)) * (wl - bl_tmp));
            end
            % check
            if length(find(abs(bl_tmp - int(:,:,no_lay + 1)) > 1e-3)) ~= 0
                error ('Wrong reconstruction interfaces d3d sigma layers')
            end
        end
        
    case 'z-model'
        no_times = size(int,1);
        no_cells = size(int,2);
        
        gridInfo = EHY_getGridInfo(inputFile,{'Z'},'mergePartitions',OPT.mergePartitions, ...
            'mergePartitionNrs',OPT.mergePartitionNrs,'disp',0);
        if strcmp(modelType,'d3d')
            bl = reshape(gridInfo.Zcen,[prod(modelSize(2:3)) 1]); % from [m,n] to cells (like FM)
        else
            bl = reshape(gridInfo.Zcen,no_cells,1);
        end
        
        ZKlocal  = gridInfo.Zcen_int;
        ZKlocal2 = repmat(ZKlocal,no_cells,1);
        
        for iT = 1:no_times
            int_field = NaN(no_cells,no_lay+1);
            
            logi = ZKlocal >= bl & ZKlocal <= wl(iT,:)';
            int_field(logi) = ZKlocal2(logi);
            
            % water level
            [~,cellIndMax] = max(int_field,[],2);
            cellIndMaxUni = unique(cellIndMax);
            cellIndMaxUni(cellIndMaxUni == 1) = [];
            for ii = 1:length(cellIndMaxUni)
                logi = cellIndMax == cellIndMaxUni(ii);
                if cellIndMaxUni(ii) == no_lay+1 % top layer
                    int_field(logi,end) = wl(iT,logi);
                else
                    int_field(logi,cellIndMaxUni(ii)+1) = wl(iT,logi);
                end
            end
            
            %% mdu
            try
                if strcmp(modelType,'dfm')
                    mdu = dflowfm_io_mdu('read',EHY_getMdFile(inputFile));
                    % make sure needed variable names can be found in lower-case
                    fns = fieldnames(mdu);
                    for iF = 1:length(fns)
                        mdu.(lower(fns{iF})) = mdu.(fns{iF});
                    end
                    fns = fieldnames(mdu.geometry);
                    for iF = 1:length(fns)
                        mdu.geometry.(lower(fns{iF})) = mdu.geometry.(fns{iF});
                    end
                end
            end
            
            %% Keepzlayeringatbed
            if ~exist('keepzlayeringatbed','var') % only needed to determine this value once
                keepzlayeringatbed = 0; % Delft3D 4 default
                try
                    fns = fieldnames(mdu.numerics);
                    ind = strmatch('keepzlayeringatbed',lower(fns),'exact');
                    keepzlayeringatbed = mdu.numerics.(fns{ind});
                end
            end
            
            [~,cellIndMin] = min(int_field,[],2);
            cellIndMinUni = unique(cellIndMin);
            for ii = 1:length(cellIndMinUni)
                if cellIndMinUni(ii) == 1; continue; end
                logi = cellIndMin == cellIndMinUni(ii);
                if keepzlayeringatbed == 0
                    int_field(logi,cellIndMinUni(ii)-1) = bl(logi);
                elseif keepzlayeringatbed == 1
                    int_field(logi,cellIndMinUni(ii)-1) = ZKlocal(cellIndMinUni(ii)-1);
                elseif keepzlayeringatbed == 2
                    int_field(logi,cellIndMinUni(ii)-1) = bl(logi);
                    if cellIndMinUni(ii) < length(ZKlocal)
                        int_field(logi,cellIndMinUni(ii)) = mean([bl(logi) int_field(logi,cellIndMinUni(ii)+1)],2);
                    end
                end
            end
            
            %% z-sigma-layer model? Add sigma-layers at the top
            try
                numtopsig = mdu.geometry.numtopsig;
                if isfield(mdu.geometry,'numtopsiguniform') && mdu.geometry.numtopsiguniform
                    sigma_bottom = max([int_field(:,end-numtopsig) bl],[],2) ;
                    sigma_top    = wl(iT,:)';
                    dz = sigma_top - sigma_bottom;
                    int_field(:,(end-numtopsig):end) = sigma_bottom+linspace(0,1,numtopsig+1).*dz;
                elseif numtopsig > 0
                    for ii = 1:size(int_field,1)
                        logi = ~isnan(int_field(ii,:));
                        logi(1:end-numtopsig) = false; % only top numtopsig are changed into sigma-layers
                        ind1 = find(logi,1,'first');
                        ind2 = find(logi,1,'last');
                        if ~isempty(ind1) && ~isempty(ind2)
                            no_active_layers =  ind2-ind1+1;
                            int_field(ii,logi) = linspace(int_field(ii,ind1),int_field(ii,ind2),no_active_layers);
                        end
                    end
                end
            end
            
            %%
            int(iT,:,:) = int_field;
        end
end

%% vertical centers at cell center
cen = (int(:,:,1:end-1) + int(:,:,2:end)) ./ 2;

%% cells (like FM) back to [m,n]
if strcmp(modelType,'d3d')
    cen = reshape(cen,[modelSize no_lay]);
    int = reshape(int,[modelSize no_lay+1]);
    wl  = reshape(wl , modelSize);
    bl  = reshape(bl , [1 modelSize(2:3)]);
end

zcen_cen = cen;
zcen_int = int;

end

function [zcen_int,zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_CMEMS(inputFile,OPT)
%         % water level
%         [pathstr, name, ext] = fileparts(inputFile);
%         [~,name] = strtok(name,'_');
%         wlFile = [pathstr filesep 'zos' name ext];
%         if ~exist(wlFile,'file')
%             error(['Could not find corresponding waterlevel-file: ' newline wlFile])
%         end
%         Data_WL = EHY_getMapModelData(wlFile,OPT,'varName','zos');
%         wl       = DataWL.val;
infonc = ncinfo(inputFile);
ind = strmatch('latitude',{infonc.Dimensions.Name},'exact');
lat_len = infonc.Dimensions(ind).Length;
ind = strmatch('longitude',{infonc.Dimensions.Name},'exact');
lon_len = infonc.Dimensions(ind).Length;
ind = strmatch('time',{infonc.Dimensions.Name},'exact');
time_len = infonc.Dimensions(ind).Length;

depth = double(ncread(inputFile,'depth'));
depth_cen = permute(depth,[2 3 4 1]);
zcen_cen = -1*repmat(depth_cen,time_len,lon_len,lat_len);
depth_int = permute(center2corner1(depth)',[2 3 4 1]);
zcen_int = -1*repmat(depth_int,time_len,lon_len,lat_len);
wl = squeeze(zcen_int(:,:,:,1));
bl = squeeze(zcen_int(:,:,:,end));
end