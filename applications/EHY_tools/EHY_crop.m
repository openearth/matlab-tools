function EHY_crop(file)
img=imread(file);

dw=2;

sumImg=sum(img,3);
AA=double(sumImg~=3*255);
cols=sum(AA,1);
rows=sum(AA,2);

m_min=max([find(rows~=0,1,'first')-dw 1]);
m_max=min([find(rows ~=0,1,'last')+dw size(img,1)]);

n_min=max([find(cols~=0,1,'first')-dw 1]);
n_max=min([find(cols ~=0,1,'last')+dw size(img,2)]);

imwrite(img(m_min:m_max,n_min:n_max,:),file)

    