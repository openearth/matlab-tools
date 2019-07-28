function nr = get_nr(cell_str,str)

%% Restrict to length of str
for i_cell = 1: length(cell_str)
    cell_str{i_cell} = cell_str{i_cell}(1:min(length(cell_str{i_cell}), max(length(str),1)));
end

%% Get the index of str in the cell array of strings cell_str
nr = find(strcmpi(str,cell_str) == 1);
