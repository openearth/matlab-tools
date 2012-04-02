function varargout = run(data, time, mask, varargin)
%RUN wrapper to use DINEOF via memory (without explicit file IO)
%
%    dataf = dineof.run(data, time, mask, <keyword,value>)
%
% where dataf is the filled + smoothed data. The dimensions 
% should be time(t), data(x,<y>,t), mask(x,<y>). Any missing 
% y dimension is permuted before calling dineof.exe.
%
%    [dataf,D] = dineof.run(data, time, mask, <keyword,value>)
%
% where optionally struct D with the mean, the spatial & temporal
% EOF modes, the singular values and the exlained variance 
% can be returned. All temporary DINEOF files are deleted afterwards 
% and saved into 1 netCDF file, unless keyword 'cleanup' is set to 0.
% Note that the upcoming DINEOF release will save the EOFs to netCDF itself.
%
% Example 2D matrices:
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
%   [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',1);
%
%See also: dineof, harmanal

% DINEOF suggestions
% - use ? instead of #, then the syntax is OPeNDAP
% - also use [] for time string
% - make keyword 'output' fully small case

% dineof keywords: order here is important as
% it determines order in init file

   OPT         = dineof.init();
   fldnames    = fieldnames(OPT);
   
   OPT.cleanup = 1;
   OPT.debug   = 0;
   OPT.plot    = 1;
   OPT.export  = 1;

% other keywords

   OPT.dataname        = 'data';
   OPT.maskname        = 'mask';
   OPT.timename        = 'time';
   OPT.ncfile          = ['dummy.nc'];
   OPT.resfile         = ['dummy_filled.nc'];
   OPT.eoffile         = ['dummy_eof.nc'];
   OPT.initfile        = []; % will have same name as eoffile
   OPT.logfile         = []; % will have same name as eoffile
   OPT.units           = '';
   OPT.standard_name   = '';
   OPT.transformFun    = @(x) x;
   OPT.transformFunInv = @(x) x;
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin);
    
   if ~(OPT.transformFun(OPT.transformFunInv(1))==1)
      error('transformFunInv(x) is not the inverse of transformFun(x) for x=1')
   end

   OPT.data     = ['[''./',OPT.ncfile ,'#',OPT.dataname,''']'];
   OPT.mask     = ['[''./',OPT.ncfile ,'#',OPT.maskname,''']'];
   OPT.time     = [ '''./',OPT.ncfile ,'#',OPT.timename,'''']; % no brackets !!
   OPT.results  = ['[''./',OPT.resfile,'#',OPT.dataname,''']'];
   
   if sum(mask) < OPT.ncv
       error(['Krylov subspace ncv (',num2str(OPT.ncv),') needs to be les than or equal to # active spatial cells (',num2str(sum(mask)),').'])
   end
   
   if isempty(OPT.initfile)
   OPT.initfile = [filepathstrname(OPT.eoffile),'.init'];
   end
   if isempty(OPT.logfile)
   OPT.logfile  = [filepathstrname(OPT.eoffile),'.log'];
   end
   
   dineof.initwrite(OPT,OPT.initfile);

%% make data matrix [M x N] that DINEOF swallows, where M or 
%  N can be 1, but DINEOF will swap dimensions internally in one case

   sz0 = size(data);
   sz  = size(data);
   permuteback = [1 2 3];
   
   if length(sz0)==2
   
     data = permute(data,[1 3 2]);
     mask = mask(:);
     sz   = size(data);
     dim  = 1;
     permuteback = [1 3 2];
     
   elseif length(sz0)==3 & sz0(1)==1

     data = permute(data,[2 1 3]);
     mask = mask(:);
     sz   = size(data);
     dim  = 1;
     permuteback = [2 1 3];

   elseif length(sz0)==3 & sz0(2)==1

     % data already OK
     mask = mask(:);
     sz   = size(data);
     dim  = 1;

   elseif length(sz0)>3
   
      error('only 1D vector and 2D matrix data implemented, no 3D cubes or higher yet.')
      
   else
     dim = 2;
  end
  
  data = OPT.transformFun(data);
   
%% check DINEOF requirements: time(t), data(x,y,t), mask(x,y)

   if ~(sz(3)==length(time))
      whos
      error('data(x,y,:) should have length as time')
   end

   if ~(isequal(sz(1:2),size(mask)))
      whos
      error('data(:,:,y) should have size as mask')
   end

%% write input data

   mode     = netcdf.getConstant('CLOBBER'); % do overwrite existing files
   NCid     = netcdf.create(OPT.ncfile,mode);
   globalID = netcdf.getConstant('NC_GLOBAL');
   
   dimid.time     = netcdf.defDim(NCid,'time' ,sz(end));
   for i=1:length(sz)-1
   dimname = ['space',num2str(i)];
   dimid.space(i) = netcdf.defDim(NCid,dimname,sz(i));
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
   netcdf.putAtt(NCid,varid.data,'transform_fun','CHECK');

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
   
   %% clean up any previous runs
   if exist('meandata.val'    );delete('meandata.val'    );end
   if exist('neofretained.val');delete('neofretained.val');end
   if exist('outputEof.lftvec');delete('outputEof.lftvec');end
   if exist('outputEof.rghvec');delete('outputEof.rghvec');end
   if exist('outputEof.varEx' );delete('outputEof.varEx' );end
   if exist('outputEof.vlsng' );delete('outputEof.vlsng' );end
   if exist('valc.dat'        );delete('valc.dat'        );end
   if exist('valosclast.dat'  );delete('valosclast.dat'  );end
   
   %% run
   disp('Running DINEOF, please wait ...')
   cmd  = [ddir filesep 'dineof.exe ' OPT.initfile ' > ' OPT.logfile];

   status = system(cmd);
   
   if OPT.debug
      nc_dump(OPT.resfile)
   end

if status < 0

   % make dummy matrices with expected size to allow automated plotting of results
   
   S.mean   = nan;
   S.P      = 0;
   S.lftvec = repmat(nan,[size(data,1) 1]);
   S.rghvec = repmat(nan,[size(data,3) 1]);
   S.varEx  = 0;
   S.varLab = {};
   S.vlsng  = 0;
   dataf    = permute(nan.*data,permuteback);;
   
   fprintf(2,'DINEOF failed, dummy matrices returned \n')

   if nargout==1
      varargout = {dataf};
   else
      varargout = {dataf,S};
   end       
   return

else

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

    varid.dataf = netcdf.inqVarID(NCid,OPT.dataname);
    dataf       = netcdf.getVar(NCid,varid.dataf);

    nodata   = netcdf.getAtt(NCid,varid.dataf,'_FillValue');
    dataf(dataf==nodata)=NaN;

    nodata   = netcdf.getAtt(NCid,varid.dataf,'missing_value');
    dataf(dataf==nodata)=NaN;

    netcdf.close (NCid);
    
    data  = OPT.transformFunInv(data );
    dataf = OPT.transformFunInv(dataf);


    S.mean   =                      load(    'meandata.val'   );
    S.P      =                      load('neofretained.val'   );
    S.lftvec =        dineof.unpack(load(   'outputEof.lftvec'),mask);
    S.rghvec =                      load(   'outputEof.rghvec');
   [S.varEx, S.varLab] =           varEx(   'outputEof.varEx' );
    S.vlsng  =                      load(   'outputEof.vlsng' );
       

  %% save results to netcdf

   mode     = netcdf.getConstant('CLOBBER'); % do overwrite existing files
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
      
     delete(OPT.initfile);
     delete(OPT.logfile );

     delete(OPT.ncfile );
     delete(OPT.resfile);
     delete(OPT.eoffile );
  end
 end   

 %% plot

   if OPT.plot
      TMP = figure;
      dineof.inspect(data, time, mask, dataf, S);
      if OPT.export
         print2screensize(strrep(OPT.eoffile,'.nc','.png'))
      end
      pausedisp
      try, close(TMP),end
   end
   
end % status

%% out

   dataf = permute(dataf,permuteback);

   if nargout==1
      varargout = {dataf};
   else
      varargout = {dataf,S};
   end

function [varex,labels] = varEx(fname)
%varEx read explained variance
%
% varex = dineof.varEx(fname)
%
%See also: dineof

[labels]=textread(fname,'%s','whitespace','\n');
try
  [number,varex,~]=textread(fname,'Mode %d=%f %s');
  for i=1:length(varex)
    labels{i} = ['Mode ',num2str(i,'%d'),' = ',num2str(varex(i),'%0.1f'),' %'];
  end
catch
  varex(1:length(labels)) = nan; % in case of ***
end
