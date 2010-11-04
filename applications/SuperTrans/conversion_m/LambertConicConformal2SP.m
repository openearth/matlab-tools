function [x2,y2]=lcc2sp(x1,y1,a,finv,lonf,fe,latf,fn,lat1,lat2,iopt)

n1=length(x1)

f=1/finv
e2=2*f-f^2
e=sqrt(e2)

if abs(0.5*pi-latf)<0.001
    latf = 0.5*pi
end

m1 = cos(lat1)/(1.0 - e^2 * (sin(lat1))^2)^0.5
m2 = cos(lat2)/(1.0 - e^2 * (sin(lat2))^2)^0.5
t1 = tan(pi/4.0 - lat1/2.0)/((1.0 - e * sin(lat1))/(1.0 + e * sin(lat1)))^(e/2.0)
t2 = tan(pi/4.0 - lat2/2.0)/((1.0 - e * sin(lat2))/(1.0 + e * sin(lat2)))^(e/2.0)
tf = tan(pi/4.0 - latf/2.0)/((1.0 - e * sin(latf))/(1.0 + e * sin(latf)))^(e/2.0)

n = (log(m1) - log(m2))/(log(t1) - log(t2))
f = m1/(n*t1^n)


if (abs(pi/4.0-latf/2.0)<0.001)
    tf = 0.0
end

rf = a*f*tf^n

for i=1:n1
    if iopt==1
        
        %           geo2xy
        
        lon=x1(i)
        lat=y1(i)
        
        t  = tan(pi/4.0 - lat /2.0)/((1.0 - e * sin(lat ))/(1.0 + e * sin(lat )))^(e/2.0)
        r  = a*f*t^n
        
        theta = n*(lon - lonf)
        
        x2(i) = fe + r*sin(theta)
        y2(i) = fn + rf - r*cos(theta)
        
    else
        
        %           xy2geo
        
        east=x1(i)
        north=y1(i)
        
        rac = ((east - fe)^2 + (rf - (north - fn))^2)^0.5
        
        
        if n < 0
            rac=-rac
        end
        
        tac = (rac/(a*f))^(1/n)
        thetaac = atan((east - fe)/(rf - (north - fn)))

        % Initial guess for latitude        
        y2(i) = 0.5*pi-2*atan(tac);

        % And now iterate
        for k=1:4
            y2(i) = pi/2.0 - 2.0*atan(tac*((1.0 - e*sin(y2(i)))/(1.0 + e*sin(y2(i))))^(e/2.0))
        end
        
        x2(i) = thetaac/n + lonf
        
    end
end


