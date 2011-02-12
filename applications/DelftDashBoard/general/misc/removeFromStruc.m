function str1=removeFromStruc(str0,iac)
k=0;
for i=1:length(str0)
    if i~=iac
        k=k+1;
        str1(k)=str0(i);
    end
end
