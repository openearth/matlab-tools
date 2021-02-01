function S=ShorelineS(S,opt)

switch lower(opt)
    case{'initialize'}
        S=initialize(S);
    case{'timestep'}
        S=timestep(S);
    case{'finalize'}
        S=finalize(S);
end


function S=initialize(S)

S.nt=round(S.tstop-S.tstart);
S.it=0;
x0=S.shoreline.x;
y0=S.shoreline.y;
S.shoreline.x0=x0;
S.shoreline.y0=y0;
for j=1:length(x0)
    S.shoreline.phase(j)=2*pi*rand(1);
    S.shoreline.omega(j)=0.1*rand(1);
end
S.shoreline.u=zeros(size(x0));
S.shoreline.v=zeros(size(x0));
S.shoreline.au=zeros(size(x0));
S.shoreline.av=zeros(size(x0));

%%
function S=timestep(S)

S.it=S.it+1;
amp=S.rhow; % use water density for this...
switch S.num_opt
    case{'circle'}
        for j=1:length(S.shoreline.x)
            S.shoreline.x(j)=S.shoreline.x0(j)+cos(S.it*S.shoreline.omega(j)-S.shoreline.phase(j))*amp;
            S.shoreline.y(j)=S.shoreline.y0(j)+sin(S.it*S.shoreline.omega(j)-S.shoreline.phase(j))*amp;
        end
    case{'up_and_down'}
        for j=1:length(S.shoreline.x)
            S.shoreline.y(j)=S.shoreline.y0(j)+sin(S.it*S.shoreline.omega(j)-S.shoreline.phase(j))*amp;
        end
    case{'left_to_right'}
        m=1e3;
        for j=1:length(S.shoreline.x)-1
            F(j)=sqrt((S.shoreline.x(j+1)-S.shoreline.x(j)).^2+(S.shoreline.y(j+1)-S.shoreline.y(j)).^2);
            phi(j)=atan2((S.shoreline.y(j+1)-S.shoreline.y(j)),(S.shoreline.x(j+1)-S.shoreline.x(j)));
        end
        for j=1:length(S.shoreline.x)
            fx=0;
            fy=0;
            if j>1
                fx=fx-cos(phi(j-1))*F(j-1);
                fy=fy-sin(phi(j-1))*F(j-1);                
            end
            if j<length(S.shoreline.x)
                fx=fx+cos(phi(j))*F(j);
                fy=fy+sin(phi(j))*F(j);                
            end
            au=fx/m;
            av=fy/m;
            S.shoreline.u(j)=S.shoreline.u(j)+au;
            S.shoreline.v(j)=S.shoreline.v(j)+av;
            S.shoreline.x(j)=S.shoreline.x(j)+S.shoreline.u(j);
            S.shoreline.y(j)=S.shoreline.y(j)+S.shoreline.v(j);
        end
end

%%
function S=finalize(S)
% Set x and y back to original values
S.shoreline.x=S.shoreline.x0;
S.shoreline.y=S.shoreline.y0;
