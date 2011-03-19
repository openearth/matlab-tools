function [handles,cancel]=ddb_makeDDModel(handles,id1,id2,runid)

% wb = waitbox('Generating Subdomain ...');pause(0.1);

runid1=handles.Model(md).Input(id1).runid;
runid2=runid;

handles.Model(md).Input(id2)=handles.Model(md).Input(id1);

% create backup of original model with id0
handles.Toolbox(tb).Input.originalDomain=handles.Model(md).Input(id1);

handles=ddb_initializeFlowDomain(handles,'griddependentinput',id2,runid);

m1=handles.Toolbox(tb).Input.firstCornerPointM;
n1=handles.Toolbox(tb).Input.firstCornerPointN;
m2=handles.Toolbox(tb).Input.secondCornerPointM;
n2=handles.Toolbox(tb).Input.secondCornerPointN;
mdd(1)=min(m1,m2);mdd(2)=max(m1,m2);
ndd(1)=min(n1,n2);ndd(2)=max(n1,n2);

% New Domain
% Grid
[handles,mdd,ndd]=ddb_makeDDModelNewGrid(handles,id1,id2,mdd,ndd,runid);

% Original Domain
% Grid
[handles,mcut,ncut,cancel]=ddb_makeDDModelOriginalGrid(handles,id1,mdd,ndd);

if ~cancel

    % New Domain
    % Attributes
    handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2);

end

% close(wb);
