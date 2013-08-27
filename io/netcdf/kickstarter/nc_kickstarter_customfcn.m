function v = nc_kickstarter_customfcn(host, var, m, m_all)

switch m.category
    case 'var'
        switch m.key
            case 'name'
                v = regexprep(var,'\W+','_');
            case 'long_name'
                v = var;
            case 'standard_name'
                names = json.load(urlread(fullfile(host,'json',['standardnames?search=' var])));
                if isempty(names)
                    names = json.load(urlread(fullfile(host,'json','standardnames')));
                end
                
                for i = 1:length(names)
                    fprintf('[%2d] %s [%s]\n',i,names(i).standard_name, names(i).units);
                end
                
                fprintf('\n');
                
                while true
                    name_id = input(sprintf('Choose standard name: ') ,'s');

                    if ~isempty(name_id)
                        if regexp(name_id,'^\d+$')
                            name_id = str2num(name_id);
                            if name_id > 0 && name_id <= length(names)
                                break;
                            end
                        end
                    end
                end
                
                v = names(name_id).standard_name;

                fprintf('\n');
            case 'units'
                m_stdname = get_m(m_all,'var','standard_name');
                names = json.load(urlread(fullfile(host,'json',['standardnames?search=' m_stdname.value])));
                
                v = names(1).units;
        end
end

function mi = get_m(m, cat, key)
    for i = 1:length(m)
        if strcmpi(m(i).category,cat) && strcmpi(m(i).key,key)
            mi = m(i);
            return;
        end
    end
    mi = struct();