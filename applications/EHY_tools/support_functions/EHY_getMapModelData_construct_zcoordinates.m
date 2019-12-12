function [zcen_int,zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT)

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
cen = NaN([size(wl) no_lay]); % time,cells,layers
int = NaN([size(wl) no_lay+1]);

switch gridInfo.layer_model
    case 'sigma-model'
        gridInfo = EHY_getGridInfo(inputFile,{'layer_perc'},'mergePartitions',0);
        
        % determine bed level
        DataBED = EHY_getMapModelData(inputFile,OPT,'varName','bedlevel');
        bl      = DataBED.val;
        if strcmp(modelType,'d3d')
            bl = reshape(bl,[1 prod(modelSize(2:3))]); % from [m,n] to cells (like FM)
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
        
%        wl = wl'; % TK: By doing this the dimension of wl gets from
%                        (no_times to no_cells) to (no_cells,no_times)
%                        Every function comes back with (no_times,no_cells)
%                        Also dfm sigma layers!
        
        ZKlocal  = gridInfo.Zcen_int;
        ZKlocal2 = repmat(ZKlocal,no_cells,1);
        
        for iT = 1:no_times
            int_field = NaN(no_cells,no_lay+1);
            
            logi = ZKlocal >= bl & ZKlocal <= wl(iT,:)';
            int_field(logi) = ZKlocal2(logi);
          
            % water level
            [~,cellIndMax] = max(int_field,[],2);
            cellIndMaxUni = unique(cellIndMax);
            cellIndMaxUni(cellIndMaxUni==1)=[];
            for ii = 1:length(cellIndMaxUni)
                logi = cellIndMax == cellIndMaxUni(ii);
                if cellIndMaxUni(ii) == no_lay+1 % top layer
                    int_field(logi,end) = wl(iT,logi);
                else
                    int_field(logi,cellIndMaxUni(ii)+1) = wl(iT,logi);
                end
            end
           
            % bed level
            [~,cellIndMin] = min(int_field,[],2);
            cellIndMinUni = unique(cellIndMin);
            cellIndMinUni(cellIndMinUni==1)=[];
            cellIndMinUni(cellIndMinUni==no_lay+1)=[];
            for ii = 1:length(cellIndMinUni)
                logi = cellIndMin == cellIndMinUni(ii);
                int_field(logi,cellIndMinUni(ii)-1) = ZKlocal(cellIndMinUni(ii)-1); % keepzlayeratbed==0
                % int_field(logi,cellIndMinUni(ii)-1) = bl(logi); % keepzlayeratbed==1
            end
            
            int(iT,:,:) = int_field;
        end

%         
%             for iT = 1:size(int,1)
%                 for iC = 1:size(int,2)
%                     if ~isnan(bl(iC)) && wl(iT,iC)>bl(iC)
%                         
%                         % ZTOP floats upward when waterlevel > ZTOP
%                         ZKlocal(end)                = max([wl(iT,iC) gridInfo.Zcen_int(end)]);
%                         
%                         % determine ksur and kbot
%                         ksur                        = find(ZKlocal >= wl(iT,iC),1);
%                         kbot                        = find(ZKlocal >= bl(iC),1) - 1;
%                         
%                         int(iT,iC,:)             =  ZKlocal;
%                         
%                         % update zcen_int for surface position
%                         if ksur < no_lay+1
%                             int(iT,iC,ksur+1:end) = NaN;
%                         end
%                         
%                         % update zcen_int for bottom position
%                         int(iT,iC,kbot)          = ZKlocal(kbot);
%                         if kbot > 1
%                             zcen_int(iT,iC,1:kbot-1)  = NaN;
%                         end
%                     end
%                 end
%             end

end

%% vertical centers at cell center
for i_lay = 1:no_lay
    cen(:,:,i_lay) = mean(int(:,:,[i_lay i_lay+1]),3);
end

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
