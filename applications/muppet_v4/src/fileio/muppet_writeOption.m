function muppet_writeOption(info,data,fid,nindent,varargin)

keywordlength=25;

if ~isempty(varargin)
    keywordlength=varargin{1};
end

% Only write option if mup keyword is given
if ~isfield(info,'keyword')    
    return
end

if ~isfield(info,'variable')
    % No specific variable given, assume it is the same as the name of
    % this option
    info.variable=info.name;
end

if isfield(info,'write')
    if strcmpi(info.write,'0')
        return
    end
end

iok=1;
% Look for checks
if isfield(info,'check')
    if isfield(info,'checkfor')
        checkfor=info.checkfor;
    else
        checkfor='all';
    end
    switch checkfor
        case{'all'}
            iok=1;
        case{'none'}
            iok=0;
        case{'any'}
    end
    % Run checks
    for icheck=1:length(info.check)
        if isfield(info.check(icheck).check,'variable')
            % Take variable
            checkvariable=info.check(icheck).check.variable;
        else
            % No variable given, take variable from option itself
            checkvariable=info.variable;
        end
        if isfield(info.check(icheck).check,'value')
            % Take value
            checkvalue=info.check(icheck).check.value;
        else
            % No value given, take default from option
            checkvalue=info.default;
        end
        % Always an operator
        operator=info.check(icheck).check.operator;
        % Evaluate variable
        
        checkvariable=eval(['data.' checkvariable]);
        if ischar(checkvariable)
            % Character
            switch operator
                case{'eq'}
                    if ~strcmpi(checkvariable,checkvalue)
                        iok=0;
                    end
                case{'ne'}
                    if strcmpi(checkvariable,checkvalue)
                        iok=0;
                    end
            end
        else
            % Numeric
            checkvalue=str2double(checkvalue);
            switch operator
                case{'eq'}
                    if checkvariable~=checkvalue
                        iok=0;
                    end
                case{'ne'}
                    if checkvariable==checkvalue
                        iok=0;
                    end
                case{'gt'}
                    if checkvariable<=checkvalue
                        iok=0;
                    end
                case{'ge'}
                    if checkvariable<checkvalue
                        iok=0;
                    end
                case{'lt'}
                    if checkvariable>=checkvalue
                        iok=0;
                    end
                case{'le'}
                    if checkvariable>checkvalue
                        iok=0;
                    end
            end
        end
    end
end

if ~iok
    return
end

%% Evaluate variable
if isfield(info,'variable')
    varname=info.variable;
else
    varname=info.name;
end
varname=deblank(varname);

% Check for multiple values (vector array)
iblank=find(varname==' ');
var=[];
if ~isempty(iblank)
    nblank=length(iblank)+1;
    iblank(end+1)=length(varname)+1;
    varstr=varname(1:iblank(1)-1);
    var(1)=eval(['data.' varstr]);
    for jj=2:nblank
        varstr=varname(iblank(jj-1)+1:iblank(jj)-1);
        var(jj)=eval(['data.' varstr]);
    end
else    
    try
        var=eval(['data.' varname]);
    catch
        return
    end
end

% Write option
if ~isempty(var)
    if ~isfield(info,'type')
        info.type='string';
    end
    iwrite=1;
    switch lower(info.type)
        case{'real'}
            varstring=deblank(num2str(var));
        case{'realorstring'}
            if ischar(var)
                varstring=['"' var '"'];
            else
                varstring=deblank(num2str(var));
            end
        case{'int'}
            varstring=num2str(var);
        case{'date'}
            varstring=datestr(var,'yyyymmdd');
        case{'datetime'}
            varstring=datestr(var,'yyyymmdd HHMMSS');
        case{'time'}
            varstring=datestr(var,'HHMMSS');
        case{'boolean','booleanorreal'}
            if var
                varstring='yes';
            else
                varstring='no';
            end
        case{'indexstring'}
            if var==0
                iwrite=0;
            end
            varstring=num2str(var);
        case{'filename'}
            if ~isempty(data.filename)
                [pathname,filename,ext]=fileparts(data.filename);
                currentpath=pwd;
                if isempty(pathname)
                    pathname='';
                else
                    if strcmpi(pathname(end),'\')
                        pathname=pathname(1:end-1);
                    end
                end
                if strcmp(currentpath,pathname)
                    pathname='';
                end
                varstring=['"' pathname filename ext '"'];
            else
                iwrite=0;
            end
        case{'multilinetext'}
            nlines=size(var,1);
            var0=var;
            var=deblank(var0(1,:));
            for iv=2:nlines
                var=[var ';' deblank(var0(iv,:))];
            end
            varstring=['"' var '"'];
            
        otherwise
            varstring=['"' var '"'];
    end
    if iwrite
        txt=[repmat(' ',1,nindent) info.keyword repmat(' ',1,max(keywordlength-length(info.keyword),1)) varstring];
        fprintf(fid,'%s \n',txt);
    end
end

