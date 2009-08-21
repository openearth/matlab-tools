function kml_id = KML_region_png(level,G,c,kml_id,PNGfileName,OPT)
bgcolor = OPT.bgcolor;

%% generate the bounding box
output = sprintf([...
    '<Region>\n'...
    '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</Region>\n'],...
    OPT.minLod,OPT.maxLod,...
    c.N,c.S,c.W,c.E);

%% add network link for the four subdivisions (if applicable)
if level<OPT.levels
    level2  = level+1;
    kml_id2 = kml_id;
    OPT.minLod;
    if level2 == OPT.levels
        OPT.maxLod = OPT.maxLod0;
    else
        OPT.maxLod = OPT.maxLod;
    end
    % sub coordinates
    c.NS    = linspace(c.N,c.S,3);
    c.WE    = linspace(c.W,c.E,3);
    % there are four possible subdivisions
    for nn = 1:4
        % set bounding subbox coordinates
        [ii,jj] = ind2sub([2 2],nn);
        c2.N = c.NS(ii); c2.S = c.NS(ii+1);
        c2.W = c.WE(jj); c2.E = c.WE(jj+1);
        % and delta coordinates, used to make a plot of a larger region,
        % that will consequently be cropped. Because of a MatLab quirk
        c2.dNS = OPT.dimExt/OPT.dim*(c2.N - c2.S);
        c2.dWE = OPT.dimExt/OPT.dim*(c2.E - c2.W);
        % check if there is data
        if any(~isnan(G.z(G.lat<=c.N&G.lat>=c.S&G.lon>=c.W&G.lon<=c.E)))
            kml_id2 = kml_id2+1;     
            PNGfileName2 = fullfile(OPT.Path,OPT.Name,sprintf('%05d.png',kml_id2));
            % make png
            set(OPT.ha,'YLim',[c2.S - c2.dNS c2.N + c2.dNS]);
            set(OPT.ha,'XLim',[c2.W - c2.dWE c2.E + c2.dWE]);
            print(OPT.hf,'-dpng','-r1',PNGfileName2);
            im = imread(PNGfileName2);
            im = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
            mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));
            imwrite(im,PNGfileName2,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))))

            % call the function to make even more subdivisions
            kml_id3 = KML_region_png(level2,G,c2,kml_id2,PNGfileName2,OPT);

            % add the network link to the newly made KML file
            output = [output sprintf([...
                '<NetworkLink>\n'...
                '<name>%05d</name>\n'...name
                '<Region>\n'...
                '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                '</Region>\n'...
                '<Link><href>%05d.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                '</NetworkLink>\n'],...
                kml_id2,...
                OPT.minLod,OPT.maxLod,...
                c2.N,c2.S,c2.W,c2.E,...
                kml_id2)];
            kml_id2 = kml_id3;
        end
    end
end

% add png to kml
output = [output sprintf([...
    '<GroundOverlay>\n'...
    '<name>%05d</name>\n'...file_name
    '<Icon><href>%s</href></Icon>\n'...%file_link
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</GroundOverlay>\n'],...
    kml_id,...
    PNGfileName,...
    c.N,c.S,c.W,c.E)];


%% write the KML
OPT.fid=fopen(fullfile(OPT.Path,OPT.Name,sprintf('%05d.kml',kml_id)),'w');
OPT_header = struct(...
    'name',['png' num2str(kml_id)],...
    'open',0);
output = [KML_header(OPT_header) output];
% FOOTER
output = [output KML_footer];
fprintf(OPT.fid,'%s',output);
% close KML
fclose(OPT.fid);

%% update sequence
if level<OPT.levels
    kml_id = kml_id2;
end
