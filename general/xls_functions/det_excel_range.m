function [range] = det_excel_range (col_start,row_start,col_stop,row_stop,varargin)

%
% Specified as colrow (Exceltype) or rowcol (more mathematical)
% default is colrow
%

nVarargins = length(varargin);

if nVarargins == 1
   if strcmpi (varargin{1},'rowcol');

      %
      % Switch rows and colums
      %

      col_tmp   = col_start;
      col_start = row_start;
      row_start = col_tmp;

      col_tmp  = col_stop;
      col_stop = row_stop;
      row_stop = col_tmp;
   end
end

%
% convert start and stop column (nr) to excel character
%

if col_start <= 26
   c1 = char(64 + col_start);
else
   ihulp1 = floor(col_start/26);
   ihulp2 = mod  (col_start,26);
   c1     = [char(64 + ihulp1) char(64 + ihulp2)];
end

if col_stop <= 26
   c2 = char(64 + col_stop);
else
   ihulp1 = floor(col_stop/26);
   ihulp2 = mod  (col_stop,26);
   c2     = [char(64 + ihulp1) char(64 + ihulp2)];
end

%
% construct the excel range
%

range     = [c1 num2str(row_start) ':' c2 num2str(row_stop)];
