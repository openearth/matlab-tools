function OPT = nc_cf_harvest_matrix2kml(ATT,varargin)
%NC_CF_HARVEST_MATRIX2KML save harvested THREDDS catalog to catalog.xls
%
% nc_cf_harvest_matrix2kml(ATT,<keyword,value>)
%
% where ATT = NC_CF_OPENDAP2CATALOG() generates an overview
% for Google Earth of timeseries locations, incl. previews
% of the time series.
%
%See also: nc_cf_harvest, googleplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011-2013 Deltares for Nationaal Modellen en Data centrum (NMDC),
%                           Building with Nature and internal Eureka competition.
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$
% 2009-10-07: Routine changed to allow for numeric station IDs and station names [Yann Friocourt]

% 2012-12-12: CF-1.6: platform_id, platform_name

% TO DO: allow for multiple parameters in one kml file instead of one per kml
% TO DO: allow for more types of ATT: 
%        mysql, netcdf file in opendap itself, csv file, opendap catalog.xml

%% set options

   OPT.fileName           = [];
   OPT.description        = '';
   OPT.kmlName            = 'tst.kml';
   OPT.openInGE           = false;
   OPT.text               = '';
   OPT.name               = [];
   OPT.lon                = [];
   OPT.lat                = [];
   OPT.z                  = [];
   OPT.open               = 0;
   
   OPT.logokmlName        = 'OpenEarth logo';
   OPT.overlayXY          = [0 0.00];
   OPT.screenXY           = [0 0.04];
   OPT.imName             = [fileparts(oetlogo),filesep,'oet4GE.png'];
   OPT.logoName           = 'OET4GE.png';

   OPT.iconnormalState         = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
   OPT.iconhighlightState      = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
   OPT.iconnormalStateScale    = 2;
   OPT.iconhighlightStateScale = 3;
   
   OPT.varname            = []; % statistics
   OPT.preview            = 0;  % add 2 previews of - and hence requires - varname
   OPT.credit             = 'Plot created with: www.OpenEarth.eu';
   OPT.varPathFcn         = @(s)(s); % function to run on urlPath, when using it, not when linking it: for reading local netCDF files, when CATALOG links to server already
   OPT.resolveUrl         = @(x) x;
   OPT.resolveName        = '';

% EXAMPLE:
%  THREDDS http://opendap.deltares.nl   /thredds/dodsC/opendap/     rijkswaterstaat/waterbase/sea_surface_wave_significant_height/id22-AUKFPFM.nc.html
%  ftp     http://opendap.deltares.nl   /thredds/fileServer/opendap/rijkswaterstaat/waterbase/sea_surface_wave_significant_height/id22-AUKFPFM.nc
%  HYRAX * http://opendap.deltares.nl   /opendap/                   rijkswaterstaat/waterbase/sea_surface_wave_significant_height/id22-AUKFPFM.nc.html
%  * = has issues with snctools
   OPT.THREDDSFcn         = @(s) (s); % assuming the supplied url's are THREDDS (HYRAX has issues anyway)
   OPT.ftpFcn             = @(s) strrep(s,'/thredds/dodsC/opendap/','/thredds/fileServer/opendap/');

   if nargin==0
      return
   end
   
   OPT = setproperty(OPT,varargin{:});
   
   varname = OPT.varname;

%% get meta data

   if isstruct(ATT)
   
      D = ATT;
      
   elseif strcmpi(fileext(c),'.nc')
   
      D = nc2struct(ATT);

   elseif strcmpi(fileext(ATT),'.xls')
   
      warning([mfile ,' now uses catalog.nc instead of catalog.xls'])

     [D,units] = xls2struct(ATT);

   else

      error('database type not implemented, only xls for now')
      % * THREDDS catalogue (opendap_folder_contents etc)
      % * matroos type mysql database
      % * OGC WCS
      % * MyOcean / EuroGoos CAMIOON
      % * SDN CDi
      % * ISO 9__whatever
      % * INSPIRE

   end

%% make character to cellstr

   fldnames = fieldnames(D);
   for ifld=1:length(fldnames)
      fldname = fldnames{ifld};
      if ischar(D.(fldname))
         D.(fldname) = cellstr(D.(fldname));
      end
   end

%% make platform_id a character

   if isnumeric(D.platform_id)
       D.platform_id = cellstr(num2str(D.platform_id));
   else % sometimes is mixture of numeric and char
     for i = 1:length(D.platform_id)
         if isnumeric(D.platform_id{i})
             D.platform_id{i} = num2str(D.platform_id{i});
         end
     end
     %for i = 1:length(D.platform_name)
     %    if isnumeric(D.platform_name{i})
     %        D.platform_name{i} = num2str(D.platform_name{i});
     %    end
     %end
   end

