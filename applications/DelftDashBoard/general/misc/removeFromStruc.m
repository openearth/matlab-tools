function str1=removeFromStruc(str0,iac)
k=0;
str1=[];
for i=1:length(str0)
    if i~=iac
        k=k+1;
        fldnames=fieldnames(str0(i));
        for j=1:length(fldnames)
            str1(k).(fldnames{j})=str0(i).(fldnames{j});
        end
    end
end
