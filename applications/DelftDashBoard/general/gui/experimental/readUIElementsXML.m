function s=readUIElementsXML(xml,dr,tag,subFields,subIndices)

if isfield(xml,'elements')
    elxml=xml.elements;
    
    try
        if ischar(elxml)
            elxml=xml_load([dr elxml]);
        end
    catch
        disp(['Error loading xml file ' dr elxml]);
    end
    
    nrElements=length(elxml);
    
    % s.elements=zeros(nrElements,1);
    
    for k=1:nrElements

        s.elements(k).style            = getnodeval(elxml(k).element,'style',[],'string');
        s.elements(k).position         = getnodeval(elxml(k).element,'position',[],'real');
        s.elements(k).tag              = getnodeval(elxml(k).element,'tag',[],'string');
        s.elements(k).name             = getnodeval(elxml(k).element,'name',[],'string');
        s.elements(k).customCallback   = getnodeval(elxml(k).element,'callback',[],'function');
        s.elements(k).option1          = getnodeval(elxml(k).element,'option1',[],'string');
        s.elements(k).option2          = getnodeval(elxml(k).element,'option2',[],'string');
        s.elements(k).onChangeCallback = getnodeval(elxml(k).element,'onchange',[],'function');
        s.elements(k).dependees        = [];
        s.elements(k).dependencies     = [];

        % Variable
        if isfield(elxml(k).element,'variable')
%            s.elements(k).variable=readvariable(elxml(k).element,subFields,subIndices);
            s.elements(k).variable=readVariableXML(elxml(k).element.variable,subFields,subIndices);
        end

        tmptag{k}=s.elements(k).tag;
        
        tg = lower(getnodeval(elxml(k).element,'tag',[],'string'));
        if ~isempty(tag)
            s.elements(k).tag = [tag '.' tg];
        else
            s.elements(k).tag = tg;
        end

        switch s.elements(k).style
            case{'tabpanel'}
                for j=1:length(elxml(k).element.tabs)
                    tg = lower(getnodeval(elxml(k).element.tabs(j).tab,'tag',[],'string'));
                    s.elements(k).tabs(j).tag = [s.elements(k).tag '.' tg];
                    s.elements(k).tabs(j).tabname = tg;
                    s.elements(k).tabs(j).tabstring   = elxml(k).element.tabs(j).tab.tabstring;
                    if isfield(elxml(k).element.tabs(j).tab,'callback')
                        s.elements(k).tabs(j).callback = str2func(elxml(k).element.tabs(j).tab.callback);
                    else
                        s.elements(k).tabs(j).callback = [];
                    end
                    s2=readUIElementsXML(elxml(k).element.tabs(j).tab,dr,s.elements(k).tabs(j).tag,subFields,subIndices);
                    s.elements(k).tabs(j).elements    = s2.elements;
                end
                
            case{'table'}
                s.elements(k).includeNumbers = getnodeval(elxml(k).element,'includenumbers',0,'boolean');
                s.elements(k).includeButtons = getnodeval(elxml(k).element,'includebuttons',0,'boolean');
                s.elements(k).nrRows         = getnodeval(elxml(k).element,'nrrows',1,'integer');
                s.elements(k).callback       = getnodeval(elxml(k).element,'callback',[],'function');
                for j=1:length(elxml(k).element.columns)
                    s.elements(k).columns(j).style     = getnodeval(elxml(k).element.columns(j).column,'style',[],'string');
                    s.elements(k).columns(j).width     = getnodeval(elxml(k).element.columns(j).column,'width',[],'integer');
                    s.elements(k).columns(j).callback  = getnodeval(elxml(k).element.columns(j).column,'callback',[],'function');
                    s.elements(k).columns(j).text      = getnodeval(elxml(k).element.columns(j).column,'text',[],'string');
                    s.elements(k).columns(j).popupText = getnodeval(elxml(k).element.columns(j).column,'popuptext',[],'string');
                    s.elements(k).columns(j).enable    = getnodeval(elxml(k).element.columns(j).column,'enable',1,'boolean');
                    s.elements(k).columns(j).format    = getnodeval(elxml(k).element.columns(j).column,'format',[],'string');
                    % Variable
                    if isfield(elxml(k).element.columns(j).column,'variable')
                        s.elements(k).columns(j).variable=readVariableXML(elxml(k).element.columns(j).column.variable,subFields,subIndices);
                    end
                end
               
            otherwise
                % Nodes from xml file
                s.elements(k).text             = getnodeval(elxml(k).element,'text',[],'string');
                s.elements(k).prefix           = getnodeval(elxml(k).element,'prefix',[],'string');
                s.elements(k).suffix           = getnodeval(elxml(k).element,'suffix',[],'string');
                s.elements(k).title            = getnodeval(elxml(k).element,'title',[],'string');
                s.elements(k).textPosition     = getnodeval(elxml(k).element,'textposition','left','string');
                s.elements(k).nrLines          = getnodeval(elxml(k).element,'nrlines',1,'int');
                s.elements(k).toolTipString    = getnodeval(elxml(k).element,'tooltipstring',[],'string');
                s.elements(k).fileExtension    = getnodeval(elxml(k).element,'extension',[],'string');
                s.elements(k).selectionText    = getnodeval(elxml(k).element,'selectiontext',[],'string');
                s.elements(k).value            = getnodeval(elxml(k).element,'value',[],'string');
                if isfield(elxml(k).element,'list')
                    if isstruct(elxml(k).element.list)
                        s.elements(k).stringList.variable=readVariableXML(elxml(k).element.list.variable,subFields,subIndices);
                    else
                        % TODO custom list
