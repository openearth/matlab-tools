function [data,ok]=ImportFromXLS

[filename, pathname, filterindex] = uigetfile('*.xls', 'Select *.xls File');
[num,txt] = xlsread(filename, -1);
nrow=size(num,1);
ok=0;
if nrow>=2
    if length(txt)>0
        if size(num,2)==2 & size(txt,2)==1
            for i=1:nrow
                data{i,1}=datenum(txt{i});
                data{i,2}=num(i,1);
                data{i,3}=num(i,2);
            end
            ok=1;
        end
    else
        if size(num,2)==3
            for i=1:nrow
                data{i,1}=datenum('30-Dec-1899') + num(i,1);
                data{i,2}=num(i,2);
                data{i,3}=num(i,3);
            end
            ok=1;
        end
    end
end