%% HEADER and initial zoom

   if isempty(OPT.lon);OPT.lon = mean(D.geospatialCoverage_eastwest_start  );end
   if isempty(OPT.lat);OPT.lat = mean(D.geospatialCoverage_northsouth_start);end
   if isempty(OPT.z  );OPT.z   = 100e4;            end

   OPT_header = struct(...
      'kmlName',OPT.kmlName,...
  'description',OPT.description,...
         'open',OPT.open,...
    'cameralon',OPT.lon,...
    'cameralat',OPT.lat,...
      'cameraz',OPT.z,...
       'timeIn',min(D.timeCoverage_start),... % does not work for old catyalogs any more: regenerate with latest nc_cf_opendap2catalog
      'timeOut',max(D.timeCoverage_end));
   output = KML_header(OPT_header);
   
%% marker BallonStyle

   output = [output ...
    '<Style id="normalState"   >'...
    '  <IconStyle><scale>' num2str(OPT.iconnormalStateScale) '</scale><Icon><href>'...
    '  ' OPT.iconnormalState ''...
    '  </href></Icon></IconStyle>'...
    '  <LabelStyle><scale>0</scale></LabelStyle>'...
    '  </Style>'...
    '<Style id="highlightState">'...
    '  <IconStyle><scale>' num2str(OPT.iconhighlightStateScale) '</scale><Icon><href>'...
    '  ' OPT.iconhighlightState ''...
    '  </href></Icon></IconStyle>'...
    '  <BalloonStyle>'...
    '  <text><![CDATA[<h3>$[name]</h3>'...
    '  $[description]<br>Provided by:'...
    '  <img src="',filenameext(oetlogo),'" align="right" width="100"/>]]></text>'...
    '  </BalloonStyle></Style>'...
    '<StyleMap id="MarkerBalloonStyle">'...
    '  <Pair><key>normal</key><styleUrl>#normalState</styleUrl></Pair> '...
    '  <Pair><key>highlight</key><styleUrl>#highlightState</styleUrl></Pair> '...
    '  </StyleMap>'];

%% labels

   output = [output, sprintf('\n%s','<Folder>')];
   output = [output, sprintf('\n%s','<open>',num2str(OPT.open),'</open>')];
   output = [output, sprintf('\n%s','<name>Platforms</name>')];

