function m=struc2mat(s,field)
m=[];
k=0;
try
    if isfield(s,field)
        for i=1:length(s)
            v=s(i).(field);
            for j=1:length(v)
                k=k+1;
                m(k)=s(i).(field)(j);
            end
        end
    end
end
