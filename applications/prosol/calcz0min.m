function [ust,z0] = calcz0min(H,U)
   nu = 1e-6;
   karman = 0.4;
   eps      = 1e-10;
   acc      = 1;
   z1       = nu/(9*0.001*U);
   while acc > eps
       z0   = z1;
       f    = H/karman*(log(H)-log(z0)-1)  +(1/karman-9*U*H/nu)*z0;
       dfdz0= H/karman*(-1/z0)             +(1/karman-9*U*H/nu);
       z1   = z0 - f/dfdz0;
       acc  = abs(z1-z0);
   end
   z0;
   ust = nu/(9*z0);
