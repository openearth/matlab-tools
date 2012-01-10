function ddb_getToolboxData(localdir,a)

handles = getHandles;

% Try to download data from server
name = handles.Toolbox(a).name;
try
    url = ['http://opendap.deltares.nl/static/deltares/delftdashboard/toolboxes/' name '/' name '.xml'];
    xmlfile = [name '.xml'];
    toolboxdata = ddb_getXmlData(localdir,url,xmlfile);
    if ~isempty(toolboxdata)
        for ii=1:length(toolboxdata.file)
            if  toolboxdata.file(ii).update == 1
                if strcmp(toolboxdata.file(ii).type,'misc')
                    urlwrite(toolboxdata.file(ii).URL,[handles.Toolbox(a).miscDir filesep toolboxdata.file(ii).name]);
                else
                    urlwrite(toolboxdata.file(ii).URL,[handles.Toolbox(a).dataDir filesep toolboxdata.file(ii).name]);
                end
            end
        end
    end
catch
    disp(['Could not retreive data from server for ' name ' toolbox']);
end