%% generate markers
%  TO DO: pre-allocate output (printing images takes longer, so speed-up will be marginal)?

   pngname1      = {};
   pngname2      = {};

   multiWaitbar(mfilename,0,'label','Making kml overview of timeSeries ','color',[0.3 0.6 0.3])

   for ii=1:length(D.geospatialCoverage_eastwest_start)
    disp(sprintf('writing coordinates: % 2d / %d',ii,length(D.geospatialCoverage_eastwest_start)));
    multiWaitbar(mfilename,ii/length(D.geospatialCoverage_eastwest_start))

    % generate table with data info
    tableContents = [];
    preview       = '';
       
    if ~isempty(OPT.resolveName)
    resolvestring = ['<tr><td bgcolor="#FFFFFF">source:       </td><td bgcolor="#FFFFFF"><a href="',OPT.resolveUrl{ii},'">',OPT.resolveName,'</a></td></tr>'];
    else
    resolvestring = '';
    end
       
    if ~isempty(OPT.varname)

    %% get statistics and make images
    
       ncfile = OPT.varPathFcn(D.urlPath{ii});
       
           [DATA,META] = nc_cf_timeseries(ncfile,varname,'plot',-OPT.preview*2);
       units.(varname) = META.(varname).units;
       
       if OPT.preview
          pngname1{ii} = [fileparts(OPT.fileName),D.platform_id{ii},'.png'];
          text(1,0,{OPT.credit},'rotation',90,'units','normalized','ve','top')
          set(findfont,'fontsize',7);print2screensizeoverwrite(pngname1{ii},400);clf

          pngname2{ii} = [fileparts(OPT.fileName),D.platform_id{ii},'_hist.png'];
          hist(DATA.(varname),50)
          xlabel(mktex([META.(varname).long_name,' [',META.(varname).units,']']))
          ylabel(['# (total # ',num2str(length(DATA.(varname))),')'])
          grid on
          text(1,0,{OPT.credit},'rotation',90,'units','normalized','ve','top')
          set(findfont,'fontsize',7);print2screensizeoverwrite(pngname2{ii},400);clf
          preview  = ['<img src="',filenameext(pngname1{ii}),'" alt="Preview">'...
                      '<img src="',filenameext(pngname2{ii}),'" alt="Preview">'];
          close all

       end
       
       D.([varname,'_min'])(ii)  =  nanmin(DATA.(varname));
       D.([varname,'_max'])(ii)  =  nanmax(DATA.(varname));
       D.([varname,'_mean'])(ii) = nanmean(DATA.(varname));
       D.([varname,'_std'])(ii)  =  nanstd(DATA.(varname));
       
    %% make table
    
       %fmt1 = ['%',num2str(max(cellfun(@(x) length(x),D.platform_name))),'s'];
       %fmt2 = ['%',num2str(max(cellfun(@(x) length(x),D.platform_id  ))),'s'];

       tableContents = [tableContents sprintf([...
        '<tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">where:</div></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">platform name:</td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">platform code:</td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">coordinates:  </td><td bgcolor="#FFFFFF">(%7.5f N,%7.5f E)</td></tr>'...
        '<tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">when:</div></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">time start:   </td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">time end:     </td><td bgcolor="#FFFFFF">%s</td></tr>',...
        '<tr><td bgcolor="#FFFFFF">time (#):     </td><td bgcolor="#FFFFFF">%g</td></tr>'...
        '<tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">what:</div></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">min:          </td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">mean:         </td><td bgcolor="#FFFFFF">%s</td></tr>',...
        '<tr><td bgcolor="#FFFFFF">max:          </td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">std:          </td><td bgcolor="#FFFFFF">%s</td></tr>',...
        '<tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">access:</div></td></tr>'...
        '%s',...
        '<tr><td bgcolor="#FFFFFF">meta-data view before data access:  </td><td bgcolor="#FFFFFF"><a href="%s">OPeNDAP (THREDDS)</a></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">direct data download:  </td><td bgcolor="#FFFFFF"><a href="%s">ftp server       </a></td></tr>'...%link to timeseries
        ],...
        strtrim(D.platform_name{ii}),...
        upper(strtrim(D.platform_id{ii})),...
        D.number_of_observations(ii),...
        D.geospatialCoverage_eastwest_start(ii),...
        D.geospatialCoverage_northsouth_start(ii),...
        datestr(D.timeCoverage_start(ii),31),...
        datestr(D.timeCoverage_end(ii),31),...
       [num2str(D.([OPT.varname,'_min' ])(ii),'%g'),' ',units.([varname])],...
       [num2str(D.([OPT.varname,'_mean'])(ii),'%g'),' ',units.([varname])],...
       [num2str(D.([OPT.varname,'_max' ])(ii),'%g'),' ',units.([varname])],...
       [num2str(D.([OPT.varname,'_std' ])(ii),'%g'),' ',units.([varname])],...
        resolvestring,...
        OPT.THREDDSFcn([D.urlPath{ii},'.html']),...
            OPT.ftpFcn([D.urlPath{ii}]))];

    else
    
       variable_name = strtokens2cell(D.variable_name{i});
       standard_name = strtokens2cell(D.standard_name{i});
       long_name     = strtokens2cell(D.long_name{i});
       units         = strtokens2cell(D.units{i});
    
       paramstring =               '<tr><td colspan="2" bgcolor="#999999"><div style="color:#FFFFFF;">what:</div></td></tr>';
       for j=1:length(variable_name)
       paramstring = [paramstring, '<tr><td colspan="2" bgcolor="#FFFFFF"><div style="color:#000000;">',variable_name{j},':<br><b>',standard_name{j},'</b>&nbsp[',units{j},']<br>&nbsp"<i>',long_name{j},'</i>"</div></td></tr>'];
       end
    
       %fmt1 = ['%',num2str(max(cellfun(@(x) length(x),D.platform_name))),'s'];
       %fmt2 = ['%',num2str(max(cellfun(@(x) length(x),D.platform_id  ))),'s'];
       
       tableContents = [tableContents sprintf([...
        '<tr><td colspan="2" bgcolor="#999999"><div style="color:#FFFFFF;">where:</div></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">platform name:</td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">platform code:</td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">longitude:    </td><td bgcolor="#FFFFFF">%g</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">latitude:     </td><td bgcolor="#FFFFFF">%g</td></tr>'...
        '<tr><td colspan="2" bgcolor="#999999"><div style="color:#FFFFFF;">when:</div></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">time start:   </td><td bgcolor="#FFFFFF">%s</td></tr>'...
        '<tr><td bgcolor="#FFFFFF">time end:     </td><td bgcolor="#FFFFFF">%s</td></tr>',...
        '<tr><td bgcolor="#FFFFFF">time (#):     </td><td bgcolor="#FFFFFF">%g</td></tr>'...
        '<tr><td colspan="2" bgcolor="#999999"><div style="color:#FFFFFF;">access:</div></td></tr>'...
        '%s',...					  
        '<tr><td bgcolor="#FFFFFF">meta-data:    </td><td bgcolor="#FFFFFF"><a href="%s">OPeNDAP (THREDDS)</a></td></tr>'...
        '<tr><td bgcolor="#FFFFFF">data:         </td><td bgcolor="#FFFFFF"><a href="%s">ftp server    </a></td></tr>'...%link to timeseries
        '%s',...					  
        ],...
        strtrim(D.platform_name{ii}),...
        upper(strtrim(D.platform_id{ii})),...
        D.geospatialCoverage_eastwest_start(ii),...
        D.geospatialCoverage_northsouth_start(ii),...
        datestr(D.timeCoverage_start(ii),31),...
        datestr(D.timeCoverage_end  (ii),31),...
        D.number_of_observations(ii),...
        resolvestring,...
        OPT.THREDDSFcn([D.urlPath{ii},'.html']),...
            OPT.ftpFcn([D.urlPath{ii},'.html'])),...
            paramstring];
       
    end
    
    if ~isempty(OPT.text)
       tablehader = ['<tr><td colspan="2" bgcolor="#666666"><div style="color:#FFFFFF;">',char(OPT.text),'</div></td></tr>'];
    else
       tablehader = '';        
    end

    table = [tablehader...
        '<table bgcolor="#333333" cellpadding="3" cellspacing="1"><tbody>'...
        tableContents...
        '</table><hr>' preview];
        
   %% preproces timespan
   %  http://code.google.com/apis/kml/documentation/kmlreference.html#timespan
   
      if  ~isnan(D.timeCoverage_start(ii))
          OPT.timeSpan = sprintf([...
              '<TimeSpan>'...
              '<begin>%s</begin>'... % OPT.timeIn
              '<end>%s</end>'...     % OPT.timeOut
              '</TimeSpan>'],...
              datestr(D.timeCoverage_start(ii),'yyyy-mm-ddTHH:MM:SS'),...
              datestr(D.timeCoverage_end(ii),'yyyy-mm-ddTHH:MM:SS'));
      else
          OPT.timeSpan ='';
      end

    % generate description
    output = [output, sprintf([...
        '\n<Placemark>'...
        '<name>%s</name>'...                                         % 1 name
        '%s' ...                                                       % 2 timeSpan
        '<snippet></snippet>'...
        '<description><![CDATA[<hr>'...
        '%s'...                                                        % 3 table with links, doubel white spaces disappear
        ']]></description>'...
        '<styleUrl>#MarkerBalloonStyle</styleUrl>'...
        '<Point><coordinates>%3.8f,%3.8f,0</coordinates></Point>'... % 4 lon lat
        '</Placemark>'],...
         strtrim(D.platform_name{ii}),... % strtrim(D.platform_id{ii}),...
         OPT.timeSpan,...
         table,...
         [D.geospatialCoverage_eastwest_start(ii) D.geospatialCoverage_northsouth_start(ii)])];

   end % ii
   
   %multiWaitbar(mfilename,1)

