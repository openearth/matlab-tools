function handles=ddb_openUnibestCL(opt)

handles=getHandles;

switch opt
    case {'open'}
        [filename, pathname, filterindex] = uigetfile('*.ltr', 'Select LTR file');
        if pathname~=0
            %ddb_plotUnibestCL(handles,'delete');
            handles.Model(md).Input=[];
            runid=filename(1:end-4);
            handles=ddb_initializeUnibestCLInput(handles,runid);
            filename=[runid '.ltr'];
            handles=ddb_readLTR(handles,[filename]);
%             handles=ddb_readAttributeFiles(handles);
            %ddb_plotUnibestCL(handles,'plot',1);
            %handles=ddb_refreshUnibestCLInput(handles);
        end
end
setHandles(handles);
end

        

