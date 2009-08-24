function [succes, kml_id] = KML_region_png(level,G,c,kml_id,OPT)
kml_id = kml_id+1;

%% make png
bgcolor = OPT.bgcolor;
PNGfileName = fullfile(OPT.Path,OPT.Name,sprintf('%05d.png',kml_id));
set(OPT.ha,'YLim',[c.S - c.dNS c.N + c.dNS]);
set(OPT.ha,'XLim',[c.W - c.dWE c.E + c.dWE]);
print(OPT.hf,'-dpng','-r1',PNGfileName);
im = imread(PNGfileName);
im = im(OPT.dimExt+1:OPT.dimExt+OPT.dim,OPT.dimExt+1:OPT.dimExt+OPT.dim,:);
mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));

%% preproces timespan
if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...OPT.timeIn
            '<end>%s</end>\n'...OPT.timeOut
            '</TimeSpan>\n'],...
            OPT.timeIn,OPT.timeOut);
    else
        timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...OPT.timeIn
            '</TimeStamp>\n'],...
            OPT.timeIn);
    end
else
    timeSpan ='';
end

%% check if there is non transparent info in the png.
if all(all(mask,3))
    kml_id = kml_id-1;
    delete(PNGfileName)
    succes = false;
    return
end
imwrite(im,PNGfileName,'Alpha',OPT.alpha*ones(size(mask(:,:,1))).*(1-double(all(mask,3))))

if level==1
    minLod = OPT.minLod0;
else
    minLod = OPT.minLod;
end
%% generate the bounding box
output = sprintf([...
    '<Region>\n'...
    '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</Region>\n'],...
    minLod,OPT.maxLod,...
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
     
        % call the function to make even more subdivisions
        [succes, kml_id3] = KML_region_png(level2,G,c2,kml_id2,OPT);
        
        if succes
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
            kml_id2+1,...
            OPT.minLod,OPT.maxLod,...
            c2.N,c2.S,c2.W,c2.E,...
            kml_id2+1)];
            kml_id2 = kml_id3;
        end
    end
end


% add png to kml
output = [output sprintf([...
    '<GroundOverlay>\n'...
    '<name>%05d</name>\n'...kml_id
    '<drawOrder>%d</drawOrder>\n...'...drawOrder
    '%s'...timeSpan
    '<Icon><href>%05d.png</href></Icon>\n'...%file_link
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</GroundOverlay>\n'],...
    kml_id,OPT.drawOrder+level,timeSpan,...
    kml_id,...
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

succes = true;
