function KML_fig2pngNew_joinTiles(OPT)
%KML_FIG2PNGNEW_JOINTILES   subsidiary of KMLfig2pngNew
%
%See also:KMLfig2pngNew

for level = OPT.lowestLevel:-1:OPT.highestLevel+1
    tiles = dir(fullfile(OPT.Path,OPT.Name,[OPT.Name '_*.png']));
    tileCodes = nan(length(tiles),level);
    for ii = 1:length(tiles)
        begin =  findstr(tiles(ii).name,'_');
        if length(tiles(ii).name)-4-begin(end) == level
            tileCodes(ii,:) = tiles(ii).name(begin(end)+1:end-4);
        end
    end
    tileCodes(any(isnan(tileCodes),2),:) = [];
    tileCodes =   char(tileCodes);
    newTiles  = unique(tileCodes(:,1:end-1),'rows');
    
    for nn = 1:size(newTiles,1);
        imL = zeros(OPT.dim*2,OPT.dim*2,3);
        aaL = uint8(zeros(OPT.dim*2,OPT.dim*2));
        code = ['01';'23'];
        for ii = 1:2
            for jj = 1:2
                PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' newTiles(nn,:) code(ii,jj) '.png']);
                if exist(PNGfileName,'file')
                    [imL((ii-1)*OPT.dim+1:ii*OPT.dim,...
                         (jj-1)*OPT.dim+1:jj*OPT.dim,1:3),...
                        ignore,...
                        aaL((ii-1)*OPT.dim+1:ii*OPT.dim,...
                            (jj-1)*OPT.dim+1:jj*OPT.dim)] = imread(PNGfileName);
                end
            end
        end
        
        tmpL = +(aaL>0);
        tmpS =...
            tmpL(1:2:OPT.dim*2,1:2:OPT.dim*2)+...
            tmpL(2:2:OPT.dim*2,2:2:OPT.dim*2)+...
            tmpL(1:2:OPT.dim*2,2:2:OPT.dim*2)+...
            tmpL(2:2:OPT.dim*2,1:2:OPT.dim*2);    
        tmpS(tmpS==0) = 1;     
        
        mask = reshape(repmat(aaL==0,1,3),size(imL));
        imL(mask) = 0;
        
        imS = ...
            imL(1:2:OPT.dim*2,1:2:OPT.dim*2,1:3)+...
            imL(2:2:OPT.dim*2,2:2:OPT.dim*2,1:3)+...
            imL(1:2:OPT.dim*2,2:2:OPT.dim*2,1:3)+...
            imL(2:2:OPT.dim*2,1:2:OPT.dim*2,1:3);
        
        imS(:,:,1) = imS(:,:,1)./tmpS;
        imS(:,:,2) = imS(:,:,2)./tmpS;
        imS(:,:,3) = imS(:,:,3)./tmpS;
        
        imS = uint8(imS);
        
         aaS = ...
            aaL(1:2:OPT.dim*2,1:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(1:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,1:2:OPT.dim*2)/4;
        
        mask = reshape(repmat(aaS==0,1,3),size(imS));
        
        % now move image around to color transparent pixels with the value of the
                        % nearest neighbour.
        
        im2       = imS;
        im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
              bsxfun(@max,im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
        imS(mask) = im2(mask);
       
        PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' newTiles(nn,:) '.png']);
        imwrite(imS,PNGfileName,'Alpha',aaS ,...
            'Author','$HeadURL$');
    end
end
