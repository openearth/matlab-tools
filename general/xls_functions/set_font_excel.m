function set_font_excel(fileName,isheet,range,varargin)

%
% changes font, fontsize, fonttype of sheet nr isheet from an excel file
% options:   name   (fontname)
%            size
%            type   (italic, bold etc)

%
% determine what is requested
%

fontname = '';
fontsize = [];
fonttype = '';

for iargin = 1: length(varargin)
    if strcmpi(varargin{iargin},'name')
       fontname = varargin{iargin + 1};
    end
    if strcmpi(varargin{iargin},'size')
       fontsize = varargin{iargin + 1};
    end
    if strcmpi(varargin{iargin},'type')
       fontsize = varargin{iargin + 1};
    end
end

%
% Open excell workbook
%

excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);

%
% Get the requested sheet
%

excelSheets    = excelWorkbook.Sheets;
excelSheets_no = excelSheets.get('Item', isheet);
excelSheets_no.Activate;

%
% Set Range of cells for which to apply (range must be in excel format (A1:B8)
%

eActivesheetRange = excelObj.Activesheet.get('Range', range);

%
% Modify
%

if length (fontname) > 0
end
if ~isempty (fontsize)
   eActivesheetRange.Font.Size = fontsize;
end
if length(type) > 0
end

%
% Save and closes excel sheet
%

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);
