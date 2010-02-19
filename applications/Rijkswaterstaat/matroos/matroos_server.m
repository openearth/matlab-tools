function url = matroos_server(varargin)
%MATROOS_SERVER     retrieve url of a Rijkswaterstaat MATROOS database
%
%   url = matroos_server()
%
% returns matroos base url incl user:password authentication, e.g.
%
%    http://username:password@matroos.deltares.nl
%
% Adapt this function to contain your own server & username and password
% and place it in your local Matlab path.
%
%See also: MATROOS

   user   = '???????????????????';
   passwd = '???????????????????';
   url    = 'matroos.deltares.nl';
   
   [user, passwd, url]=matroos_deltares();

%% urlread_basicauth & matroos_urlread handle the any special character (like @) in username or password

   url      = ['http://',user,':',passwd,'@',url];
   
% EOF   
