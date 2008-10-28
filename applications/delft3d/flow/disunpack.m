function DISout = disunpack(DISin)
%DISUNPACK        Rewrites BCT_IO indexed table a struct with one field per data type <<beta version!>>
%
% works presently only for parameters (left) to become fieldname (right)
%
% *.dis
%
% 'total discharge (t)  end A'  > QA
% 'total discharge (t)  end B'  > QB
%
% *.bct
%
% 'flux/discharge rate'         > Q
% 'Salinity'                    > salinity
% 'Temperature'                 > temperature
%
%See also: BCT_IO, DELFT3D_IO_DIS

ReferenceTimeFirst = DISin.Table(1).ReferenceTime;

for itable = 1:DISin.NTables

   %disp(['processing table: ',num2str(itable)])

   %% Check for consistent ReferenceTime times
   %% ---------------------------------------
   
   if ~(ReferenceTimeFirst==DISin.Table(itable).ReferenceTime)
      error('disunpack: ReferenceTime of different tables are different')
   end

   %% Extract data from multi-dimensional table into struct field
   %% ---------------------------------------
   
   H.parameternames = {'QA',...                         %       *.bct
                       'QB',...                         %       *.bct
                       'Q',...                          % *.dis
                       'salinity',...                   % *.dis
                       'temperature'};                  % *.dis
   % units determined from file
   H.tablenames     = {'total discharge (t)  end A',... %       *.bct
                       'total discharge (t)  end B',... %       *.bct
                       'flux/discharge rate',...        % *.dis
                       'Salinity',...                   % *.dis
                       'Temperature',...                % *.dis
                       };

    DISout.data(itable).datenum  = time2datenum(DISin.Table(itable).ReferenceTime) + ...
                                                DISin.Table(itable).Data(:,1)./60./24; % minutes to days
    DISout.data(itable).datenum_units = 'days';
    
   %% Loop over Table names
   %% ---------------------------------------

    for ipar=1:length(H.parameternames)

       parametername      = char(H.parameternames{ipar});
       parameternameunit  = [parametername,'_units'];
       tablename          = char(H.tablenames{ipar});
       
       for ifield = 1:length(DISin.Table(itable).Parameter);
       
          if strcmpi(DISin.Table(itable).Parameter(ifield).Name,tablename);
       
          DISout.data(itable).(parameternameunit) = DISin.Table(itable).Parameter(ifield).Unit;
          DISout.data(itable).(parametername    ) = DISin.Table(itable).Data(:,ifield);
           
          end
        
       end % ifield
       
       %% Calculate cumulative columes from Q
       %% ---------------------------------------
       
       if strcmpi(parametername,'Q')

         DISout.data(itable).volume_units = 'm3';

         if    strcmpi(DISin.Table(itable).Interpolation,'Linear')
         
         DISout.data(itable).volume = cumtrapz(DISout.data(itable).datenum*24*3600,... % [s],...
                                               DISout.data(itable).Q)                  % [m3/s]
                                               
         

         elseif strcmpi(DISin.Table(itable).Interpolation,'Block')

         dt                         = diff(DISout.data(itable).datenum).*24.*3600;    % [s]
         DISout.data(itable).volume = cumsum([0; DISout.data(itable).Q(1:end-1).*dt]);% [m3/s] * [s]

         end

       end
        
    end
    
   %% Copy meta-information
   %% ---------------------------------------

    DISout.data(itable).Name           =         DISin.Table(itable).Name         ;
    DISout.data(itable).Contents       =         DISin.Table(itable).Contents     ;
    DISout.data(itable).Location       =         DISin.Table(itable).Location     ;
    DISout.data(itable).TimeFunction   =         DISin.Table(itable).TimeFunction ;
    DISout.data(itable).ReferenceTime  = num2str(DISin.Table(itable).ReferenceTime);
   %DISout.data(itable).TimeUnit       =         DISin.Table(itable).TimeUnit     ;
    DISout.data(itable).Interpolation  =         DISin.Table(itable).Interpolation;
   %DISout.data(itable).Parameter      =         DISin.Table(itable).Parameter    ; 
   
end

%% EOF