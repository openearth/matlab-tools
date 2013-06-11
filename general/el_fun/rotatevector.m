function [U1, V1] = rotatevector(u0,v0,a);
%ROTATEVECTOR   Rotatation in rad of vectors to other coordinate system.
%
%  [U2 V2] = rotatevector (u1,v1,angle_in_radians)
%
%  Maps vector (u0,v0) given in one cartesian grid 1
%  onto vector (U1,V1) in cartesian grid 2,which is 
%  rotated over angle a with respect to the cartesian
%  grid 1 (angle positive anti-clockwise).
%  u0,v0 should have the same size. 'a' can either
%  be a scalar or have the same size as (u0,v0). Likewise
%  (u0,v0) can be a scaler and a can be an array.
%
%         Y0
%         ^
%         |      X1
%  Y1     |     /   
%     \   |   / \ a = angle (positive anti-clockwise)
%       \ | /    |
% --------+------------------> X0
%        /|\
%      /  |  \
%    /    |    \
%
%  N.B. angle given in radians
%       for degrees: angle*pi/180
%
%  Method:
%  ____        ____
%  Unew =  M * uold;
% 
%  _  _       _                         _     _  _
% | U2 |  =  | cos(angle)   - sin(angle) |   | u1 |;
% |    |     |                           | * |    |
% |_V2_|  =  |_sin(angle)   + cos(angle)_|   |_v1_|; 
% 
% See also: cart2pol, pol2cart, rotatevectord

%13-9-2004

%method = 1;

%if method==1

   U1 = cos(a) .* u0 - sin(a) .* v0;
   V1 = sin(a) .* u0 + cos(a) .* v0;

%elseif method==2

   % slower
   %tic
   %[TH0,R0] = cart2pol(u0,v0);
   % TH1     = + a + TH0 ;
   %[U1 ,V1] = pol2cart(TH1,R0)
   %toc

%elseif method==2

   %% Method below is almost 2 times as slow
   %% - - - - - - - - - - - - - - - - - - - 
   %tic
   %M   = [cos(a),  - sin(a) 
   %       sin(a),  + cos(a)]
   %       
   %UV1 = M*[u0(:) v0(:)];
   %U1  = UV1(1,:)
   %V1  = UV1(2,:)
   %toc

%end
%% EOF
