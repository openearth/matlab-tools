function combine_in_to_single_tex(main_file, combined_file) 
%COMBINE_IN_TO_SINGLE_TEX - combine mulitple tex files into a single one

%Usage: 
%combine_in_to_single_tex(main_file, combined_file) 
%   main_file:     top-level file 
%   combined_file: combined file 

% create an empty file
fileID_combined = fopen(combined_file,'w');
fclose(fileID_combined); 

% scan through the file and add to combined file
curdir = pwd; 
move_lines_from_files_to_combined(main_file, combined_file, curdir)

function move_lines_from_files_to_combined(main_file, combined_file, curdir)
    fileID_main = fopen(fullfile(curdir, main_file),'r');
    % open combined file as appending 
    fileID_combined = fopen(combined_file,'a');
    tline = fgetl(fileID_main);
    while ischar(tline)
        idx_input = strfind(tline,'\input'); 
        if idx_input > 0; 
            % exclude comment line
            if isempty(strfind(tline(1:idx_input),'%')); 
                out = regexp(tline, '\{.*\}','match'); 
                [rel_dir,rel_file] = fileparts(fullfile(curdir,out{1}(2:end-1))); 
                fclose(fileID_combined); 
                move_lines_from_files_to_combined([rel_file, '.tex'], combined_file, rel_dir)
                fileID_combined = fopen(combined_file,'a');
            else
                fprintf(fileID_combined, '%s\r\n', tline);
            end
        else
            fprintf(fileID_combined, '%s\r\n', tline);
        end
        tline = fgetl(fileID_main);
    end
    fclose(fileID_main);
    fclose(fileID_combined); 
end

end