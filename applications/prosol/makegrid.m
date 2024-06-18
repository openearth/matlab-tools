function z = makegrid(J,gridtype,z0,H);
    %Generate grid on interval z0/H:1;
    if (gridtype ==0)
        z=z0/H:(1-z0/H)/J:1;

    elseif (gridtype ==1)%Random grid.
        z = [0,cumsum(rand(1,J))];z = z./max(z);z = z*(1-z0/H);z = z + z0/H;

    elseif (gridtype ==2)
        z=z0/H:(1-2*z0/H)/J:1-z0/H;
        teta = 0.5;
        x1 = log(max(z(z<teta)));
        x0 = log(z0/H);
        %
        xn = length(z(z<teta))-1;
        xd = (x1-x0)/xn;
        z(z<teta)     = exp(x0:xd:x1);
        z(end-xn:end) = -fliplr(exp(x0:xd:x1)) + 1+z0/H;  %WO 23.01.09
    elseif (gridtype ==3)
        J2 = floor(J/3);
        J3 = J-2*J2;
        z=[z0:z0:(J2-1)*z0, (J2)*z0:(H-2*J2*z0)/J3:H-J2*z0 , H-(J2-1)*z0:z0:H]; %    z0/H:(1-2*z0/H)/J:1-z0/H;
        if length(z) > floor(H/z0);
            error('grid cannot be created')
        end
    elseif (gridtype ==4)
        z = z0/H:(1-2*z0/H)/J:1-z0/H;
        z = cumsum(z.*(1-z));
        z = z-min(z);
        z = z/max(z);
        z = (1-z0/H).*z + z0/H;
    elseif (gridtype ==5)
        z=1:J+1; %z0/H:(1-2*z0/H)/J:1-z0/H;
        teta = 0.5;
        x1 = log(0.5+z0/H/2);
        x0 = log(z0/H);
        %
        xn  = (J+1)/2;
%        xn2 = J+1 - xn;
        xd = (x1-x0)/xn;
        %xd2 = (x1-x0)/xn2;
        z(1:floor(xn)) = exp(x0:xd:x1-xd);
        z(end-floor(xn)-1:end) = -fliplr(exp(x0:xd:x1+xd)) + 1+z0/H;  %WO 23.01.09
    elseif (gridtype == 6)
        pow = 6;
        xn = 0:1/J:1;
        xd = 2*xn(xn<=0.5);
        xu = 2*(1-xn(xn>0.5));
        zd = xd.^pow/2;
        zu = 1-xu.^pow/2;
        z = [zd,zu];
        z = z*(H-z0)/H+z0/H;
    elseif (gridtype ==7)
        x0 = log(z0/H);
        x1 = log(0.5);
        xd = (x1-x0)/J*2;
        zd = exp(x0:xd:x1);
        zu = 1-(fliplr(zd)-z0/H)/(0.5-z0/H)*0.5;
        if zd(end) == zu(1);
           z = [zd(1:end-1),zu];
        else
           z = [zd,zu];            
        end
    end
    %Multiply by waterdepth
    z = z*H;
end