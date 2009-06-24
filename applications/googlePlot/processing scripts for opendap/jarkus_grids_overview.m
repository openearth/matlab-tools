clear all
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
contents = opendap_folder_contents(url);
EPSG = load('EPSGnew');
for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x   = nc_varget(contents{ii},   'x');
    y   = nc_varget(contents{ii},   'y');
    x2 = [x(1) x(end) x(end) x(1) x(1)];
    y2 = [y(1) y(1) y(end) y(end) y(1)];
    [lat(:,ii),lon(:,ii)] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    markerNames{ii} = fname;
    markerLat(ii) = mean(lat(:,ii));
    markerLon(ii) = mean(lon(:,ii));
    markerX(ii,:)   = [min(x(:)) max(x(:))];
    markerY(ii,:)   = [min(y(:)) max(y(:))];
end

%% set options
OPT.fileName = 'Jarkus Grids.kml';
OPT.kmlName = 'Jarkus Grids';
OPT.lineWidth = 1;
OPT.lineColor = [0 0 0];
OPT.lineAlpha = 1;
OPT.openInGE = false;
OPT.reversePoly = false;
OPT.description = '';
OPT.text = '';
OPT.latText = mean(lat,1);
OPT.lonText = mean(lon,1);

%% start KML
OPT.fid=fopen(OPT.fileName,'w');
%% HEADER
OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0);
output = KML_header(OPT_header);
%% STYLE
OPT_style = struct(...
    'name',['style' num2str(1)],...
    'lineColor',OPT.lineColor(1,:) ,...
    'lineAlpha',OPT.lineAlpha(1),...
    'lineWidth',OPT.lineWidth(1));
output = [output KML_style(OPT_style)];

if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
    for ii = 2:length(lat(1,:))
        OPT_style.name = ['style' num2str(ii)];
        if length(OPT.lineColor(:,1))>1
            OPT_style.lineColor = OPT.lineColor(ii,:);
        end
        if length(OPT.lineWidth(:,1))>1
            OPT_style.lineWidth = OPT.lineWidth(ii,:);
        end
        if length(OPT.lineAlpha(:,1))>1
            OPT_style.lineAlpha = OPT.lineAlpha(ii,:);
        end
        output = [output KML_style(OPT_style)];
    end
end
%% marker BallonStyle

output = [output ...
    '<Style id="MarkerBalloonStyle">\n'...
    '<IconStyle><scale>1.2</scale><Icon>\n'...
	'<href>http://maps.google.com/mapfiles/kml/shapes/placemark_square.png</href>\n'...
	'</Icon></IconStyle>\n'...
	'<BalloonStyle>\n'...
	'<text><![CDATA[<h3>$[name]</h3>\n'...
 	'$[description]\n'...
 	'<hr />\n'...
 	'<br />Provided by:\n'...
 	'<img src="https://public.deltares.nl/download/attachments/16876019/OET?version=1" align="right" width="100"/>]]></text>'...
	'</BalloonStyle>\n'...
	'</Style>\n'];

%% print output
output = [output, '<Folder>'];
output = [output, '<Name>Outlines</Name>'];
fprintf(OPT.fid,output);
%% LINE
OPT_line = struct(...
    'name','',...
    'styleName',['style' num2str(1)],...
    'timeIn',[],...
    'timeOut',[],...
    'visibility',1,...
    'extrude',0);
% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;
for ii=1:length(lat(1,:))
    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
        OPT_line.styleName = ['style' num2str(ii)];
    end
    OPT_line.name = markerNames{ii};
    newOutput =  KML_line(lat(:,ii),lon(:,ii),'clampToGround',OPT_line);
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    if kk>1e5
        %then print and reset
        fprintf(OPT.fid,output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
end
fprintf(OPT.fid,output(1:kk-1)); % print output

%% labels
output = '</Folder>';
output = [output, '<Folder>'];
output = [output, '<Name>Outlines</Name>'];

%% generate markers  

%tableContents

baseString = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/jarkus/grids/';
for ii=1:length(lat(1,:))
    tableContents = [];
    tempString = [baseString markerNames{ii} '_preview/'];
    [html,status] = urlread([tempString 'contents.html']);
    if status
        for checkYear = 2010:-1:1950
            if isempty(strfind(html,[num2str(checkYear) '_2D.kmz']))
                str2D  = [];
            else
                str2D = [tempString num2str(checkYear) '_2D.kmz'];
            end
            if isempty(strfind(html,[num2str(checkYear) '_3D.kmz']))
                str3D  = [];
            else
                str3D = [tempString num2str(checkYear) '_3D.kmz'];
            end
            if ~(isempty(str2D)&&isempty(str3D))
                tableContents = [tableContents sprintf([...
                    '<tr><td>%d</td>'...year
                    '<td><a href="%s">2D</a></td>'....2D
                    '<td><a href="%s">3D</a></td></tr>\n'],....3D
                    checkYear,str2D,str3D)];
            end
        end
    end

    % generate table with data links
    if isempty(tableContents)
        table = 'No pre-rendered data available';
    else
        table = [...        
        '<h3>Available pre-rendered datafiles</h3>\n'...
        '<table border="0" padding="0" width="200">'...
        tableContents...
        '</table>'];
    end

    % generate description
    output = [output, sprintf([...
        '<Placemark>\n'...
        '<name>%s</name>\n'...name
        '<snippet></snippet>\n'...
        '<description><![CDATA[RD coordinates:  <br>\n'...
        'x: % 7.0f -% 7.0f<br>\n'...[xmin xmax]
        'y: % 7.0f -% 7.0f<br>\n'...[ymin ymax]
        '<hr />\n'...
        '%s'...table with links
        ']]></description>\n'...
        '<styleUrl>#MarkerBalloonStyle</styleUrl>\n'...
        '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>\n'...lat lon
        '</Placemark>\n'],...
        markerNames{ii},markerX(ii,:),markerY(ii,:),table,markerLon(ii),markerLat(ii))];
end
%% FOOTER
output = [output '</Folder>' KML_footer];
fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);
%% compress to kmz?
if strcmpi(OPT.fileName(end),'z')
    movefile(OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip(OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete([OPT.fileName(1:end-3) 'kml'])
end

