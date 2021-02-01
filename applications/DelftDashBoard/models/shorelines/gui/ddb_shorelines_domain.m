function ddb_shorelines_domain(varargin)

ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);        

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'blablabla'}
            bla_bla_bla;
            
    end
    
end

%%
function bla_bla_bla

handles=getHandles;
setHandles(handles);

