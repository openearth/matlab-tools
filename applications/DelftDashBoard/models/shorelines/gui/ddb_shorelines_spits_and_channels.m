function ddb_shorelines_numerics(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectspitoption'}
            select_spit_option;
        case{'selectchanneloption'}
            select_channel_option;
            
    end
    
end

%%
function select_spit_option

handles=getHandles;
opt=handles.model.shorelines.domain.spit_opt;
ddb_giveWarning('text',['Thank you for selecting spit option ' opt]);
setHandles(handles);
%%
function select_channel_option

handles=getHandles;
opt=handles.model.shorelines.domain.channel_opt;
ddb_giveWarning('text',['Thank you for selecting channel option ' opt]);
setHandles(handles);
