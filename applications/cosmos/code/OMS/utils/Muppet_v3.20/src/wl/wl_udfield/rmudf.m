function rmudf(Handle,FieldName),
% RMUDF Remove field in a userdata structure.
%
%    RMUDF(H,'PropertyName') removes the specified field
%    'PropertyName' from the structure stored in the UserData
%    property of the graphics object with handle H. H can be a
%    vector of handles, in which case RMUDF removes the field
%    from all the UserData structures.
%
%    See also ISUDF, GETUDF, SETUDF, WAITFORUDF, RMFIELD.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

for H=1:length(Handle(:)),
  UserData=get(Handle(H),'userdata');
  if isfield(UserData,FieldName),
    UserData=rmfield(UserData,FieldName);
  end;
  set(Handle(H),'userdata',UserData);
end;