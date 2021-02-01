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
end

%%
function S=timestep(S)

S.it=S.it+1;
amp=S.rhow; % use water density for this...
for j=1:length(S.shoreline.x)
    S.shoreline.x(j)=S.shoreline.x0(j)+cos(S.it/10-S.shoreline.phase(j))*amp;
    S.shoreline.y(j)=S.shoreline.y0(j)+sin(S.it/10-S.shoreline.phase(j))*amp;
end

%%
function S=finalize(S)
% Set x and y back to original values
S.shoreline.x=S.shoreline.x0;
S.shoreline.y=S.shoreline.y0;
