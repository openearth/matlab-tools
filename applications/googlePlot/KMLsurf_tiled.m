function KMLsurf_tiled(lat,lon,z)


%[lat,lon] = meshgrid(54:1/255:55,4:1/127:5);
%z = abs(peaks(256))*500;
%z(z<100) = nan;


z = z(1:128,:);
OPT.fileName = 'test.kml';
OPT.kmlName = 'test';
OPT.lineWidth = 1;
OPT.lineColor = [0 0 0];
OPT.lineAlpha = 1;
OPT.colormap = 'jet';
OPT.colorSteps = 16;
OPT.cLim       = [0 2500];
OPT.fillAlpha = 1;
OPT.polyOutline = 0;
OPT.polyFill = 1;
%% start KML
OPT.fid=fopen(OPT.fileName,'w');
%% HEADER
OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0);
output = KML_header(OPT_header);
%% Style
colors = jet(16);
OPT_stylePoly = struct(...
    'name',['style' num2str(1)],...
    'fillColor',colors(1,:),...
    'lineColor',OPT.lineColor ,...
    'lineAlpha',OPT.lineAlpha,...
    'lineWidth',OPT.lineWidth,...
    'fillAlpha',OPT.fillAlpha,...
    'polyFill',OPT.polyFill,...
    'polyOutline',OPT.polyOutline);

for ii = 1:OPT.colorSteps
    OPT_stylePoly.name = ['style' num2str(ii)];
    OPT_stylePoly.fillColor = colors(ii,:);
    output = [output KML_stylePoly(OPT_stylePoly)];
end

%% print and clear output
fprintf(OPT.fid,output);
output = repmat(char(1),1,1e5);
kk = 1;


for xx = 2.^(8:-1:1)
    mm = [1:xx:size(lat,1)-1 size(lat,1)];
    nn = [1:xx:size(lat,2)-1 size(lat,2)];
    for ii=1:length(mm)-1
        for jj=1:length(nn)-1
            
            lat2 = lat(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            lon2 = lon(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            z2 =   z(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            if ~all(isnan(z2))
                [a b] = size(z2);
                cv   = [1,a,b*a,(b-1)*a+1,1]';
                if isnan(any(z2(cv)))
                    cv   = flipud(convhull(lat3,lon3));
                    coords=[lon3(cv) lat3(cv) z3(cv)]';
                    lat3 = lat2(~isnan(z2));
                    lon3 = lon2(~isnan(z2));
                    z3   =   z2(~isnan(z2));
                else
                    coords=[lon2(cv) lat2(cv) z2(cv)]';
                    lat3 = lat2;
                    lon3 = lon2;
                    z3   =   z2;
                end
                
                level = round(min(max(sum(z3(cv))/numel(cv),OPT.cLim(1)),OPT.cLim(2))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;
                
                coordinates  = sprintf(...
                    '%3.8f,%3.8f,%3.3f ',...coords);
                    coords);
                
                %mean(z3(cv))
                newOutput = sprintf([...
                    '<Placemark><name>Region LineString</name>\n'...
                    '<styleUrl>#%s</styleUrl>\n'...
                    '<Polygon><altitudeMode>absolute</altitudeMode><outerBoundaryIs><LinearRing><coordinates>%s</coordinates></LinearRing></outerBoundaryIs></Polygon>\n'...coordinates
                    '<Region>\n'...
                    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><east>%3.8f</east><west>%3.8f</west><minAltitude>0</minAltitude><maxAltitude>1000</maxAltitude></LatLonAltBox>\n'...N,S,E,W
                    '<Lod><minLodPixels>32</minLodPixels><maxLodPixels>72</maxLodPixels></Lod>\n'...
                    '</Region>\n'...
                    '</Placemark>\n'],...
                    sprintf('style%d',level),...
                    coordinates,...
                    max(lat3(cv)),min(lat3(cv)),max(lon3(cv)),min(lon3(cv)));
                %<minFadeExtent>32</minFadeExtent><maxFadeExtent>64</maxFadeExtent>
                output(kk:kk+length(newOutput)-1) = newOutput;
                kk = kk+length(newOutput);
                if kk>1e5
                    %then print and reset
                    fprintf(OPT.fid,output(1:kk-1));
                    kk = 1;
                    output = repmat(char(1),1,1e5);
                end
            end
        end
    end
end
fprintf(OPT.fid,output(1:kk-1));
output = KML_footer;
fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);