function nc_file_list = list_of_open_nc_files(action,ncid)
persistent list_of_open_nc_files

if nargin == 2
    switch lower(action)
        case 'open'
            list_of_open_nc_files = [list_of_open_nc_files; ncid];
        case 'close'
            list_of_open_nc_files(ismember(list_of_open_nc_files,ncid)) = [];
        case 'clear'
            list_of_open_nc_files = [];
    end
elseif nargin == 1
    switch lower(action)
        case 'clear'
            list_of_open_nc_files = [];
        case 'open'
        case 'close'
        otherwise
            error('action ''%s'' not supported',action')
    end
end
    
nc_file_list = list_of_open_nc_files;