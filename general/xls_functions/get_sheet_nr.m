function [isheet] = get_sheet_nr(filename,sheetname)

if isnumeric(sheetname)
   isheet = sheetname;
else
   [status,sheets] = xlsfinfo(filename);
   isheet = strmatch(sheetname,sheets);
end
