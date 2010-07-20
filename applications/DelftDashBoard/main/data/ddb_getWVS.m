function [x,y]=ddb_getWVS(dr,xl,yl,res)

ilon1=floor((xl(1)+180)/30)+1;
ilon2=ceil((xl(2)+180)/30)+1;
ilat1=floor((yl(1)+90)/30)+1;
ilat2=ceil((yl(2)+90)/30)+1;

x=[];
y=[];
for i=ilon1:ilon2
    for j=ilat1:ilat2
                
%        fname=[dr 'wvs_' res '_lon' num2str(i,'%0.2i') '_lat' num2str(j,'%0.2i') '.mat'];
        fname=[dr 'wvs.zl' num2str(res,'%0.2i') '.' num2str(i,'%0.2i') '.' num2str(j,'%0.2i') '.nc'];

        if exist(fname,'file')
            xy=nc_varget(fname,'xy');
%            s.Lat=nc_varget(fname,'lat');
%            s=load(fname);
            x=[x xy(1,:) NaN];
            y=[y xy(2,:) NaN];
        end
    end
end
x=double(x);
y=double(y);
