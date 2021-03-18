function x1=hit_and_mis(f,x)

fmin=min(f);
fmax=max(f);
xmin=min(x);
xmax=max(x);

ok=0;
while ok==0
    y=rand(2,1);
    x1=(xmax-xmin)*y(1)+xmin;
    f1=(fmax-fmin)*y(2)+fmin;
    try
        f2=interp1(x,f,x1);
        if f1<=f2
            ok=1;
        end
    catch
        x1=x;
        ok=1;
    end
end