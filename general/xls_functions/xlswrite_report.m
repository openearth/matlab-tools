function xlswrite_clean(filename,cell_arr,sheetname,varargin);

% set the optianal property/value pairs

OPT.format = '0.000';
OPT        = setproperty(OPT,varargin);

% create filename including full path

[~,name,ext] = fileparts(filename);
filename     = [pwd filesep name ext];

% write default file

xlswrite(filename,cell_arr,sheetname);

%% and now modify, start with deliting empty sheets

delete_empty_excelsheets(filename);

% set column widths

set_colwidth_excel      (filename,1,1,20);
for i_col = 2: size(cell_arr,2)
    set_colwidth_excel      (filename,1,i_col,15);
end

% topline allign right and bold font

range = det_excel_range(1,1,1,size(cell_arr,2),'rowcol');
xlsallign(filename,sheetname,range,'horizontal',4);
xlsfont  (filename,sheetname,range,'size',12,'fontstyle','bold' );

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
