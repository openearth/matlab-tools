function s=appendStructure(s)
n=length(s);
f=fieldnames(s(n));
for j=1:length(f)
    s(n+1).(f{j})=[];
end

