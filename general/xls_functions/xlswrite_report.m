function xlswrite_report(filename,cell_arr,sheetname,varargin)
%xlswrite_report

%
% Function                      : Generates a "report" xls file whereas matlab's own xlswrite produces
%                                 a rather messy excel file. The top row an left most column are assumed to
%                                 be describtive and displayed in a different color than the "body".
% usage (identical to xlswrite) : xlswrite_report(filename,cell_arr,sheetname, ... , ...)
%                                 filename  = name of the resulting xls file
%                                 cell_arr  = cell array of values/names to be written to the excell file
%                                 sheetname = name of the sheet in the xls file
%                                 optional property/value pairs are:
%                                 'format'   xls format like for instance '0.00'
%                                 'colwidth' vector of nrow column widths (pts)
%
%                                 an example of how to use this functions is given in xls_xmp.m
%
% start with setting the optional property/value pairs

OPT.format      = '0.000';
OPT.colwidth(1) = 20;
for i_col = 2: size(cell_arr,2)
    OPT.colwidth(i_col) = 20;
end
OPT        = setproperty(OPT,varargin);

%%
filename =  relativeToabsolutePath(filename);

% write default file

xlswrite(filename,cell_arr,sheetname);

%% and now modify, start with deliting empty sheets

delete_empty_excelsheets(filename);

% set column widths

set_colwidth_excel      (filename,sheetname,1,OPT.colwidth(1));
for i_col = 2: size(cell_arr,2)
    set_colwidth_excel      (filename,sheetname,i_col,OPT.colwidth(i_col));
end

% topline allign right and bold font
range = det_excel_range(1,1,1,1,'rowcol');
xlsallign(filename,sheetname,range,'horizontal',2);
xlsfont  (filename,sheetname,range,'size',12,'fontstyle','bold' );
range = det_excel_range(1,2,1,size(cell_arr,2),'rowcol');
xlsallign(filename,sheetname,range,'horizontal',4);
xlsfont  (filename,sheetname,range,'size',10,'fontstyle','bold' );

% set format interior

range            = det_excel_range(2,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
set_format_excel (filename,sheetname,range,OPT.format);

% set borders

range            = det_excel_range(1,1,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(2,1,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'box',1,4,1);

range            = det_excel_range(1,1,1,size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'InsideVertical',1,4,1);

range            = det_excel_range(2,1,size(cell_arr,1),1,'rowcol');
xlsborder        (filename,sheetname,range,'InsideHorizontal',1,3,1);

range            = det_excel_range(2,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
xlsborder        (filename,sheetname,range,'InsideHorizontal',2,2,1);
xlsborder        (filename,sheetname,range,'InsideVertical'  ,2,2,1);

% Set Colors

range            = det_excel_range(1,2,1,size(cell_arr,2),'rowcol');
set_color_excel  (filename,sheetname,range,[255 255 0],'rgb');

range            = det_excel_range(2,1,size(cell_arr,1),1,'rowcol');
set_color_excel  (filename,sheetname,range,[0 255 255],'rgb');

range            = det_excel_range(2,2,size(cell_arr,1),size(cell_arr,2),'rowcol');
set_color_excel  (filename,sheetname,range,[192 192 192],'rgb');
