function fig2pngNew_joinTiles(OPT)
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
    tileCodes = char(tileCodes);
    newTiles = unique(tileCodes(:,1:end-1),'rows');
    
    for nn = 1:size(newTiles,1);
        imL = uint8(zeros(OPT.dim*2,OPT.dim*2,3));
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
        imS = ...
            imL(1:2:OPT.dim*2,1:2:OPT.dim*2,1:3)/4+...
            imL(2:2:OPT.dim*2,2:2:OPT.dim*2,1:3)/4+...
            imL(1:2:OPT.dim*2,2:2:OPT.dim*2,1:3)/4+...
            imL(2:2:OPT.dim*2,1:2:OPT.dim*2,1:3)/4;
        aaS = ...
            aaL(1:2:OPT.dim*2,1:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(1:2:OPT.dim*2,2:2:OPT.dim*2)/4+...
            aaL(2:2:OPT.dim*2,1:2:OPT.dim*2)/4;
        PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' newTiles(nn,:) '.png']);
        imwrite(imS,PNGfileName,'Alpha',aaS ,...
            'Author','$HeadURL$');
    end
end
