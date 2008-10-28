function DISout = dispack(DISin,varargin)
%DISPACK          rewrites BCT_IO result to have column instead of a struct field per data type <<beta version!>>
%
% DISout = dispack(DISin,<keyword,value>)
% DISout = dispack(DISin,OPT)
%
% where the following <keyword,value> pairs have been implemented:
% * ReferenceTimeMask: remove all data before refenrece tiem, 
%                      because delft3d-flow cannot handle those.
%
% work now for parameters (left) to become fieldname (right)
%
% *.dis
%
% 'total discharge (t)  end A'  < QA
% 'total discharge (t)  end B'  < QB
%
% *.bct
%
% 'flux/discharge rate'         < Q
% 'Salinity'                    < salinity
% 'Temperature'                 < temperature
%
%See also: BCT_IO, DELFT3D_IO_BCT, DELFT3D_IO_DIS

% for block remove last data point, so array sizes determine block or linear

   %% Set defaults for keywords
   %% ----------------------

   OPT.ReferenceTimeMask = 1;

   %% Return defaults
   %% ----------------------

   if nargin==0
      varargout = {OPT};
      return
   end

   iargin = 1;
   while iargin<=nargin-1,
     if isstruct(varargin{iargin})
        OPT = mergestructs('overwrite',OPT,varargin{iargin});
     elseif ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'referencetimemask' ;iargin=iargin+1;OPT.referencetimemask  = varargin{iargin};
       otherwise
          error(['Invalid string argument: %s.',varargin{i}]);
       end
     end;
     iargin=iargin+1;
   end; 
 
   %% Start
   %% ----------------------
 
   ReferenceTimeFirst = DISin.data(1).ReferenceTime;
   
   for itable = 1:length(DISin.data)
   
      %disp(['processing table: ',num2str(itable)])
   
      %% Check for consistent ReferenceTime times
      %% ---------------------------------------
      
      if isnumeric(ReferenceTimeFirst)
         if ~(ReferenceTimeFirst==DISin.data(itable).ReferenceTime)
            error('disunpack: ReferenceTime of different tables are different')
         end
      else
         if ~strcmpi(ReferenceTimeFirst,DISin.data(itable).ReferenceTime)
             error('disunpack: ReferenceTime of different tables are different')
         end
      end
   
      %% Extract data from multi-dimensional table into struct field
      %% ---------------------------------------
      
      H.parameternames = {'QA',...                         %       *.bct
                          'QB',...                         %       *.bct
                          'Q',...                          % *.dis
                          'salinity',...                   % *.dis
                          'temperature'};                  % *.dis
   
      H.parameterunits = {'[m3/s]',...                     %       *.bct
                          '[m3/s]',...                     %       *.bct
                          '[m3/s]',...                     % *.dis
                          '[ppt]',...                      % *.dis
                          '[°C]'};                         % *.dis
   
      H.tablenames     = {'total discharge (t)  end A',... %       *.bct
                          'total discharge (t)  end B',... %       *.bct
                          'flux/discharge rate',...        % *.dis
                          'Salinity',...                   % *.dis
                          'Temperature',...                % *.dis
                          };
                          
      %% Check number of substances
      %% ---------------------------------------
      
      fldnames = fieldnames(DISin.data(itable));
      
      ncolumns = 1; % start with one for time
   
      for ipar=1:length(H.parameternames)
         if any(strcmp(H.parameternames{ipar},fldnames));
         ncolumns = ncolumns + 1;
         end
      end
      
      %% Mask
      %% ---------------------------------------

      mask = 1:length(DISin.data(itable).datenum);
      if any(DISin.data(itable).datenum < time2datenum(DISin.data(itable).ReferenceTime))
         if OPT.ReferenceTimeMask
            warning(['Removed all data before reference time ',DISin.data(itable).ReferenceTime])
            mask = DISin.data(itable).datenum > time2datenum(DISin.data(itable).ReferenceTime);
         else
            warning(['Some data are before reference time ',DISin.data(itable).ReferenceTime,', which Delft3D does not swallow.'])
         end
      end      
      
      ntimes = length(DISin.data(itable).datenum(mask));
      
      %% Insert time columns
      %% ---------------------------------------
   
      DISout.Table(itable).Data      = repmat(nan,[ntimes ncolumns]);
   
      DISout.Table(itable).Data(:,1) = (DISin.data(itable).datenum(mask) - ...
                                        time2datenum(DISin.data(itable).ReferenceTime)).*24.*60;
                                        

                                        
      DISout.Table(itable).Parameter(1).Name = 'time';
      DISout.Table(itable).Parameter(1).Unit = '[min]';
                                        
   
      %% Loop over Table names
      %% ---------------------------------------
   
      column = 1; % start with one for time
         
      for ipar=1:length(H.parameternames)
      
         H.parametername      = char(H.parameternames{ipar});
         H.parameterunit      = char(H.parameterunits{ipar});
         H.tablename          = char(H.tablenames{ipar});
         
         for ifield = 1:length(fldnames);
         
            fldname = fldnames{ifield};
            
            if strcmpi(fldname,H.parametername);
            
            column = column + 1;
         
           %disp([num2str(itable),'  ',num2str(ifield),'  ',num2str(column),'  ',fldname,'  ',H.tablename,'  ',H.parameterunit])
            
            DISout.Table(itable).Parameter(column).Name = H.tablename;
            DISout.Table(itable).Parameter(column).Unit = H.parameterunit;
            DISout.Table(itable).Data   (:,column)      = DISin.data(itable).(H.parametername)(mask);
             
            end
          
          end % ifield
          
      end
       
      %% Copy meta-information
      %% ---------------------------------------
   
      DISout.Table(itable).Name          =         DISin.data(itable).Name          ;
      DISout.Table(itable).Contents      =         DISin.data(itable).Contents      ;
      DISout.Table(itable).Location      =         DISin.data(itable).Location      ;
      DISout.Table(itable).TimeFunction  =         DISin.data(itable).TimeFunction  ;
      DISout.Table(itable).ReferenceTime = str2num(DISin.data(itable).ReferenceTime );
      DISout.Table(itable).TimeUnit      = 'minutes';
      DISout.Table(itable).Interpolation =         DISin.data(itable).Interpolation ;
      
   end % itable
   
   DISout.NTables = length(DISout.Table);

%% EOF