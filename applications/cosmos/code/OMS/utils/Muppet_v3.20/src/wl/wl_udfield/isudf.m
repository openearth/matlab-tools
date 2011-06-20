function Output=isudf(Handle,FieldName),
% ISUDF True if field in userdata structure.
%
%    F = ISUDF(H,'PropertyName') returns true if 'PropertyName'
%    is a field in the structure stored in the UserData property
%    of the graphics object with handle H. H can be a vector of
%    handles, in which case ISUDF returns an M-by-1 vector
%    containing a one for each handle for which the UserData
%    property contains a 'PropertyName' field.
%
%    See also RMUDF, GETUDF, SETUDF, WAITFORUDF, ISFIELD.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

Value=logical(zeros(length(Handle(:)),1));
for H=1:length(Handle(:)),
  UserData=get(Handle(H),'userdata');
  Output(H)=isfield(UserData,FieldName);
end;