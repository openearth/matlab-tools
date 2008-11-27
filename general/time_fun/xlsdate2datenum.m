function matlabDates = xlsdate2datenum(excelDates)
%XLSDATE2DATENUM
%
% matlabDates = xlsdate2datenum(excelDates)
%
% method for real input:
%    matlabDates = datenum('30-Dec-1899') + excelDates;
%
% method for string input:
%    datenum(excelDates,'dd-mm-yyyy HH:MM:SS')
%    or for midnights:
%    datenum(excelDates,'dd-mm-yyyy         ')
%
% © G.J. de Boer, Delft University of Technology 2006
%
% See also:
% XLSREAD, DATENUM, DATESTR, TIME2DATENUM

OPT.debug = 0;

   if isnumeric(excelDates)
   
      matlabDates = datenum('30-Dec-1899') + excelDates;
   
   elseif ischar(excelDates)
   
      %% 'dd-mm-yyyy         '
      %%  or 
      %% 'dd-mm-yyyy HH:MM:SS'
      %% first we fill spaces with 00:00:00
      %% then we apply datenum to all rows
      %% ---------------------------------
      
      if size(excelDates,2)==19
         mask                   = strmatch(' ',excelDates(:,19));
         excelDates(mask,12:19) = repmat('00:00:00',[length(mask) 1]);
         if OPT.debug
            for j=1:size(excelDates,1)
            disp(num2str(j))
            matlabDates(j)         = datenum(excelDates(j,:),'dd-mm-yyyy HH:MM:SS');
            end
         else
            matlabDates            = datenum(excelDates(:,:),'dd-mm-yyyy HH:MM:SS');
         end
      elseif size(excelDates,2)==10
         matlabDates            = datenum(excelDates,'dd-mm-yyyy');
      end
      
   end


