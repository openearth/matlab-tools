function s=addToStructure(s,i)
f=fieldnames(s(i-1));
for j=1:length(f)
    s(i).(f{j})=[];
end

