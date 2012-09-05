function handles=muppet_readFileTypes(handles)

dr='c:\work\checkouts\OpenEarthTools\trunk\matlab\applications\muppet4\xml\filetypes\';
flist=dir([dr '*.xml']);
for ii=1:length(flist)
    xml=xml2struct2([dr flist(ii).name]);
    handles.filetype(ii).filetype=xml;
    if isfield(handles.filetype(ii).filetype,'option')
        for jj=1:length(handles.filetype(ii).filetype.option)
            if ~isfield(handles.filetype(ii).filetype.option(jj).option,'element')
                handles.filetype(ii).filetype.option(jj).option.element=[];
            end
            if ~isfield(handles.filetype(ii).filetype.option(jj).option,'muptext')
                handles.filetype(ii).filetype.option(jj).option.muptext=[];
            end
        end
    else
        handles.filetype(ii).filetype.option=[];
    end
end
