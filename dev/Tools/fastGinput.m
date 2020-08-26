function [out1,out2,out3] = fastGinput(arg1)
% slimmed down fast version of ginput
if nargin==1
    N = arg1;
else
    N = 999;
end
out1 = nan(N,1);
out2 = nan(N,1);
out3 = nan(N,1);
zoom off;
pan off;
hObject = gcf;
set(hObject,'pointer','crosshair');
i = 0;
while 1
    key = waitforbuttonpress;
    if key ==0
        i  = i+1;        
        button = get(hObject, 'SelectionType');
        if strcmp(button,'normal')
            out3(i) = 1;
        elseif strcmp(button,'alt')
            out3(i) = 2;  
        end

        crd = get (gca, 'CurrentPoint');
        out2 (i) = crd(1,2);
        out1 (i) = crd(1,1);
        if i>=N
            break
        end
    else
        break;
    end
end
N = i;
out1(N+1:end,:)= [];
out2(N+1:end,:)= [];
out3(N+1:end,:)= [];
set(hObject,'pointer','arrow');
end