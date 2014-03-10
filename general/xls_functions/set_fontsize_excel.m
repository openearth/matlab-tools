
function set_fontsize_excel(fileName,isheet,range,fontsize)

%
% Get Sheetnr if Sheetname is given
%

isheet = get_sheet_nr(fileName,sheet);

%
% Open excel woorkbook
%


excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%
% Select and activate the requested sheet
%

excelSheets    = excelWorkbook.Sheets;
excelSheets_no = excelSheets.get('Item', isheet);
excelSheets_no.Activate;

%
% Set Range
%

eActivesheetRange = excelObj.Activesheet.get('Range', range);

%
% Set fontsize (within range)
%

eActivesheetRange.Font.Size = fontsize;

%
% Save and close workbook
%

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);

