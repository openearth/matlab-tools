function nr = get_nr(cell_str,str)

%% Get the index of str in the cell array of strings cell_str
nr = find(strcmp(str,cell_str) == 1);
