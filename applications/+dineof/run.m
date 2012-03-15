function varargout = run(data, time, mask, varargin)
%run wrapper to use DINEOF via memory (without explicit file IO)
%
%    dataf = dineof.run(data, time, mask, <keyword,value>)
%
% where dataf is the filled + smoothed data.
%
%    [dataf,D] = dineof.run(data, time, mask, <keyword,value>)
%
% where optionally struct D with the mean, the spatial & temporal
% EOF modes, the singular values and the exlained variance 
% can be returned. All files are deleted afterwards and saved into
% 1 netCDF file, unless keyword 'cleanup' is set to 0.
%
% Example:
%
%   nt      = 14;time    = [1:nt];
%   ny      = 20;
%   nx      = 21;
%  [y,x]    = meshgrid(linspace(-3,3,ny),linspace(-3,3,nx));
%   z       = peaks(x,y);
%   mask    = rand(size(z)) < 1;
%   mask(1:5,1:5) = 0; % land
%
%   for it=1:nt
%     noise  = rand(size(z)).*z./100;
%     clouds = double(rand(size(z)) < 0.95);
%     clouds(clouds==0)=nan;
%     data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
%                   abs(z).*cos(pi.*it./nt) + ...
%                           noise;
%   end
%   
%   OPT.ncfile   = ['dineof_demo.nc'];
%   OPT.resfile  = ['dineof_demo_filled.nc'];% here eof filled data will be written
%   OPT.eoffile  = ['dineof_demo_eof.nc'];   % here eof modes will be written
%   OPT.nev      = 5; % max # of modes
%   OPT.plot     = 1;
%   
%   [dataf,eofs] = dineof.run(data, time, mask, OPT);
%
%See also: dineof, harmanal

% DINEOF suggestions
% - use ? instead of #, then the syntax is OPeNDAP
% - also use [] for time string
% - make keyword output fully small case

% dineof keywords: order here is important as
% it determines order in init file

   OPT         = dineof.init();
   fldnames    = fieldnames(OPT);
   
   OPT.cleanup = 1;
   OPT.debug   = 0;
   OPT.plot    = 1;

