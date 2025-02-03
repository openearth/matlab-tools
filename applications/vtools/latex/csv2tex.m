function csv2tex(filecsv, filetex, caption); 
%CSV2TEX transfers DFLOWFM simulation results at cell faces to netCDF UGRID file.
%
% Example usage: 
% csv2ugrid(filecsv,filetex); 
%  
% filecsv: path of input csv 
% filetex: path of output tex
%
%
% Include in tabular environment within Latex document using \input{}
%

fid_csv = fopen(filecsv,'r');
fid_tex = fopen(filetex,'w');

fname_st=dbstack(1, '-completenames');
if isempty(fname_st)
    fpath_main=pwd;
else
    fpath_main=fname_st(end).file;
end
[filepath,filebase,fileext] = fileparts(filetex);


fprintf(fid_tex, '%s%s\n', '%created:     ', datestr(now));
fprintf(fid_tex, '%s%s\n', '%user:        ', getenv('USERNAME'));
fprintf(fid_tex, '%s%s\n', '%called from: ', fpath_main);  
fprintf(fid_tex, '%s\n','%');
fprintf(fid_tex, '%s\n', '\begin{table}[ht!]');
fprintf(fid_tex, '%s\n', '  %\tiny');
fprintf(fid_tex, '%s\n', '  \begin{center}');
fprintf(fid_tex, '%s%s%s\n', '  \caption{',caption,'}');
fprintf(fid_tex, '%s\n', '  \begin{adjustwidth}{-2cm}{-2cm}');

count = 1; 
a = fgetl(fid_csv); 
while a ~= -1
    if count > 1; 
        a = strrep(a,'1000', '>1000'); %ad hoc 
        s = strsplit(a,','); 
        fprintf(fid_tex, '%s', '                  ');
        for k = 1:length(s)-1;
            fprintf(fid_tex, '%11s & ', s{k});
        end
        fprintf(fid_tex, '%11s \\\\ \n', s{length(s)});        
    else
        s = strsplit(a,','); 
        for k = 1:length(s);
            r = strsplit(s{k}, '_'); 
            for j = 1:length(r); 
                s2{k,j} = r{j}; 
            end
        end
        fprintf(fid_tex, '%s%s%s\n', '     \begin{tabular}{',repmat('c',1,size(s2,1)),'}');
        for j = 1:size(s2,2); 
            fprintf(fid_tex, '%s', '\rowcolor{dblue1} ');
            for k = 1:length(s)-1;
                fprintf(fid_tex, '%11s & ', s2{k,j});
            end
            fprintf(fid_tex, '%11s \\\\ \n', s2{length(s),j});
        end
        fprintf(fid_tex, '%s \n', '\hline');
    end
    a = fgetl(fid_csv); 
    count = count + 1; 
end

fprintf(fid_tex, '%s\n', '	   \end{tabular}');
fprintf(fid_tex, '%s%s%s\n', '     \label{tab:', filebase,'}');
fprintf(fid_tex, '%s\n', '    \end{adjustwidth}');
fprintf(fid_tex, '%s\n', '  \end{center}');
fprintf(fid_tex, '%s\n', '\end{table}');

fclose(fid_tex);
fclose(fid_csv);

fprintf('%s\n', ''); 
fprintf('%s\n', 'Include the following in your latex document');
fprintf('%s%s%s%s\n', '\input{tables/', filebase, fileext,'}');

end