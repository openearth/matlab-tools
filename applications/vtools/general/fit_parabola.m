
clear

%%

y1=2.5; %maximum power of the transformer [kW]
xm=14; %time at which the maximum sun occurs [h]
x0=8; %time at which the energy starts being produced [h]
x1=12; %time at which the maximum power is reached [h]

%%

x2=x1+(xm-x1)*2;
A=(x0-xm)^2-(x1-xm)^2;
alpha=-y1/A;
beta=-2*xm*alpha;
ym=-alpha*(x0-xm)^2; %maximum power if unlimited by transformer [kW]
gamma=ym+alpha*xm^2;

Fy=@(x)alpha.*x.^2+beta.*x+gamma; %power unlimited by transformer [kW]
Fyint=@(x)alpha/3.*x^3+beta/2*x^2+gamma*x; %integral of the power 

ypanels=Fyint(x2)-Fyint(x1);
%using trapezium
xt=x1:0.1:x2;
yt=alpha.*xt.^2+beta.*xt+gamma;
ypt=trapz(xt,yt);

ytransformer=y1*(x2-x1);

ylost=ypanels-ytransformer;
ymaxl=ym*(x2-x1);

%%

x=6:0.5:18; %time vector [h]


figure
hold on
plot(x,Fy(x))