%                        s.elements(k).stringList       = getnodeval(elxml(k).element,'list',[],'string');
                    end
                end
        end
    end

    % Checking for dependencies
    for k=1:nrElements
        if isfield(elxml(k).element,'dependencies')
            % There are dependencies
            for id=1:length(elxml(k).element.dependencies)
                
                s.elements(k).dependencies(id).action=elxml(k).element.dependencies(id).dependency.action;
                
                ntgs=length(elxml(k).element.dependencies(id).dependency.tags);
                for ii=1:ntgs
                    s.elements(k).dependencies(id).tags{ii}=elxml(k).element.dependencies(id).dependency.tags(ii).tag;
                    
                    % Loop through all elements to find
                    % element that control this variable
                    % and set dependees for this variable
                    for jj=1:nrElements
                        if ~isempty(s.elements(jj).variable)
                            if strcmpi(s.elements(k).dependencies(id).tags{ii},tmptag{jj})
                                ndep=length(s.elements(jj).dependees);
                                ndep=ndep+1;
                                s.elements(jj).dependees(ndep).tag=s.elements(k).tag;
                                s.elements(jj).dependees(ndep).dependeeNr=k;
                                s.elements(jj).dependees(ndep).dependencyNr=id;
                            end
                        end
                    end
                end
                
                dep=elxml(k).element.dependencies(id).dependency;
                
                if isfield(elxml(k).element.dependencies(id).dependency,'checkfor')
                    s.elements(k).dependencies(id).checkFor=elxml(k).element.dependencies(id).dependency.checkfor;
                    
                    for ic=1:length(dep.checks)
                        
                        s.elements(k).dependencies(id).checks(ic).variable=readVariableXML(dep.checks(ic).check.variable,subFields,subIndices);
                        s.elements(k).dependencies(id).checks(ic).value=dep.checks(ic).check.value;
                        s.elements(k).dependencies(id).checks(ic).operator=dep.checks(ic).check.operator;
                        
                        switch lower(dep.checks(ic).check.variable.type)
                            case{'string'}
                            otherwise
                                v=s.elements(k).dependencies(id).checks(ic).value;
                                s.elements(k).dependencies(id).checks(ic).value=str2double(v);
                        end
                    end
                end
            end
        end
    end
    
else
    s.elements=[];
end

%%
function val = getnodeval(elxml,nodename,default,tp)

if isfield(elxml,nodename)
    switch tp
        case{'string'}
            val=elxml.(nodename);
        case{'function'}
            val=str2func(elxml.(nodename));
        case{'boolean'}
            val=elxml.(nodename);
            switch lower(val(1))
                case{'y','1'}
                    val=1;
                case{'n','0'}
                    val=0;
            end            
        otherwise
            try
            val=str2num(elxml.(nodename));
            catch
                shite=1;
            end
            
    end
else
    val=default;
end

%%
function v=readvariable(el,subFields,subIndices)

if ~isstruct(el.variable)
    % Easy
    v.name       = el.variable;
    v.type       = el.vartype;
    v.subFields  = subFields;
    v.subIndices = subIndices;
else
    % Difficult
    v.name       = el.variable.name;
    v.type       = el.variable.type;
    v.subFields  = subFields;
    v.subIndices = subIndices;
    
    % Subfields and indices
    % Reading custom subfields
    for i=1:10
        fldname=['subfield' num2str(i)];
        indname=['subindex' num2str(i)];
        sft{i}=[];
        sit{i}=[];
        if isfield(el.variable,fldname)
            if ~isstruct(el.variable.(fldname))
                sft{i} = el.variable.(fldname);
            else
                sft{i} = readvariable(el.variable.(fldname),subFields,subIndices);
            end            
        end
        if isfield(el.variable,indname)
            if ~isstruct(el.variable.(indname))
                sit{i} = el.variable.(indname);
            else
                sit{i} = readvariable(el.variable.(indname),subFields,subIndices);
            end            
        end
    end
    
    % Subfields and indices
    % Reading custom subfields
    for i=1:10
%         fldname=['subfield' num2str(i)];
%         indname=['subindex' num2str(i)];
%         sft       = getnodeval(elxml(k).element,fldname,[],'string');
%         sit       = getnodeval(elxml(k).element,indname,[],'string');
        if ~isempty(sft)
            sf{i}  = sft;
            if isempty(sit)
                sit=1;
            else
                if ~isempty(str2num(sit))
                    si{i}=str2num(sit);
                else
                    si{i}=sit;
                end
            end
        else
            sf{i}=[];
            si{i}=[];
        end
    end
    
    % Set standard subfields and indices
    if ~isempty(subFields{1})
        for i=1:length(subFields)
            s.elements(k).subFields{i}=subFields{i};
            s.elements(k).subIndices{i}=subIndices{i};
        end
    end
    
    % Set custom subfields and indices
    for i=1:10
        if ~isempty(sf{i})
            % Custom subfield
            s.elements(k).subFields{i}=sf{i};
            if ~isempty(si{i})
                s.elements(k).subIndices{i}=si{i};
            end
        end
    end
    
end
