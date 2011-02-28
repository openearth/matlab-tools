function str=deblank2(str)
% Removes starting and trailing spaces from string

spaces=str==' ';
ifirstchar=[];
for i=1:length(spaces)
    if ~spaces(i)
        ifirstchar=i;
        break
    end
end
if ~isempty(ifirstchar)
    str=str(ifirstchar:end);
end
str=deblank(str);
