function handles=ddb_readModelXMLs(handles)

for j=1:length(handles.Model)

    gui=handles.Model(j).GUI;
    
    fname=[handles.Model(j).Name '.xml'];
    
    if exist(fname,'file')
        
        handles.Model(j).useXML=1;
        
        s=xml_load(fname);
        
        % Set long name
        handles.Model(j).longName=s.longname;
        
        % Set tab info
        for i=1:length(s.tabs)
            
            gui.upperPanel.shortName{i}=s.tabs(i).tab.shortname;
            gui.upperPanel.longName{i}=s.tabs(i).tab.longname;
            gui.upperPanel.strings{i}=s.tabs(i).tab.longname;
            gui.upperPanel.width(i)=str2double(s.tabs(i).tab.width);
            
            tabname=gui.upperPanel.shortName{i};
            
            fname2=[handles.Model(j).Name '.' tabname '.xml'];
            
            if exist(fname2,'file')
                
                gui.(tabname).useXML=1;
                
                s2=xml_load(fname2);
                
                % Getting ui elements
                idep=0;                
                for k=1:length(s2.elements)
                    
                    % Nodes from xml file
                    gui.(tabname).elements(k).style            = getnodeval(s2,k,'style',[],'string');
                    gui.(tabname).elements(k).position         = getnodeval(s2,k,'position',[],'real');
                    gui.(tabname).elements(k).text             = getnodeval(s2,k,'text',[],'string');
                    gui.(tabname).elements(k).title            = getnodeval(s2,k,'title',[],'string');
                    gui.(tabname).elements(k).textPosition     = getnodeval(s2,k,'textposition','left','string');
                    gui.(tabname).elements(k).varName          = getnodeval(s2,k,'variable',[],'string');
                    gui.(tabname).elements(k).varType          = getnodeval(s2,k,'vartype',[],'string');
                    gui.(tabname).elements(k).nrLines          = getnodeval(s2,k,'nrlines',1,'int');
                    gui.(tabname).elements(k).customCallback   = getnodeval(s2,k,'callback',[],'string');
                    gui.(tabname).elements(k).onChangeCallback = getnodeval(s2,k,'onchange',[],'string');
                    gui.(tabname).elements(k).toolTipString    = getnodeval(s2,k,'tooltipstring',[],'string');
                    gui.(tabname).elements(k).tag              = getnodeval(s2,k,'tag',[],'string');
                    gui.(tabname).elements(k).fileExtension    = getnodeval(s2,k,'extension','*.*','string');
                    gui.(tabname).elements(k).selectionText    = getnodeval(s2,k,'selectiontext','','string');
                    
                    % Stuff needed for dependencies
                    gui.(tabname).elements(k).dependees        = [];
                    gui.(tabname).elements(k).dependencies     = [];
                    if isfield(s2.elements(k).element,'tag')
                        tags{k}=s2.elements(k).element.tag;
                    else
                        tags{k}='';
                    end                    
                    if isfield(s2.elements(k).element,'dependencies')
                        idep=1;
                    end
                    
                end
                
                % Check which elements depend on which
                % Each element can get dependees and dependencies
                if idep
                    for ie=1:length(s2.elements)
                        if isfield(s2.elements(ie).element,'dependencies')
                            % There are dependencies
                            for id=1:length(s2.elements(ie).element.dependencies)
                                gui.(tabname).elements(ie).dependencies(id).dependency=s2.elements(ie).element.dependencies(id).dependency;
                                dep=s2.elements(ie).element.dependencies(id).dependency;
                                for k=1:length(dep.checks)
                                    chk=dep.checks(k).check;
                                    if isfield(chk,'tag')
                                        ii=strmatch(lower(chk.tag),lower(tags),'exact');
                                        % a callback for this tag needs to be added
                                        ndep=length(gui.(tabname).elements(ii).dependees);
                                        ndep=ndep+1;
                                        gui.(tabname).elements(ii).dependees(ndep).tag=tags{ie};
                                    end
                                end
                            end
                        end
                    end
                end
            else
                gui.(tabname).useXML=0;
            end
        end
    else
        handles.Model(j).useXML=0;
    end
    
    handles.Model(j).GUI=gui;
    
end

%%
function val = getnodeval(elstr,i,nodename,default,tp)

if isfield(elstr.elements(i).element,nodename)
    switch tp
        case{'string'}
            val=elstr.elements(i).element.(nodename);
        otherwise
            val=str2num(elstr.elements(i).element.(nodename));
    end
else
    val=default;
end

