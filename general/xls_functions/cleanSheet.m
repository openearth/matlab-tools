function cleanSheet(fileName,sheetName)

%% Clear contents of sheetName (avoid leftovers of previous manipulations
excelObj      = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);
worksheets    = excelObj.sheets;
numSheets     = worksheets.Count;
for iSheet = 1: numSheets
   Name = worksheets.Item(iSheet).Name;
   if ~isempty(strmatch(Name,sheetName))
      worksheets.Item(iSheet).Cells.Clear;
   end
end

excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);
