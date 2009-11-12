function D = seawifs_l2_read(fname,varname,varargin);
%SEAWIFS_L2_READ   load one image from a SeaWiFS L2 HDF file
%
%   D = seawifs_l2_read(filename,varname)
%
% load one image from a SeaWiFS L2 HDf file incl. full lat and lon arrays.
%
% Example:
% 
%   D = seawifs_L2_read('S1998128121603.L2_HDUN_ZUNO.hdf','nLw_555')
%
%See also: HDFINFO

  %fname   = 'S1998128121603.L2_HDUN_ZUNO.hdf'
  %varname = 'nLw_555'

   %% Keywords

   OPT.debug = 0;
   OPT.plot  = 0;
   OPT = setproperty(OPT,varargin{:});

   %% Load
   
   
   D.fname = fname;
   I       = hdfinfo(D.fname);
   
   for iatt=1:length(I.Attributes)
   if strcmpi(I.Attributes(iatt).Name,'start time');break;end
   end   
   D.datenum(1) = seawifsdatenum(I.Attributes(iatt).Value);
   for iatt=1:length(I.Attributes)
   if strcmpi(I.Attributes(iatt).Name,'end time');break;end
   end   
   D.datenum(2) = seawifsdatenum(I.Attributes(iatt).Value);

   D.(varname)    = hdfread(D.fname,varname);
   T.longitude    = hdfread(D.fname,'longitude');
   T.latitude     = hdfread(D.fname,'latitude' );
   T.cntl_pt_rows = hdfread(D.fname,'cntl_pt_rows');
   T.cntl_pt_cols = hdfread(D.fname,'cntl_pt_cols');

   %% georeference full matrices
   %  http://oceancolor.gsfc.nasa.gov/forum/oceancolor/topic_show.pl?pid=2029
   %  for each swatch the (lat,lon) arrays are only stored every 8th pixel.
   %  to get the full matrix interpolte to the full pixel range, with a spline.
   
   if size(D.(varname),1)==length(T.cntl_pt_rows)
      D.longitude = repmat(nan,size(D.(varname)));
      D.latitude  = repmat(nan,size(D.(varname)));
      nrow        =            size(D.(varname),1);
      ncol        =            size(D.(varname),2);
      for irow = 1:nrow
         D.longitude(irow,:) = interp1(single(T.cntl_pt_cols),double(T.longitude(irow,:)),1:ncol,'spline' );
         D.latitude (irow,:) = interp1(single(T.cntl_pt_cols),double(T.latitude (irow,:)),1:ncol,'spline' );
      end
   
   end   

   %% debug: for last row   
   
   if OPT.debug
      clf
      subplot(1,2,1)
      plot(single(T.cntl_pt_cols),T.longitude(irow,:),'.-b','Displayname','per 8')
      hold on
      plot(                1:ncol,D.longitude(irow,:),'.-r','Displayname','interp1')
      xlabel('pixel #')
      xlabel('longitude')
   
      subplot(1,2,2)
      plot(single(T.cntl_pt_cols),T.latitude (irow,:),'.-b','Displayname','per 8')
      hold on
      plot(                1:ncol,D.latitude (irow,:),'.-r','Displayname','interp1')
      xlabel('pixel #')
      xlabel('latitude')
      
   end
   if OPT .plot
      figure
      pcolorcorcen(D.longitude,D.latitude,double(D.nLw_555))
      L.url = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc';
      L.lon = nc_varget(L.url,'lon');
      L.lat = nc_varget(L.url,'lat');
      hold on
      plot(L.lon,L.lat,'w')
      
   end