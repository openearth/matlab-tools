function supertrans_xls2csv(xlsFile)

% xlsFile = 'c:\Users\schri050\Tools\OET\matlab\applications\SuperTrans\data\csv_files\EPSG-v10_013.xlsx';
[fpath,~,~] = fileparts(xlsFile);
[fid,sheets] = xlsfinfo(xlsFile);

for ii = 1:length(sheets)
    clear num txt raw T fname
    [~,~,raw] = xlsread(xlsFile,sheets{ii});
    fname = sprintf('%s.csv',sheets{ii});
    if strncmp(fname,'coord_',6)
        fname = ['coordinate_',fname(7:end)];
    end
    T = cell2table(raw);
    writetable(T,[fpath,'/',fname],'WriteVariableNames',0);
    fprintf('\t%s is written to file\n',fname)
end


return