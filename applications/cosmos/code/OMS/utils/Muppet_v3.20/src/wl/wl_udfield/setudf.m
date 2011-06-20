function setudf(Handle,FieldName,Value),
% SETUDF Set field in a userdata structure.
%
%    SETUDF(H,'PropertyName',PropertyValue) sets the value of
%    the specified field 'PropertyName' in the structure stored
%    in the UserData property of the graphics object with handle H.
%    H can be a vector of handles, in which case SETUDF sets the
%    properties' values for all the objects.
%
%    See also GETUDF, ISUDF, RMUDF, WAITFORUDF, SET.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

for H=1:length(Handle(:)),
  UserData=get(Handle(H),'userdata');
  if ~isstruct(UserData),
    if ~isempty(UserData),
      error('nonstructure userdata.');
    end;
    UserData=[];
  end;
  UserData=setfield(UserData,FieldName,Value);
  set(Handle(H),'userdata',UserData);
end;
