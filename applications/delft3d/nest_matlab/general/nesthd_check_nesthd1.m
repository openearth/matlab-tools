function [handles] = check_nesthd1(handles)

% check_nesthd1 : checks if all information for nesthd1 is present

type_bnd = nesthd_det_filetype(handles.files_hd1{3});

switch type_bnd
    case{'pli' 'ext' 'mdu'}
        if ~isempty(handles.files_hd1{1}) &&                                    ...
           ~isempty(handles.files_hd1{3}) && ~isempty(handles.files_hd1{4})  && ...
           ~isempty(handles.files_hd1{5})
            handles.run_nesthd1_onoff = 'on';
        end
    otherwise
        if ~isempty(handles.files_hd1{1}) && ~isempty(handles.files_hd1{2})  && ...
           ~isempty(handles.files_hd1{3}) && ~isempty(handles.files_hd1{4})  && ...
           ~isempty(handles.files_hd1{5})
            handles.run_nesthd1_onoff = 'on';
        end
end

