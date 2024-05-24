function [d] = makerhn2(Sn0,g,J,karman,ust);   
    d     = g*Sn0*ones(1,J+1)/karman/ust;
    %Boundary conditions
    d(end)= 0;         %No gradient in velocity near surface.
    d(1)  = 0;         %Near bed u = 0 at z0.
