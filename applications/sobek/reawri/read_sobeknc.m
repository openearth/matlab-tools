function [Info] = read_sobeknc (dir_or_filename)

% Read all data from all the sobeknc files in a directory or just a single file 

if isdir(dir_or_filename)
    %% Get all filenames
    D                 = dir2(dir_or_filename,'file_incl', '\.nc$');
    files             = find(~[D.isdir]);
    full_file_names   = strcat({D(files).pathname}, {D(files).name})';
    
    for i_file = 1: length(full_file_names)
        [~,name,~] = fileparts(full_file_names{i_file});
        position = strfind(name,'-');
        short_file_name{i_file} = simona2mdu_replacechar(name(1:position(1)-1),' ','_');
        short_file_name{i_file} = simona2mdu_replacechar(short_file_name{i_file},'(','');
        short_file_name{i_file} = simona2mdu_replacechar(short_file_name{i_file},')','');
        Info.(short_file_name{i_file}) = read_sobeknc_file(full_file_names{i_file});
    end
else
    Info = read_sobeknc_file(dir_or_filename);
end

end

function Info = read_sobeknc_file(file_name)

%% Read a single Sobek3 nc file and put everthing in a structure
File       = qpfopen(file_name);
Fields     = qpread(File);
Fieldnames = transpose({Fields.Name});

for i_field = 1: length(Fieldnames)
    
    Name_subfield = simona2mdu_replacechar(Fieldnames{i_field},' ','_');
    Name_subfield = simona2mdu_replacechar(Name_subfield,'(','');
    Name_subfield = simona2mdu_replacechar(Name_subfield,')','');
    Name_subfield = simona2mdu_replacechar(Name_subfield,'.','');
    Param = sum(Fields(i_field).DimFlag);
    if Param == 1
        Info.(Name_subfield) = qpread(File,Fieldnames{i_field},'data',0);
    elseif Param == 2
        Info.(Name_subfield) = qpread(File,Fieldnames{i_field},'data',0,0);
    elseif Param == 3
        Info.(Name_subfield) = qpread(File,Fieldnames{i_field},'data',0,0,0);
    elseif Param == 4
        Info.(Name_subfield) = qpread(File,Fieldnames{i_field},'data',0,0,0,0);
    elseif Param == 5
        Info.(Name_subfield) = qpread(File,Fieldnames{i_field},'data',0,0,0,0,0);
    end
end

end 

 
    




