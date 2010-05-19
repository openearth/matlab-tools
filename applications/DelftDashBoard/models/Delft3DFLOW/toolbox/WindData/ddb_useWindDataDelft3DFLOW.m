function handles=ddb_useWindDataDelft3DFLOW(handles,id,windData,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

handles.Model(md).Input(id).WindType='Uniform';
handles.Model(md).Input(id).WindData=windData;
