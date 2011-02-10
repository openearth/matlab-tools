function varargout = KMLsurf_tiled(lat,lon,z,varargin)
%KMLSURF_TILED  BETA!!!!
%
% Experimental function to tile patches of a KMLsurf plot. 
%
%  KMLsurf_tiled(lat,lon,z)
%
%See also: googlePlot, surf

% [lat,lon] = meshgrid(54:1/255:55,4:1/127:5);
% z = abs(peaks(256))*500;
% z(z<100) = nan;

%% process <keyword,value>
   % get colorbar options first
   OPT                    = KMLcolorbar();
   OPT                     = mergestructs(OPT,KML_header());
   % rest of the options
   OPT.fileName           = '';
   OPT.lineWidth          = 1;
   OPT.lineColor          = [0 0 0];
   OPT.lineAlpha          = 1;
   OPT.colorMap           = @(m) jet(m); % function(OPT.colorSteps) or an rgb array
   OPT.colorSteps         = 16;
   OPT.cLim               = [-20 20];
   OPT.fillAlpha          = 1;
   OPT.polyOutline        = 0;
   OPT.polyFill           = 1;
   OPT.zScaleFun          = @(z) (z+20)*5;
   OPT.colorbar           = 1;

   if nargin==0
      varargout = {OPT};
      return
   end

%% set properties

   [OPT, Set, Default] = setproperty(OPT, varargin{:});

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% pre-process color data

   if isempty(OPT.cLim)
      OPT.cLim         = [min(z(:)) max(z(:))];
   end

   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
   end
   
   if isa(OPT.colorMap,'function_handle')
     colorRGB           = OPT.colorMap(OPT.colorSteps);
   elseif isnumeric(OPT.colorMap)
     if size(OPT.colorMap,1)==1
       colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
     elseif size(OPT.colorMap,1)==OPT.colorSteps
       colorRGB         = OPT.colorMap;
     else
       error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
     end
   end

   % clip c to min and max 

   z(z<OPT.cLim(1)) = OPT.cLim(1);
   z(z>OPT.cLim(2)) = OPT.cLim(2);

   %  convert color values into colorRGB index values

   c = round(((z-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');
   
   OPT_header = struct(...
       'name',OPT.kmlName,...
       'open',0);
   output = KML_header(OPT_header);

   if OPT.colorbar
      clrbarstring = KMLcolorbar(OPT);
      output = [output clrbarstring];
   end

%% STYLE

   OPT_stylePoly = struct(...
       'name'       ,['style' num2str(1)],...
       'fillColor'  ,colorRGB(1,:),...
       'lineColor'  ,OPT.lineColor,...
       'lineAlpha'  ,OPT.lineAlpha,...
       'lineWidth'  ,OPT.lineWidth,...
       'fillAlpha'  ,OPT.fillAlpha,...
       'polyFill'   ,OPT.polyFill,...
       'polyOutline',OPT.polyOutline); 
   for ii = 1:OPT.colorSteps
       OPT_stylePoly.name      = ['style' num2str(ii)];
       OPT_stylePoly.fillColor = colorRGB(ii,:);
       if strcmpi(OPT.lineColor,'fillColor')
           OPT_stylePoly.lineColor = colorRGB(ii,:);
       end
       output = [output KML_stylePoly(OPT_stylePoly)];
   end

%% print and clear output

   fprintf(OPT.fid,output);
   output = repmat(char(1),1,1e6);
   kk = 1;
   
   OPT.minpow = 4;
   
   for xx = 2.^(10:-1:1) % 1024, 512, 256, 128, 64, 32, 16,8, 4, 2, 1
   if xx > OPT.minpow
   %%%% disp(['debug: ',num2str(xx)])
      mm = [1:xx:size(lat,1)-1 size(lat,1)]; % always use last element of dimension
      nn = [1:xx:size(lat,2)-1 size(lat,2)]; % always use last element of dimension
      for ii=1:length(mm)-1
         for jj=1:length(nn)-1
            
            lat2 = lat(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            lon2 = lon(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            z2   =   z(mm(ii):mm(ii+1),nn(jj):nn(jj+1));
            
            whos lat2 lon2 z2
            
            %%%% whos; pausedisp
            if ~all(isnan(z2))
                [a b] = size(z2);
                 cv   = [1,a,b*a,(b-1)*a+1,1]'; % MAGIC simple surbounding box for case of full grid (no nans)
                if any(isnan(z2(cv)))
                    lat3 = lat2(~isnan(z2));
                    lon3 = lon2(~isnan(z2));
                    z3   =   z2(~isnan(z2));
                    try
                    cv   = flipud(convhull(lat3,lon3));
                    catch
                        break
                    end
                else
                    lat3 = lat2;
                    lon3 = lon2;
                    z3   =   z2;
                end
                coords=[lon3(cv) lat3(cv) OPT.zScaleFun(z3(cv))]';
                
                % define color
                level = round((sum(z3(cv))/numel(cv))-OPT.cLim(1)/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1;
                level = min(max(level,1),OPT.colorSteps);
                
                coordinates  = sprintf(...
                    '%3.8f,%3.8f,%3.3f ',...coords);
                    coords);
                
                if xx == OPT.minpow
                    maxLod = -1;
                else
                    maxLod = 50;
                end

                %mean(z3(cv))
                newOutput = sprintf([...
                    '<Placemark><name>Region LineString</name>\n'...
                    '<styleUrl>#%s</styleUrl>\n'...
                    '<Polygon><altitudeMode>absolute</altitudeMode><outerBoundaryIs><LinearRing><coordinates>%s</coordinates></LinearRing></outerBoundaryIs></Polygon>\n'... % coordinates
                    '<Region>\n'...
                    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><east>%3.8f</east><west>%3.8f</west><minAltitude>-1000</minAltitude><maxAltitude>1000</maxAltitude></LatLonAltBox>\n'... % N,S,E,W
                    '<Lod><minLodPixels>22</minLodPixels>\n'...
                    '<maxLodPixels>%d</maxLodPixels></Lod>\n'... % maxLod
                    '</Region>\n'...
                    '</Placemark>\n'],...
                    sprintf('style%d',level),... % color
                    coordinates,...
                    max(lat3(cv)),min(lat3(cv)),max(lon3(cv)),min(lon3(cv)),...
                    maxLod);
                %<minFadeExtent>32</minFadeExtent><maxFadeExtent>64</maxFadeExtent>
                output(kk:kk+length(newOutput)-1) = newOutput;
                kk = kk+length(newOutput);
                if kk>1e6
                    %then print and reset
                    fprintf(OPT.fid,output(1:kk-1));
                    kk = 1;
                    output = repmat(char(1),1,1e6);
                end
            end % isnan
         end % jj
      end % ii
   end % minpow
   end % xx
   fprintf(OPT.fid,output(1:kk-1));
   output = KML_footer;
   fprintf(OPT.fid,output);

%% close KML

   fclose(OPT.fid);