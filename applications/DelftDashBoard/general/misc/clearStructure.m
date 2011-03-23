function s=clearStructure(s,i)
f=fieldnames(s(i));
for j=1:length(f)
    s(i).(f{j})=[];
end

