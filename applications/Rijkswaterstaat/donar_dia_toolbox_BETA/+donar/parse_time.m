function [block_data,unique_years] = parse_time(block_data, datetimeCol, varargin)
%PARSE_TIME   parse time in block into decimal days since reference day
%
%  block_data               = donar.parse_time(block_data, datetimeCol, refdatenum)
% [block_data,unique_years] = donar.parse_time(block_data, datetimeCol, refdatenum)
%
% where datetimeCol(1) indicates the date column index into
% block_data = donar.read_block(), and datetimeCol(2) the time
% column index, if any. donar.parse_time() also sorts the 
% matrix chronologically.
%
% The  datetimeCol(1) in block_data become decimal days since
% the optional refdatenum, with as default Matlab datenumb: days
% since 0000-00-00, but recommended since 1970-01-01.
%
% The time column, which is redundsnt after donar.parse_time()
% is kept in the  block_data to maintain column indices, and 
% checking accuracy for small time intervals.
%
% Do not call parse_time() twice on the same block_data !
%
%See also: parse_coordinates.

    if odd(nargin)
        refdatenum = varargin{1};
    else
        refdatenum = 0;
    end
   
   dateCol = datetimeCol(1);
   
   if length(datetimeCol) > 1
   timeCol = datetimeCol(2);
   block_data(:,dateCol) = time2datenum(block_data(:,dateCol),...
                                        block_data(:,timeCol)) - refdatenum;   
   else
   block_data(:,dateCol) = time2datenum(block_data(:,dateCol)) - refdatenum;
   end

   block_data = sortrows(block_data,dateCol);

   unique_years = year(block_data(:,dateCol));


