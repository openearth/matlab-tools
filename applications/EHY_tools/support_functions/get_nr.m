function nr = get_nr(cell_str,str)

%% Restrict to length of str
%  Cannot remeber why I did this
% for i_cell = 1: length(cell_str)
%    cell_str{i_cell} = cell_str{i_cell}(1:min(length(cell_str{i_cell}), max(length(str),1)));
% end

%% Get the index of str in the cell array of strings cell_str
% not very elegant. Must do for now
nr = [];
for i_name = 1: length(cell_str)
    if strcmpi(cell_str{i_name},str)
        nr(end + 1) = i_name;
    end
end
