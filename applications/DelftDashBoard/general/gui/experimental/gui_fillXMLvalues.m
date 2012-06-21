function xml=gui_fillXMLvalues(xml,varargin)
% Does some string to numeric conversions and adds default values

variableprefix=[];
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'variableprefix'}
                variableprefix=varargin{ii+1};
        end
    end
end

fldnames=fieldnames(xml);

% First some conversions ...
for ii=1:length(fldnames)
    fldname=fldnames{ii};    
    switch fldname
        case{'enable','multipledomains','includenumbers','includebuttons','showfilename'}
            switch lower(xml.(fldname)(1))
                case{'y','1'}
                    xml.(fldname)=1;
                otherwise
                    xml.(fldname)=0;
            end
        case{'position'}
            pos=str2num(xml.position);
            pos=[pos repmat(20,1,4-length(pos))];
            xml.position=pos;
        case{'nrlines','nrrows','max'}
            xml.(fldname)=str2num(xml.(fldname));
        case{'callback'}
            if ~isempty(xml.callback)
                xml.callback=str2func(xml.callback);
            end
        case{'onchange'}
            if ~isempty(xml.onchange)
                xml.callback=str2func(xml.onchange);
            end
    end
end

% And now add missing values
for ii=1:length(fldnames)
    fldname=fldnames{ii};
    switch fldname
        case{'elements'}
            for ielm=1:length(xml.elements)
                xml.elements(ielm).element=gui_fillXMLvalues(xml.elements(ielm).element,'variableprefix',variableprefix);
                % Fill missing element values
                xml.elements(ielm).element=fillMissingElementValues(xml.elements(ielm).element,variableprefix);
                switch lower(xml.elements(ielm).element.style)
                    case{'table'}
                        xml.elements(ielm).element.columns=fillMissingColumnValues(xml.elements(ielm).element.columns);
                end
            end
        case{'tabs'}
            for itab=1:length(xml.tabs)
                xml.tabs(itab).tab=gui_fillXMLvalues(xml.tabs(itab).tab,'variableprefix',variableprefix);
                xml.tabs(itab).tab=fillMissingTabValues(xml.tabs(itab).tab);
            end            
        case{'model'}
            if ~isfield(xml,'multipledomains')
                xml.multipledomains=0;
            end
            if ~isfield(xml,'enable')
                xml.enable=0;
            end
            if ~isfield(xml,'longname')
                xml.longname=xml.model;
            end
        case{'toolbox'}
            if ~isfield(xml,'enable')
                xml.enable=0;
            end
            if ~isfield(xml,'longname')
                xml.longname=xml.model;
            end
    end
end

%%
function el=fillMissingElementValues(el,variableprefix)

default.style=[];
default.position=[];
default.tag='';
default.name=[];
default.callback=[];
default.option1=[];
default.option2=[];
default.parent=[];
default.dependencies=[];
default.multivariable=[];
default.includenumbers=0;
default.includebuttons=0;
default.nrrows=1;
default.nrlines=1;
default.enable=1;
default.horal='left';
default.prefix=[];
default.suffix=[];
default.title=[];
default.textposition='left';
default.tooltipstring=[];
default.extension=[];
default.selectiontext=[];
default.value=[];
default.showfilename=1;
default.type='string';
default.mx=[];
default.max=[];
default.bordertype='etchedin';
default.format='';
default.text='';
default.list=[];
default.variableprefix=[];

el.variableprefix=variableprefix;

fields=fieldnames(default);
for ii=1:length(fields)
    if ~isfield(el,fields{ii})
        el.(fields{ii})=default.(fields{ii});
    end
end

% List
if ~isfield(el.list,'texts')
    el.list.texts=[];
end
for jj=1:length(el.list.texts)
    if ~isfield(el.list.texts,'text')
        el.list.texts(jj).text=[];
    end
end
if ~isfield(el.list,'values')
    el.list.values=[];
end
for jj=1:length(el.list.values)
    if ~isfield(el.list.values,'value')
        el.list.values(jj).value=[];
    end
end

% Dependencies
if ~isfield(el,'dependencies')
    el.dependencies=[];
end
for jj=1:length(el.dependencies)
    if ~isfield(el.dependencies(jj).dependency,'action')
        el.dependencies(jj).dependency.action='enable';
%         warning(['No action supplied for dependency in element ' el.tag '. Using enable instead.']);
    end
    if ~isfield(el.dependencies(jj).dependency,'checkfor')
        el.dependencies(jj).dependency.checkfor='all';
    end
    if ~isfield(el.dependencies(jj).dependency,'tags')
        el.dependencies(jj).dependency.tags=[];
    end
    if ~isfield(el.dependencies(jj).dependency,'checks')
        el.dependencies(jj).dependency.checks=[];
%         warning(['No checks supplied for dependency in element ' el.tag]);
    end
    for kk=1:length(el.dependencies(jj).dependency.checks)
        if ~isfield(el.dependencies(jj).dependency.checks(kk).check,'variable')
            el.dependencies(jj).dependency.checks(kk).check.variable=[];
%            warning(['No variable supplied for dependency in element ' el.tag]);
        end        
        if ~isfield(el.dependencies(jj).dependency.checks(kk).check,'operator')
            el.dependencies(jj).dependency.checks(kk).check.operator=[];
%            warning(['No operator supplied for dependency in element ' el.tag '. Using .eq. instead.']);
        end
        if ~isfield(el.dependencies(jj).dependency.checks(kk).check,'value')
            el.dependencies(jj).dependency.checks(kk).check.value=[];
%            warning(['No value supplied for dependency in element ' el.tag '. Using .eq. instead.']);
        end
%         if ~isnan(str2double(el.dependencies(jj).dependency.checks(kk).check.value))
%             el.dependencies(jj).dependency.checks(kk).check.value=str2double(el.dependencies(jj).dependency.checks(kk).check.value);
%         end
    end
end

%%
function columns=fillMissingColumnValues(columns)

for jj=1:length(columns)
    fields=fieldnames(columns(jj).column);
    for kk=1:length(fields)
        fldname=fields{kk};
        switch lower(fldname)
            case{'width'}
                columns(jj).column.(fldname)=str2num(columns(jj).column.(fldname));
            case{'enable'}
                switch lower(columns(jj).column.(fldname)(1))
                    case{'y','1'}
                        columns(jj).column.(fldname)=1;
                    otherwise
                        columns(jj).column.(fldname)=0;
                end
        end
    end
end


default.style=[];
default.width=50;
default.callback=[];
default.text=[];
default.popuptext=[];
default.enable=1;
default.format=[];
default.type=[];
default.stringlist=[];
default.variable=[];

fields=fieldnames(default);
for ii=1:length(fields)
    for jj=1:length(columns)
        if ~isfield(columns(jj).column,fields{ii})
            columns(jj).column.(fields{ii})=default.(fields{ii});
        end
            
    end
end

%%
function tb=fillMissingTabValues(tb)

default.tab=[];
default.tabstring=[];
default.tabname=[];
default.callback=[];
default.elements=[];
default.enable=1;
default.formodel=[];

fields=fieldnames(default);
for ii=1:length(fields)
    if ~isfield(tb,fields{ii})
        tb.(fields{ii})=default.(fields{ii});
    end
end