% other keywords

   OPT.dataname      = 'data';
   OPT.maskname      = 'mask';
   OPT.timename      = 'time';
   OPT.ncfile        = ['dummy.nc'];
   OPT.resfile       = ['dummy_filled.nc'];
   OPT.eoffile       = ['dummy_eof.nc'];
   OPT.units         = '';
   OPT.standard_name = '';
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
    
   OPT.data     = ['[''./',OPT.ncfile ,'#',OPT.dataname,''']'];
   OPT.mask     = ['[''./',OPT.ncfile ,'#',OPT.maskname,''']'];
   OPT.time     = [ '''./',OPT.ncfile ,'#',OPT.timename,'''']; % no brackets !!
   OPT.results  = ['[''./',OPT.resfile,'#',OPT.dataname,''']'];
   
   initfile     = [filepathstrname(OPT.resfile),'.init'];
   logfile      = [filepathstrname(OPT.resfile),'.log'];
   
   dineof.initwrite(OPT,initfile);

%% write input data

   mode     = netcdf.getConstant('CLOBBER'); % do not overwrite existing files
   NCid     = netcdf.create(OPT.ncfile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   
   dimid.time     = netcdf.defDim(NCid,'time' ,size(data,3));
   for i=1:length(size(data))-1
   dimname = ['space',num2str(i)];
   dimid.space(i) = netcdf.defDim(NCid,dimname,size(data,i));
   end
   
   varid.data = netcdf.defVar(NCid,OPT.dataname,'double',[dimid.space dimid.time]); 
   varid.time = netcdf.defVar(NCid,OPT.timename,'float' ,dimid.time); 
   varid.mask = netcdf.defVar(NCid,OPT.maskname,'short' ,dimid.space); 

   netcdf.putAtt(NCid,varid.time,'standard_name','time');
   netcdf.putAtt(NCid,varid.time,'standard_name','days since 1970-01-01');
   
   netcdf.putAtt(NCid,varid.data,'long_name'    ,'data');
   netcdf.putAtt(NCid,varid.data,'missing_value',9999); % clouds
   netcdf.putAtt(NCid,varid.data,'_FillValue'   ,9999); % clouds
   if ~isempty(OPT.units)
   netcdf.putAtt(NCid,varid.data,'units'        ,OPT.units);
   end
   if ~isempty(OPT.standard_name)
   netcdf.putAtt(NCid,varid.data,'standard_name',OPT.standard_name);
   end
   
   netcdf.putAtt(NCid,varid.mask,'long_name'    ,'mask');
   netcdf.putAtt(NCid,varid.mask,'flag_values'  ,[0 1]);
   netcdf.putAtt(NCid,varid.mask,'flag_meanings','land ocean');

   netcdf.endDef(NCid,20e3,4,0,4); 

   netcdf.putVar(NCid,varid.data,data);
   netcdf.putVar(NCid,varid.time,time - datenum(1970,1,1));
   netcdf.putVar(NCid,varid.mask,int8(mask));

   netcdf.close (NCid)
   
   if OPT.debug
      nc_dump(OPT.ncfile)
   end

%% call dineof

   copyfile(OPT.ncfile,OPT.resfile)
   ddir = filepathstr(mfilename('fullpath')); 
   if ~exist([ddir, filesep,'dineof.exe'])
   fprintf(2,'%s\n',['Tu use dineof first download dineof.exe from '])
   fprintf(2,'%s\n',['http://modb.oce.ulg.ac.be/mediawiki/index.php/DINEOF'])
   fprintf(2,'%s\n',['into'])
   fprintf(2,'%s\n',ddir)
   error('DINEOF')
   end
   disp('Running DINEOF, please wait ...')
   cmd  = [ddir filesep 'dineof.exe ' initfile ' > ' logfile ];

   system(cmd);
   
   if OPT.debug
      nc_dump(OPT.resfile)
   end

if nargout==0

  %% rename outpout

   movefile('meandata.val'    ,[filepathstrname(OPT.resfile),'_meandata.asc'  ]);
   movefile('neofretained.val',[filepathstrname(OPT.resfile),'_neofretained.asc']);
   movefile('outputEof.lftvec',[filepathstrname(OPT.resfile),'_lftvec.asc'    ]);
   movefile('outputEof.rghvec',[filepathstrname(OPT.resfile),'_rghvec.asc'    ]);
   movefile('outputEof.varEx' ,[filepathstrname(OPT.resfile),'_varEx.asc'     ]);
   movefile('outputEof.vlsng' ,[filepathstrname(OPT.resfile),'_vlsng.asc'     ]);
   movefile('valc.dat'        ,[filepathstrname(OPT.resfile),'_valc.bin'      ]);
   movefile('valosclast.dat'  ,[filepathstrname(OPT.resfile),'_valosclast.bin']);

else

  %% collect results

   NCid     = netcdf.open(OPT.resfile,'NOWRITE');
   
   varid    = netcdf.inqVarID(NCid,OPT.dataname);
   dataf    = netcdf.getVar(NCid,varid);
   
   nodata   = netcdf.getAtt(NCid,varid,'_FillValue');
   dataf(dataf==nodata)=NaN;

   nodata   = netcdf.getAtt(NCid,varid,'missing_value');
   dataf(dataf==nodata)=NaN;

   netcdf.close (NCid)

   S.mean   =                      load(    'meandata.val'   );
   S.P      =                      load('neofretained.val'   );
   S.lftvec =        dineof_unpack(load(   'outputEof.lftvec'),mask);
   S.rghvec =                      load(   'outputEof.rghvec');
  [S.varEx, S.varLab] = dineof_io_varEx(   'outputEof.varEx' );
   S.vlsng  =                      load(   'outputEof.vlsng' );

  %% save results to netcdf

   mode     = netcdf.getConstant('CLOBBER'); % do not overwrite existing files
   NCid     = netcdf.create(OPT.eoffile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   
   dimid.time     = netcdf.defDim(NCid,'time' ,size(data,3));
   dimid.P        = netcdf.defDim(NCid,'P'    ,S.P);
   for i=1:length(size(data))-1
   dimname = ['space',num2str(i)];
   dimid.space(i) = netcdf.defDim(NCid,dimname,size(data,i));
   end
   
   varid.time   = netcdf.defVar(NCid,OPT.timename,'float' ,dimid.time); 
   varid.mask   = netcdf.defVar(NCid,OPT.maskname,'short' ,dimid.space); 

   varid.P      = netcdf.defVar(NCid,'P'     ,'float' ,[]); 
   varid.mean   = netcdf.defVar(NCid,'mean'  ,'float' ,[]); 
   varid.lftvec = netcdf.defVar(NCid,'lftvec','float' ,[dimid.P dimid.space]); 
   varid.rghvec = netcdf.defVar(NCid,'rghvec','float' ,[dimid.P dimid.time]); 
   varid.vlsng  = netcdf.defVar(NCid,'vlsng' ,'float' , dimid.P); 
   varid.varEx  = netcdf.defVar(NCid,'varEx' ,'float' , dimid.P); 
   
   netcdf.putAtt(NCid,varid.P     ,'long_name'    ,'optimal number of EOF modes');
   netcdf.putAtt(NCid,varid.mean  ,'long_name'    ,'spatiotemporal mean');
   netcdf.putAtt(NCid,varid.lftvec,'long_name'    ,'spatial EOF modes');
   netcdf.putAtt(NCid,varid.rghvec,'long_name'    ,'temporal EOF modes');
   netcdf.putAtt(NCid,varid.vlsng ,'long_name'    ,'singular values');
   netcdf.putAtt(NCid,varid.varEx ,'long_name'    ,'explained variance');

   netcdf.putAtt(NCid,varid.time  ,'standard_name','time');
   netcdf.putAtt(NCid,varid.time  ,'standard_name','days since 1970-01-01');

   netcdf.putAtt(NCid,varid.mask  ,'long_name'    ,'mask');
   netcdf.putAtt(NCid,varid.mask  ,'flag_values'  ,[0 1]);
   netcdf.putAtt(NCid,varid.mask  ,'flag_meanings','land ocean');

   netcdf.putAtt(NCid,varid.mean  ,'units'        , 0.01); % percent
   if ~isempty(OPT.units)
   netcdf.putAtt(NCid,varid.mean  ,'units'        ,OPT.units);
   end
   if ~isempty(OPT.standard_name)
   netcdf.putAtt(NCid,varid.mean  ,'standard_name',OPT.standard_name);
   end
   
   netcdf.putAtt(NCid,varid.varEx ,'units'        , 0.01); % percent

   netcdf.endDef(NCid,20e3,4,0,4); 

   netcdf.putVar(NCid,varid.time,time - datenum(1970,1,1));
   netcdf.putVar(NCid,varid.mask,int8(mask));

   netcdf.putVar(NCid,varid.P     ,S.P);
   netcdf.putVar(NCid,varid.mean  ,S.mean);
   netcdf.putVar(NCid,varid.lftvec,S.lftvec);
   netcdf.putVar(NCid,varid.rghvec,S.rghvec);
   netcdf.putVar(NCid,varid.vlsng ,S.vlsng);
   netcdf.putVar(NCid,varid.varEx ,S.varEx);

   netcdf.close (NCid)
   
   if OPT.debug
      nc_dump(OPT.ncfile)
   end

  %% delete output

  if OPT.cleanup
     delete('meandata.val'    );
     delete('neofretained.val');
     delete('outputEof.lftvec');
     delete('outputEof.rghvec');
     delete('outputEof.varEx' );
     delete('outputEof.vlsng' );
     delete('valc.dat'        );
     delete('valosclast.dat'  );
      
     delete(initfile);
     delete(logfile );

     delete(OPT.resfile);
     delete(OPT.ncfile );
  end
  
end   

if OPT.plot
   TMP = figure;
   nt  = length(S.rghvec);
   r   = [min(data(:)) max(data(:))];

   %% spatial modes
   subplot(1,4,3)
   for im=1:S.P
   surf(0.*S.lftvec(:,:,im)+im,S.lftvec(:,:,im))
   hold on
   end
   zlim([1 max(2,S.P)])
   grid on
   colorbarwithhtext('leftvec','horiz')
   shading interp
   zlabel('modes')  
   set(gca,'zdir','reverse')
    
   %% 1st temporal modes
   subplot(1,4,4)
   for im=1:S.P
   plot(S.rghvec(:,im),time,'.-','Color',repmat(interp1([S.P 0],[0.9 0],im),[1 3]),'DisplayName',S.varLab{im});
   hold on
   end
   zlim([0 nt])
   grid on
   xlabel('rghvec')
   ylabel('time')
   legend show
   
   %% data
   subplot(1,4,1)
   caxis([min(data(:)) max(data(:))])
   d = surf(data(:,:,1).*0,data(:,:,1));
   hold on
   zlim([0 nt])
   grid on
   zlabel('time')
   shading interp
   clim(r)
   colorbarwithhtext('raw data','horiz')
   view(-20,10)

   %% data filled
   subplot(1,4,2)
   caxis([min(data(:)) max(data(:))])
   df = surf(dataf(:,:,1).*0,dataf(:,:,1));
   hold on
   zlim([0 nt])
   grid on
   zlabel('time')
   shading interp
   clim(r)
   colorbarwithhtext('filled data','horiz')
   view(-20,10)

   for it=1:nt
   
      if nt > 20
      
         set(d,'zdata',data(:,:,1 ).*0+it)
         set(d,'cdata',data(:,:,it))

         set(df,'zdata',dataf(:,:,1 ).*0+it)
         set(df,'cdata',dataf(:,:,it))
         pause(0.01)
         
      else
      
         subplot(1,4,1)
         surf(dataf(:,:,1).*0+it,data(:,:,it));
         shading interp
      
         subplot(1,4,2)
         surf(dataf(:,:,1).*0+it,dataf(:,:,it));
         shading interp

      end

   end
   
   %try, close(TMP),end

end

if nargout==1
   varargout = {dataf};
else
   varargout = {dataf,S};
end