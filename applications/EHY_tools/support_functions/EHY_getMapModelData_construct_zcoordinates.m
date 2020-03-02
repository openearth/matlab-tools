function [zcen_int,zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT)

% This function uses the order of dimensions: [times,cells,layers]

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
        
        gridInfo = EHY_getGridInfo(inputFile,{'Z'},'mergePartitions',OPT.mergePartitions,'disp',0);
        if strcmp(modelType,'d3d')
            bl = reshape(gridInfo.Zcen',[prod(modelSize(2:3)) 1]); % from [m,n] to cells (like FM)
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
           
            % Keepzlayeringatbed
            keepzlayeringatbed = 1; % Delft3D 4 
%             if strcmp(modelType,'dfm')
%                 try
%                     mdu = dflowfm_io_mdu('read',EHY_getMdFile(inputFile));
%                     fns = fieldnames(mdu.numerics);
%                     ind = strmatch('keepzlayeringatbed',lower(fns),'exact');
%                     keepzlayeringatbed = mdu.numerics.(fns{ind});
%                 end
%             end
            
            % bed level
            [~,cellIndMin] = min(int_field,[],2);
            cellIndMinUni = unique(cellIndMin);
            cellIndMinUni(cellIndMinUni == 1) = [];
            for ii = 1:length(cellIndMinUni)
                logi = cellIndMin == cellIndMinUni(ii);
                if keepzlayeringatbed
                    int_field(logi,cellIndMinUni(ii)-1) = ZKlocal(cellIndMinUni(ii)-1);
                else
                    int_field(logi,cellIndMinUni(ii)-1) = bl(logi);
                end
            end
            
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
