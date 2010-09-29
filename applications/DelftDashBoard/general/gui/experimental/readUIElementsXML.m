function s=readUIElementsXML(xml,dr,tag)

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
        s.elements(k).subFields{1}     = getnodeval(elxml(k).element,'subfield1',[],'string');
        s.elements(k).subFields{2}     = getnodeval(elxml(k).element,'subfield2',[],'string');
        s.elements(k).subFields{3}     = getnodeval(elxml(k).element,'subfield3',[],'string');
        s.elements(k).subFields{4}     = getnodeval(elxml(k).element,'subfield4',[],'string');
        s.elements(k).subFields{5}     = getnodeval(elxml(k).element,'subfield5',[],'string');
        s.elements(k).customCallback   = getnodeval(elxml(k).element,'callback',[],'function');
        s.elements(k).onChangeCallback = getnodeval(elxml(k).element,'onchange',[],'function');
        s.elements(k).dependees    = [];
        s.elements(k).dependencies = [];

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
                    s2=readUIElementsXML(elxml(k).element.tabs(j).tab,dr,s.elements(k).tabs(j).tag);
                    s.elements(k).tabs(j).elements    = s2.elements;
                end
                
            case{'table'}
                s.elements(k).includeNumbers = getnodeval(elxml(k).element,'includenumbers',0,'boolean');
                s.elements(k).includeButtons = getnodeval(elxml(k).element,'includebuttons',0,'boolean');
                s.elements(k).nrRows         = getnodeval(elxml(k).element,'nrrows',1,'integer');
                s.elements(k).callback       = getnodeval(elxml(k).element,'callback',[],'function');
                for j=1:length(elxml(k).element.columns)
                    s.elements(k).columns(j).style     = getnodeval(elxml(k).element.columns(j).column,'style',[],'string');
                    s.elements(k).columns(j).varName   = getnodeval(elxml(k).element.columns(j).column,'variable',[],'string');
                    s.elements(k).columns(j).varType   = getnodeval(elxml(k).element.columns(j).column,'vartype',[],'string');
                    s.elements(k).columns(j).width     = getnodeval(elxml(k).element.columns(j).column,'width',[],'integer');
                    s.elements(k).columns(j).callback  = getnodeval(elxml(k).element.columns(j).column,'callback',[],'function');
                    s.elements(k).columns(j).text      = getnodeval(elxml(k).element.columns(j).column,'text',[],'string');
                    s.elements(k).columns(j).popupText = getnodeval(elxml(k).element.columns(j).column,'popuptext',[],'string');
                    s.elements(k).columns(j).enable    = getnodeval(elxml(k).element.columns(j).column,'enable',1,'boolean');
                    s.elements(k).columns(j).format    = getnodeval(elxml(k).element.columns(j).column,'format',[],'string');
                end
               
            otherwise
                % Nodes from xml file
                s.elements(k).text             = getnodeval(elxml(k).element,'text',[],'string');
                s.elements(k).prefix           = getnodeval(elxml(k).element,'prefix',[],'string');
                s.elements(k).suffix           = getnodeval(elxml(k).element,'suffix',[],'string');
                s.elements(k).title            = getnodeval(elxml(k).element,'title',[],'string');
                s.elements(k).textPosition     = getnodeval(elxml(k).element,'textposition','left','string');
                s.elements(k).varName          = getnodeval(elxml(k).element,'variable',[],'string');
                s.elements(k).varType          = getnodeval(elxml(k).element,'vartype',[],'string');
                s.elements(k).nrLines          = getnodeval(elxml(k).element,'nrlines',1,'int');
                s.elements(k).toolTipString    = getnodeval(elxml(k).element,'tooltipstring',[],'string');
                s.elements(k).fileExtension    = getnodeval(elxml(k).element,'extension',[],'string');
                s.elements(k).selectionText    = getnodeval(elxml(k).element,'selectiontext',[],'string');
                s.elements(k).value            = getnodeval(elxml(k).element,'value',[],'string');
        end
    end

    % Checking for dependencies
    for k=1:nrElements
        if isfield(elxml(k).element,'dependencies')
            % There are dependencies
            for id=1:length(elxml(k).element.dependencies)
                
                s.elements(k).dependencies(id).action=elxml(k).element.dependencies(id).dependency.action;
                s.elements(k).dependencies(id).checkFor=elxml(k).element.dependencies(id).dependency.checkfor;

                ntgs=length(elxml(k).element.dependencies(id).dependency.tags);
                for ii=1:ntgs
                    s.elements(k).dependencies(id).tags{ii}=elxml(k).element.dependencies(id).dependency.tags(ii).tag;

                    % Loop through all elements to find
                    % element that control this variable
                    % and set dependees for this variable
                    for jj=1:nrElements
                        if ~isempty(s.elements(jj).varName)
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
                
                for ic=1:length(dep.checks)
                    
                    s.elements(k).dependencies(id).checks(ic).varName=dep.checks(ic).check.variable;
                    s.elements(k).dependencies(id).checks(ic).value=dep.checks(ic).check.value;
                    s.elements(k).dependencies(id).checks(ic).varType=dep.checks(ic).check.vartype;
                    s.elements(k).dependencies(id).checks(ic).operator=dep.checks(ic).check.operator;

                    switch lower(dep.checks(ic).check.vartype)
                        case{'string'}
                        otherwise
                            v=s.elements(k).dependencies(id).checks(ic).value;
                            s.elements(k).dependencies(id).checks(ic).value=str2double(v);
                    end

%                     % Set correct variable type (string or numeric) for this check
%                     for jj=1:nrElements
%                         if ~isempty(s.elements(jj).varName)
%                             if strcmpi(s.elements(k).dependencies(id).checks(ic).varName,s.elements(jj).varName)
%                                 
%                                 % Element jj controls this checked variable
%                                 
%                                 % Change type if necessary
%                                 switch s.elements(jj).varType
%                                     case{'string'}
%                                     otherwise
%                                         v=s.elements(k).dependencies(id).checks(ic).value;
%                                         s.elements(k).dependencies(id).checks(ic).value=str2double(v);
%                                 end
%                                 
%                                 % Now set the dependees
%                                 
%                                 ndep=length(s.elements(jj).dependees);
%                                 ndep=ndep+1;
%                                 s.elements(jj).dependees(ndep).tag=s.elements(k).tag;
%                                 s.elements(jj).dependees(ndep).dependeeNr=k;
%                                 s.elements(jj).dependees(ndep).dependencyNr=id;
%                                 
%                             end
%                         end
%                     end
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
