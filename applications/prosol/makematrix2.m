function [B,ddz] = makematrix2(z,H,nu_num);
    J = length(z)-1;
    dz = [1,diff(z)];
    ddz = diff(z)';
    f = (-2*z/H+1);  
    a  = max(z.*(H-z)/H,nu_num); 

    
    % f = 0.5./sqrt(z/H);
   % a = max(sqrt(z/H),nu_num);%max(z.^4-2*z.^3+z.^2,nu_num);
    %build advective matrix
    F = spalloc(J+1,J+1,3*(J+1));
    B = spalloc(J+1,J+1,3*(J+1));    
    
    F(1,1) = 1/dz(1);
    for i=2:J+1;
       F(i,i)  = f(i)/dz(i);
       F(i,i-1)= -f(i)/dz(i);
    end
    %build diffusive matrix
    A = spalloc(J+1,J+1,3*(J+1));
    for i=2:J;
        A(i,i-1)= a(i)./(0.5*(dz(i+1)+dz(i)))*1/dz(i);
        A(i,i)  =-a(i)./(0.5*(dz(i+1)+dz(i)))*(1/dz(i)+1/dz(i+1));
        A(i,i+1)= a(i)./(0.5*(dz(i+1)+dz(i)))*1/dz(i+1);
    end
%    A = sparse(A);
%    F = sparse(F);
    B = A + F;
    B(1,:) = 0; %Boundary conditions
    B(1,1) = 1;
    B = sparse(B);
%    condest(B)