function KML_fig2pngNew_printTile(baseCode,D,OPT)
for addCode = ['0','1','2','3']
    code = [baseCode addCode];
    B   = KML_fig2pngNew_code2boundary(code);
    
    % stop if tile is out of bounds
    if ~((D.E>B.W&&D.W<B.E)&&(D.N>B.S&&D.S<B.N))
       fprintf('%-16s %-10s Reason: %s\n',code,'ABORTED','tile out of bounds')
    else
        
        R   = D.lon>=(B.W - OPT.dWE) & D.lon<=B.E + OPT.dWE &...
            D.lat>=(B.S - OPT.dNS) & D.lat<=B.N + OPT.dNS;
        
        % stop if no data is present in tile
        if ~any(R(:))
                  fprintf('%-16s %-10s Reason: %s\n',code,'ABORTED','no data in tile')
        else
            
            D2.z   = D.z  (any(R'),any(R));
            if all(isnan(D2.z(:)))
          fprintf('%-16s %-10s Reason: %s\n',code,'ABORTED','only NAN''s in tile')
            else
                D2.lat = D.lat(any(R'),any(R));
                D2.lon = D.lon(any(R'),any(R));
                D2.N = max(D.lat(:));
                D2.S = min(D.lat(:));
                D2.W = min(D.lon(:));
                D2.E = max(D.lon(:));
                % stop if no data is present in tile
                
                
                if length(code) < OPT.lowestLevel
                    fprintf('%-16s %-10s\n',code,'CONTINUING')
                    fig2pngNew_printTile(code,D2,OPT)
                else
                     fprintf('%-16s %-10s',code,'PRINTING TILE')
                    
                    dNS = OPT.dimExt/OPT.dim*(B.N - B.S);
                    dWE = OPT.dimExt/OPT.dim*(B.E - B.W);
                    
                    set(OPT.h,'ZDATA',D2.z,'YDATA',D2.lat,'XDATA',D2.lon)
                    set(OPT.ha,'YLim',[B.S - dNS B.N + dNS]);
                    set(OPT.ha,'XLim',[B.W - dWE B.E + dWE]);
                    
                    PNGfileName = fullfile(OPT.Path,OPT.Name,[OPT.Name '_' code '.png']);
                    
                    % read a previous image if necessary
                    mergeExistingTiles = false;
                    if OPT.mergeExistingTiles
                        if exist(PNGfileName,'file')
                            [oldIm ignore oldImAlpha] = imread(PNGfileName);
                            mergeExistingTiles = true;
                        end
                    end
                    print(OPT.hf,'-dpng','-r1',PNGfileName);
                    
                    im   = imread(PNGfileName);
                    im   = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
                    mask = bsxfun(@eq,im,reshape(OPT.bgcolor,1,1,3));
                    mask = repmat(all(mask,3),[1 1 3]);
                    
                    % merge data from different tiles
                    if mergeExistingTiles
                        oldIm(~mask) = im(~mask);
                        im = oldIm;
                        mask(repmat(oldImAlpha>0,[1 1 3])) = false;
                    end
                    
                    
                    % return if no data is present in tile
                    if all(mask(:))
                        delete(PNGfileName)
                            fprintf(' ...TILE DELETED, no data in tile\n')
                    else
                        fprintf('\n')
                        % now move image around to color transparent pixels with the value of the
                        % nearest neighbour.
                        im2       = im;
                        im2(mask) = 0;
                        im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
                            bsxfun(@max,im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
                        im(mask) = im2(mask);
                        imwrite(im,PNGfileName,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))),...
                            'Author','$HeadURL$'); % NOT 'Transparency' as non-existent pixels have alpha = 0
                    end
                end
            end
        end
    end
end


