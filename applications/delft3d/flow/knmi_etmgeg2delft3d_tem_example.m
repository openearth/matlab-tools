%KNMI_ETMGEG2DELFT3D_TEM_EXAMPLE    script that transforms KNMI etmgeg files to delft3d *.tem file
%
%  KNMI_ETMGEG2DELFT3D_TEM_EXAMPLE(fname,ref_datenum)
%
% writes *.tem file from knmi_etmgeg file valid for ref_datenum in *.mdf file.
%
% >        Station 235 Den Helder (De Kooy)
% >        Station 240 Amsterdam (Schiphol)
% >        Station 260 De Bilt
%          Station 270 Leeuwarden
%          Station 280 Groningen (Eelde)
%          Station 290 Twenthe
%          Station 310 Vlissingen
%          Station 344 Rotterdam
%          Station 370 Eindhoven
%          Station 380 Maastricht (Beek)
%
%See also: KNMI_ETMGEG, DELFT3D_IO_TEM, KNMI_POTWIND, 
%          KNMI_POTWIND2DELFT3D_WND_EXAMPLE

   OPT.filename     = 'F:\checkouts\OpenEarthRawData\KNMI_etmgeg\raw\etmgeg_240_2001';
   OPT.refdatenum   = datenum(2007,1,1);%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   C                = knmi_etmgeg(OPT.filename)

%% Negative with respect to reference date not posible
%% ----------------
   mask             = C.data.datenum > OPT.refdatenum;
   
   D.datenum        = C.data.datenum(mask);
   D.RH             = C.data.UG     (mask);
   D.airtemperature = C.data.TG     (mask);
   D.cloudcover     = C.data.NG     (mask)./8*100; % octants to %
   
   D.datenum_units        = 'days';
   D.RH_units             = '%';
   D.airtemperature_units = '°C';
   D.cloudcover_units     = '%';  
   
%% Negative with respect to reference date not posible
%% ----------------

   AX = subplot_meshgrid(1,3,[.05],[.05])
   
   axes(AX(1))
   plot(C.data.datenum(mask),C.data.UG(mask),'DisplayName',[C.data.UG_long_name,' [',C.data.UG_units,']'])
   legend show
   datetick('x')
   grid on
   title(['file: ''',mktex(filename(OPT.filename)),''', station: ',KNMI_etmgeg_stations(C.data.STN(1))])
   
   axes(AX(2))
   plot(C.data.datenum(mask),C.data.TG(mask),'DisplayName',[C.data.TG_long_name,' [',C.data.TG_units,']'])
   legend show
   datetick('x')
   grid on
   
   axes(AX(3))
   plot(C.data.datenum(mask),C.data.NG(mask),'DisplayName',[C.data.NG_long_name,' [',C.data.NG_units,']']);
   legend show
   datetick('x')
   grid on   
   text(1,0,['\copyright Deltares, 2008, OCt, Q4613, GJdB'],...
                       'rotation',90,...
              'verticalalignment','top',...
                       'fontsize',5,...
                          'units','normalized')
   
   print2screensize([filename(OPT.filename),'_timeseries.png'])

%% Mind that there are NaN's in the direction
%% ----------------

   clf
  
   mask = (isnan(D.RH            ) | ...
           isnan(D.airtemperature) | ...
           isnan(D.cloudcover    ) );
           
   plot  (D.datenum,mask,'.-')
   title ('UG or TG or NG is NaN')
   datetick('x')
   grid on   

   print2screensize([filename(OPT.filename),'_after_refdate_',datestr(OPT.refdatenum,30),'_NaNs.png'])
  
%% Remove NaNs
%% ---------------------------

   D.datenum        = D.datenum       (~mask);
   D.RH             = D.RH            (~mask);
   D.airtemperature = D.airtemperature(~mask);
   D.cloudcover     = D.cloudcover    (~mask);
  
%% Save
%% ---------------------------

  iostat = delft3d_io_tem('write',...
                                 [filename(OPT.filename),'_after_refdate_',datestr(OPT.refdatenum,30),'_nonan.tem'],...
                                 D,...
                                 'P:\q4408-mkm\flow\cb009d\tst.mdf');
