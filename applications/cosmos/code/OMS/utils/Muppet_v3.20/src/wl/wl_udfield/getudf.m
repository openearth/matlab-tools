function Value=getudf(Handle,FieldName),
%GETUDF Get the value of the field in a userdata structure.
%
%    V = GETUDF(H,'PropertyName') returns the value of the specified
%    field 'PropertyName' in the structure stored in the UserData
%    property of the graphics object with handle H. If H is a
%    vector of handles, then getudf will return an M-by-1 cell array
%    of values where M is equal to length(H).
%
%    See also SETUDF, ISUDF, RMUDF, WAITFORUDF, GET.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

Value=cell(length(Handle(:)),1);
for H=1:length(Handle(:)),
  UserData=get(Handle(H),'userdata');
  if isfield(UserData,FieldName),
    Value{H}=getfield(UserData,FieldName);
  else,
    error(['invalid property: ' FieldName '.']);
    Value{H}=[];
  end;
end;

if length(Handle)==1,
  Value=Value{1};
end;