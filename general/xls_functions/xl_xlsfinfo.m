function [Sheets_Names]  = xl_xlsfinfo(file_name)
%%********************************************************************************
%   Name          : xl_xlsfinfo
%   Author        : Pruthvi Raj G
%   Version       : Version 1.0 - 2011b Compactible
%   Description   : Finds all the sheets in the Excel file (.xls,.xlsm,.xlsx)
%   Input         : File_Name with path included.
%   Date          : 11-Feb-2020
%
%   Examples      : xl_xlsfinfo('D:\Pruthvi\Test_file.xls')
%*********************************************************************************
% Open the Excel file (*.xls or *.xlsx).
Excel = actxserver('Excel.Application');
Excel.Workbooks.Open(file_name);

% Finding the Sheets.

workSheets = Excel.sheets;
for i = 1:workSheets.Count
    sheet = get(workSheets,'item',i);
    Sheets_Names{i} = sheet.Name;
end

Excel.DisplayAlerts = 0;
% Close Excel Sheet
Excel.ActiveWorkbook.Close;
% quit Excel Object
Excel.Quit;
Excel.delete;
end
