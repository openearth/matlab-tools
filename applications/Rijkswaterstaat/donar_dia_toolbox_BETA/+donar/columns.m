function varargout = columns()
%columns  name and units of dia columns
%
%  [columns     ] = donar.columns()
%  [names, units] = donar.columns()
%
%See also: 

   column.units = {'degrees_east' ,'degrees_north','centimeters'  , ...
                   'yyyymmdd'     ,'HHMMSS'       , ''};
   column.names = {'longitude'    ,'latitude'     , 'depth'        , ...
                   'datestring'   ,'timestring'   , 'variable'     };

if     nargout==1
   varargout = {column};
elseif nargout==2
   varargout = {column.names,column.units};
end
