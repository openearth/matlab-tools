function [d] = makerhn4(karman,ust,U,N,anglat);
    omega=7.272e-5; %m/s
    f = - 2 * omega *sin(anglat); 
    d     = f*ones(1,N+1)*U/karman/ust;
    %Boundary conditions
    d(end)= 0;         %No gradient in velocity near surface.
    d(1)  = 0;         %Near bed u = 0 at z0.
