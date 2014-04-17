      function [mnes,nnes,weight,varargout] = nesthd_getwgh (fid,mcbsp ,ncbsp ,typbnd)

      % getwgh : gets coordinates and weights from the nest administration file

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : getwgh
% version            : v1.0
% date               : June 1997
% programmer         : Theo van der Kaaij
%
% function           : Gets coordinates and weights for water level
%                      and velocity boundaries
% limitations        :
% subroutines called :
%***********************************************************************

      fseek (fid,0,'bof');

      switch typbnd
         case 'z'
            quantity = 'water level';
         case {'c' 'r' 'n'}
            quantity = 'velocity';
         case {'x' 'p'}
            quantity = 'velocity(t)';
      end
%
%-----cycle through administration file
%
      found = false;
      tline = fgetl(fid);
      while ischar (tline) && ~found;
          pos = strfind (tline,quantity);
          if ~isempty(pos)
             m = strread(tline(60:64),'%4d');
             n = strread(tline(66:70),'%4d');

             if m == mcbsp && n == ncbsp
                found = true;
%
%---------------Read orientation (angle and positive inflow)
%
                if typbnd == 'c' || typbnd == 'r' || typbnd == 'x' || typbnd == 'p' || typbnd == 'n'
                   varargout{1} = strread(tline(80:88),'%9.3f')*pi/180.;
                end
                if typbnd == 'r'
                   varargout{2} = strread(tline(99:end),'%s');
                end
%
%---------------Read nesting stations and belonging weights
%
                for iwght = 1: 4
                   switch typbnd
                      case {'c' 'z' 'x' 'p'}
                         [values] = fscanf(fid,'%d %d %f',3);
                      case {'r' 'n'}
                         [values] = fscanf(fid,'%d %d %f %g %g',5);
                         x(iwght) = values(4);
                         y(iwght) = values(5);
                   end
                   mnes(iwght)   = values(1);
                   nnes(iwght)   = values(2);
                   weight(iwght) = values(3);
                end
                if typbnd == 'n'
                    varargout{3} = x;
                    varargout{4} = y;
                end
             end
          end
          tline = fgetl(fid);
      end
