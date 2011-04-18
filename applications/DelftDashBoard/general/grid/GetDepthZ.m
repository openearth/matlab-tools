function zz=getDepthZ(z,dpsopt)
% Return matrix of depths in cell centres
% dpsopt can be dp, min, max or mean

zz=zeros(size(z));
zz(zz==0)=NaN;

z1=z(1:end-1,1:end-1);
z2=z(2:end  ,1:end-1);
z3=z(2:end  ,2:end  );
z4=z(1:end-1,2:end  );

switch lower(dpsopt)
    case{'dp'}
        zz=z;
    case{'min'}
        zz0=max(z1,z2);
        zz0=max(zz0,z3);
        zz0=max(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'max'}
        zz0=min(z1,z2);
        zz0=min(zz0,z3);
        zz0=min(zz0,z4);
        zz(2:end,2:end)=zz0;
    case{'mean'}
        zz(2:end,2:end)=(z1+z2+z3+z4)/4;
end
