function val=getSubFieldValue(s,v)
% Gets variable
val=[];
try
    if length(v)>=7
        if strcmpi(v(1:7),'handles')
            % Old code, used for Delft Dashboard
            v=strrep(v,'handles','s');
            val=eval(v);
        else
            val=s.(v);
        end
    else
        val=s.(v);
    end
end
