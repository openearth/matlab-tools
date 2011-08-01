function delft3d_wnd_from_nc(varargin)
%delft3d_wnd_from_nc     script that transforms netCDf wind file to delft3d *.wnd file
%
%  delft3d_wnd_from_nc(<keyword,value>)
%
% writes *.wnd file from netCDF file valid for ref_datenum in *.mdf file
%
% Implemented <keyword,value> pairs:
% * refdatenum: datenum or filename of *.mdf file
% * period:     2 datenums
% * dir   :     directory where to save *.wnd
% * nc    :     name or opendap url of netCDF file with wind data
%
%See also: KNMI_POTWIND, DELFT3D_IO_WND, delft3d_wnd_from_knmi_potwind

%% get data

   OPT.nc         = 'http://opendap.deltares.nl/thredds/dodsC/opendap/knmi/potwind/potwind_242.nc';
   OPT.period     = datenum(2009, 1, 1 + [0 365]);
   OPT.dir        = pwd;
   OPT.refdatenum = []; %datenum(1998,1,1); % offset from delftd *.mdf
   
   OPT = setproperty(OPT,varargin{:});

   if ischar(OPT.refdatenum)
      mdf            = delft3d_io_mdf('read',OPT.refdatenum);
      OPT.refdatenum = datenum(mdf.keywords.itdate,'yyyy-mm-dd');
   elseif isempty(OPT.refdatenum)
      error('refdatenum missing')
   end

   [dummy,start,count] = nc_varget_range(OPT.nc,'time',OPT.period);
   W.datenum           = nc_cf_time     (OPT.nc,'time'                       ,[  start],[  count]);
   W.UP                = nc_varget      (OPT.nc,'wind_speed'                 ,[0 start],[1 count]);
   W.DD                = nc_varget      (OPT.nc,'wind_from_direction'        ,[0 start],[1 count]);

%% Mind that there are NaN's in the direction
  
  mask = (isnan(W.DD));
  
  plot(W.UP(mask))
  ylabel('m/s')
  title('Wind speed when direction is NaN')
  print2screensize([OPT.dir,filesep,filename(OPT.nc),'_after_refdate_',datestr(OPT.refdatenum,30),'_NaN_in_direction.png'])
  
%% Remove nans (of either directory or speed)
%  For Delft3D there is no need to be equidistant in time.

   mask      = find(~isnan(W.UP) & ~isnan(W.DD));
 % W.UX      = interp1(W.datenum(mask),W.UX(mask),W.datenum);
 % W.UY      = interp1(W.datenum(mask),W.UY(mask),W.datenum);
 %[W.DD,W.UP] = CART2POL(W.UX,W.UY);
 % W.DD = deguc2degn(rad2deg(W.DD));
   
   W.datenum  = W.datenum(mask);
   W.UP       = W.UP     (mask);
   W.DD       = W.DD     (mask);
   
   delft3d_io_wnd('write',[OPT.dir,filesep,filename(OPT.nc),'_after_refdate_',datestr(OPT.refdatenum,30),'_nonan.wnd'],W,'refdatenum',OPT.refdatenum)