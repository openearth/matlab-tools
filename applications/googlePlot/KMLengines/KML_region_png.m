function [succes, kml_id] = KML_region_png(level,G,c,kml_id,OPT)
kml_id = kml_id+1;

%% make png
bgcolor = OPT.bgcolor;
if level>=0
    dim = OPT.dim;
else
    dim = round(OPT.dim/2^-level);
end
set(OPT.hf,'PaperUnits', 'inches','PaperPosition',[0 0 dim+2*OPT.dimExt dim+2*OPT.dimExt],'color',bgcolor/255,'InvertHardcopy','off');
c.dNS = OPT.dimExt/dim*(c.N - c.S);
c.dWE = OPT.dimExt/dim*(c.E - c.W);
set(OPT.ha,'YLim',[c.S - c.dNS c.N + c.dNS]);
set(OPT.ha,'XLim',[c.W - c.dWE c.E + c.dWE]);

PNGfileName = fullfile(OPT.Path,OPT.Name,sprintf('%05d.png',kml_id));
print(OPT.hf,'-dpng','-r1',PNGfileName);

im = imread(PNGfileName);
im = im(OPT.dimExt+1:OPT.dimExt+dim,OPT.dimExt+1:OPT.dimExt+dim,:);
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

if level==OPT.levels(1)
    minLod = OPT.minLod0;
else
    if level<0
        minLod = OPT.minLod/(2^-level);
    else
        minLod = OPT.minLod;
    end
end

if level == OPT.levels(2)
    maxLod = OPT.maxLod0;
else
    if level<0
        maxLod = OPT.maxLod/(2^-level);
    else
        maxLod = OPT.maxLod;
    end
end

%% generate the bounding box
output = sprintf([...
    '<Region>\n'...
    '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
    '</Region>\n'],...
    minLod,maxLod,...
    c.N,c.S,c.W,c.E);

%% add network link for the four subdivisions (if applicable)
if level<OPT.levels(2)
    level2  = level+1;
    kml_id2 = kml_id;
    if level<0
        latSubDivisions = 1;
        lonSubDivisions = 1;
    else
        latSubDivisions = OPT.latSubDivisions;
        lonSubDivisions = OPT.lonSubDivisions;
    end
    % sub coordinates
    c2.NS    = linspace(c.N,c.S,latSubDivisions+1);
    c2.WE    = linspace(c.W,c.E,lonSubDivisions+1);
    % there are one or four possible subdivisions
    for nn = 1:(latSubDivisions*lonSubDivisions)
        % set bounding subbox coordinates
        [ii,jj] = ind2sub([latSubDivisions lonSubDivisions],nn);
        c2.N = c2.NS(ii); c2.S = c2.NS(ii+1);
        c2.W = c2.WE(jj); c2.E = c2.WE(jj+1);
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
                '%s'...time
                '<Region>\n'...
                '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                '</Region>\n'...
                '<Link><href>%05d.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                '</NetworkLink>\n'],...
                kml_id2+1,...
                timeSpan,...
                minLod,-1,...
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
    '<drawOrder>%d</drawOrder>\n'...drawOrder
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
if level<OPT.levels(2)
    kml_id = kml_id2;
end

succes = true;