%% FOOTER

%% open and fill KML

   fid     = fopen(OPT.fileName,'w');
   fprintf(fid,'%c',output); % handle any % in output, cannot handle \n any more
   fprintf(fid,'\n%s\n','</Folder>'); % handle any % in output, cannot handle \n any more
   output  = [];

%% LOGO
%  add url of logo kml @ OpenEarth wiki

   if ischar(OPT.logokmlName)
     if exist(OPT.imName)==2
       output = KMLlogo('kmlName'  ,OPT.logokmlName,...
                        'overlayXY',OPT.overlayXY,...
                        'screenXY' ,OPT.screenXY,...
                        'imName'   ,OPT.imName,...
                        'logoName' ,OPT.logoName);

       fprintf(fid,output    ,'%s');
     end
   else
     for i=1:length(OPT.logokmlName)
       if isurl(OPT.imName{i})
           cachename = [tempdir,filesep,filenameext(OPT.imName{i})];
           urlwrite(OPT.imName{i},cachename);
           OPT.imName{i} = cachename;
       end
       if exist(OPT.imName{i})==2
       output = KMLlogo('kmlName'  ,OPT.logokmlName{i},...
                        'overlayXY',OPT.overlayXY{i},...
                        'screenXY' ,OPT.screenXY{i},...
                        'imName'   ,OPT.imName{i},...
                        'logoName' ,OPT.logoName{i});

       fprintf(fid,output    ,'%s');
       end
     end
   end

   fprintf(fid,KML_footer,'%s');

%% close KML

   fclose(fid);

%% Zip and make all images also offline locally available by added them to kmz

   KML2kmz(OPT.fileName,oetlogo,OPT.logoName,OPT.iconnormalState,OPT.iconhighlightState,{pngname1{:},pngname2{:}}); % oet logo, OPT.iconnormalState,OPT.iconhighlightState, are cached because they're googles
   
   if ~isempty(OPT.varname) & OPT.preview
   deletefile(pngname1)
   deletefile(pngname2)
   end
   