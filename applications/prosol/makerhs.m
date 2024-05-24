function [c] = makerhs(Ss0,g,H,J,karman,ust,U);   
    c     = (g)*Ss0*ones(1,J+1)/(karman*ust);
    %Boundary conditions
    c(end)= 0;         %No gradient in velocity near surface.
    c(1)  = 0;         %Near bed u = 0 at z0.
