outputDir = 'F:\KML\jarkus_grids\';
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
contents = opendap_folder_contents(url);
EPSG = load('EPSGnew');

% z scaling paramters:
a = 40; %lift up meters
b = 5;  %exagertaion
c = 30; %colormap limits

for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x    = nc_varget(contents{ii},   'x');
    y    = nc_varget(contents{ii},   'y');
    time = nc_varget(contents{ii},'time');

    %create output directory
    outputDir2 = [outputDir fname '_preview'];

    %Check dir, make if needed
    if ~isdir(outputDir2)
        mkdir(outputDir2);
    end

    % calculate coordinates, should not be necessary!!
    % it is though ... but it goes lightning fast anyways ;-)
    [x,y] = meshgrid(x,y);
    [lat,lon] = convertCoordinatesNew(x,y,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');

    % convert time to years
    time = datestr(time+datenum(1970,1,1),10);

    %loop through all the years
    for jj = size(time,1):-40:1

        % dispaly progress
        disp([num2str(ii) '/' num2str(length(contents)) ' ' fname ' ' time(jj,:)]);

        % load z data
        z = nc_varget(contents{ii},'z',[jj-1,0,0],[1,-1,-1]);

        % make sure there are no crazy high Z values
        % should not be necessary!!
        z(z>500) = nan;

        %scale z
        z= (z+a)*b;

        % and then do something, if it is not already done
        if exist([outputDir2 '/' time(jj,:) '_3D.kmz'],'file')
            disp([outputDir2 '/' time(jj,:) '_3D.kmz already exists'] )
        else
            KMLsurf(lat,lon,z,'fileName',[outputDir2 '/' time(jj,:) '_3D.kmz'],...
                'kmlName',[fname ' ' time(jj,:) ' 2D'],'lineWidth',0,...
                'colormap','colormapbathymetry','colorSteps',64,'cLim',[(a-c)*b (a+c)*b]);
        end
        if exist([outputDir2 '/' time(jj,:) '_2D.kmz'],'file')
            disp([outputDir2 '/' time(jj,:) '_3D.kmz already exists'] )
        else
            KMLpcolor(lat,lon,z,'fileName',[outputDir2 '/' time(jj,:) '_2D.kmz'],...
                'kmlName',[fname ' ' time(jj,:) ' 2D'],'lineWidth',0.3,'lineAlpha',.6,'fillAlpha',.8,...
                'colormap','colormapbathymetry','colorSteps',64,'cLim',[(a-c)*b (a+c)*b]);
        end
    end
end