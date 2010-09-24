function s=readUIElementsXML(xml)

if isfield(xml,'elements')
    elxml=xml.elements;
    
    if ischar(elxml)
        elxml=xml_load(elxml);
    end
    
    nrElements=length(elxml);
    
    % s.elements=zeros(nrElements,1);
    
    for k=1:nrElements
        
        s.elements(k).style        = getnodeval(elxml,k,'style',[],'string');
        s.elements(k).position     = getnodeval(elxml,k,'position',[],'real');
        s.elements(k).tag          = getnodeval(elxml,k,'tag',[],'string');
        s.elements(k).name         = getnodeval(elxml,k,'name',[],'string');
        s.elements(k).dependees    = [];
        s.elements(k).dependencies = [];
        
        switch s.elements(k).style
            case{'tabpanel'}
                for j=1:length(elxml(k).element.tabs)
                    s2=readUIElementsXML(elxml(k).element.tabs(j).tab);
                    s.elements(k).tabs(j).elements    = s2.elements;
                    s.elements(k).tabs(j).tabname     = elxml(k).element.tabs(j).tab.tabname;
                    s.elements(k).tabs(j).tabstring   = elxml(k).element.tabs(j).tab.tabstring;
                    if isfield(elxml(k).element.tabs(j).tab,'callback')
                        s.elements(k).tabs(j).callback = str2func(elxml(k).element.tabs(j).tab.callback);
                    else
                        s.elements(k).tabs(j).callback = [];
                    end
                end
            otherwise
                % Nodes from xml file
                s.elements(k).text             = getnodeval(elxml,k,'text',[],'string');
                s.elements(k).prefix           = getnodeval(elxml,k,'prefix',[],'string');
                s.elements(k).suffix           = getnodeval(elxml,k,'suffix',[],'string');
                s.elements(k).title            = getnodeval(elxml,k,'title',[],'string');
                s.elements(k).textPosition     = getnodeval(elxml,k,'textposition','left','string');
                s.elements(k).varName          = getnodeval(elxml,k,'variable',[],'string');
                s.elements(k).varType          = getnodeval(elxml,k,'vartype',[],'string');
                s.elements(k).nrLines          = getnodeval(elxml,k,'nrlines',1,'int');
                s.elements(k).customCallback   = getnodeval(elxml,k,'callback',[],'function');
                s.elements(k).onChangeCallback = getnodeval(elxml,k,'onchange',[],'function');
                s.elements(k).toolTipString    = getnodeval(elxml,k,'tooltipstring',[],'string');
                s.elements(k).fileExtension    = getnodeval(elxml,k,'extension',[],'string');
                s.elements(k).selectionText    = getnodeval(elxml,k,'selectiontext',[],'string');
        end
    end

    % Checking for dependencies
    for k=1:nrElements
        if isfield(elxml(k).element,'dependencies')
            % There are dependencies
            for id=1:length(elxml(k).element.dependencies)
                
                s.elements(k).dependencies(id).action=elxml(k).element.dependencies(id).dependency.action;
                s.elements(k).dependencies(id).checkFor=elxml(k).element.dependencies(id).dependency.checkfor;
                
                dep=elxml(k).element.dependencies(id).dependency;
                
                for ic=1:length(dep.checks)
                    
                    s.elements(k).dependencies(id).checks(ic).varName=dep.checks(ic).check.variable;
                    s.elements(k).dependencies(id).checks(ic).value=dep.checks(ic).check.value;
                    
                    % Set correct variable type (string or numeric) for this check
                    % Loop through all elements to find
                    % element that control this variable
                    % and set dependees for this variable
                    for jj=1:nrElements
                        if ~isempty(s.elements(jj).varName)
                            if strcmpi(s.elements(k).dependencies(id).checks(ic).varName,s.elements(jj).varName)
                                
                                % Element jj controls this checked variable
                                
                                % Change type if necessary
                                switch s.elements(jj).varType
                                    case{'string'}
                                    otherwise
                                        v=s.elements(k).dependencies(id).checks(ic).value;
                                        s.elements(k).dependencies(id).checks(ic).value=str2double(v);
                                end
                                
                                % Now set the dependees
                                
                                ndep=length(s.elements(jj).dependees);
                                ndep=ndep+1;
                                s.elements(jj).dependees(ndep).tag=s.elements(k).tag;
                                s.elements(jj).dependees(ndep).dependeeNr=k;
                                s.elements(jj).dependees(ndep).dependencyNr=id;
                                
                            end
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
function val = getnodeval(elxml,i,nodename,default,tp)

if isfield(elxml(i).element,nodename)
    switch tp
        case{'string'}
            val=elxml(i).element.(nodename);
        case{'function'}
            val=str2func(elxml(i).element.(nodename));
        otherwise
            val=str2num(elxml(i).element.(nodename));
    end
else
    val=default;
end

% %%
% % Check which elements depend on which
% % Each element can get dependees and dependencies
% if idep
%     for ie=1:nrElements
%         if isfield(s2.elements(k).element,'dependencies')
%             % There are dependencies
%             for id=1:length(s2.elements(k).element.dependencies)
%                 
%                 gui.(tabname).elements(k).dependencies(id).action=s2.elements(k).element.dependencies(id).dependency.action;
%                 gui.(tabname).elements(k).dependencies(id).checkFor=s2.elements(k).element.dependencies(id).dependency.checkfor;
%                 
%                 dep=s2.elements(k).element.dependencies(id).dependency;
%                 
%                 for k=1:length(dep.checks)
%                     
%                     gui.(tabname).elements(k).dependencies(id).checks(k).varName=dep.checks(k).check.variable;
%                     gui.(tabname).elements(k).dependencies(id).checks(k).value=dep.checks(k).check.value;
%                     
%                     % Set correct variable type (string or numeric) for this check
%                     % Loop through all elements to find
%                     % element that control this variable
%                     % and set dependees for this variable
%                     for jj=1:length(gui.(tabname).elements)
%                         if ~isempty(gui.(tabname).elements(jj).varName)
%                             if strcmpi(gui.(tabname).elements(k).dependencies(id).checks(k).varName,gui.(tabname).elements(jj).varName)
%                                 
%                                 % Element jj controls this
%                                 % checked variable
%                                 
%                                 % Change type if necessary
%                                 switch gui.(tabname).elements(jj).varType
%                                     case{'string'}
%                                     otherwise
%                                         v=gui.(tabname).elements(k).dependencies(id).checks(k).value;
%                                         gui.(tabname).elements(k).dependencies(id).checks(k).value=str2double(v);
%                                 end
%                                 
%                                 % Now set the dependees
%                                 
%                                 ndep=length(gui.(tabname).elements(jj).dependees);
%                                 ndep=ndep+1;
%                                 gui.(tabname).elements(jj).dependees(ndep).tag=tags{ie};
%                                 gui.(tabname).elements(jj).dependees(ndep).dependeeNr=ie;
%                                 gui.(tabname).elements(jj).dependees(ndep).dependencyNr=id;
%                                 
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
