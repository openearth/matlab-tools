function ddb_saveDelft3D_keyWordFile(fname,s)
% Write structure to Delft3D keyword file

fid=fopen(fname,'wt');
fldnames=fieldnames(s);
for i=1:length(fldnames)
    fldname=fldnames{i};
    nf=length(s.(fldname));
    for j=1:nf
        fprintf(fid,'%s\n',['[' fldname ']']);
        keywords=fieldnames(s.(fldname)(j));
        for k=1:length(keywords)
            valstr=[];
            keyw=keywords{k};
            
            if ~isempty(s.(fldname)(j).(keyw))
                
                keywstr=[keyw repmat(' ',1,17-length(keyw))];

                % Value
                if isfield(s.(fldname)(j).(keyw),'type')
                    tp=s.(fldname)(j).(keyw).type;
                else
                    tp='string';
                end
                if ~isempty(s.(fldname)(j).(keyw).value)
                    switch lower(tp)
                        case{'real'}
                            valstr=num2str(s.(fldname)(j).(keyw).value,'%14.7e');
                        case{'integer'}
                            valstr=num2str(s.(fldname)(j).(keyw).value);
                        case{'string'}
                            valstr=s.(fldname)(j).(keyw).value;
                            % Only put # around string in case of keyword
                            % has unit OR comment
                            if ~isempty(findstr(valstr,' ')) && (isfield(s.(fldname)(j).(keyw),'unit') || isfield(s.(fldname)(j).(keyw),'comment'))
                                valstr=['#' valstr '#'];
                            end
                       case{'boolean'}
                           if s.(fldname)(j).(keyw).value
                               valstr='true';
                           else
                               valstr='false';
                           end
                    end
                    valstr=[valstr repmat(' ',1,17-length(valstr))];
                end
                
                if isfield(s.(fldname)(j).(keyw),'unit')
                    unit=['[' s.(fldname)(j).(keyw).unit ']'];
                else
                    unit='';
                end
                unit=[unit repmat(' ',1,12-length(unit))];
                
                
                if isfield(s.(fldname)(j).(keyw),'comment')
                    comment=s.(fldname)(j).(keyw).comment;
                else
                    comment='';
                end
                comment=[comment repmat(' ',1,12-length(comment))];
                
                valstr=[valstr repmat(' ',1,17-length(valstr))];
                str=['   ' keywstr ' = ' valstr ' ' unit ' ' comment];
                fprintf(fid,'%s\n',str);
            end
        end
    end
end
fclose(fid);
