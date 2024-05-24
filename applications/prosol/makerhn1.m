function [d] = makerhn1(karman,ust,fs,R);   
    d     = -fs.^2/R/karman/ust;
    %Boundary conditions
    d(end)= 0;         %No gradient in velocity near surface.
    d(1)  = 0;         %Near bed u = 0 at z0.
