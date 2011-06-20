function waitforudf(Handle,FieldName,WaitforValue),
% WAITFORUDF Block execution and wait for change of UserData field.
%
%    WAITFORUDF(H,'PropertyName'), returns when the value of
%    'PropertyName' for the graphics object handle changes.
%    If 'PropertyName' is not a valid field of the structure
%    stored in the userdata property of the object, or if the
%    handle does not exist, waitfor returns immediately without
%    processing any events.
% 
%    WAITFORUDF(H,'PropertyName',PropertyValue), returns when
%    the value of the 'PropertyName' field of the userdata of
%    the graphics object handle changes to PropertyValue. If
%    'PropertyName' is set to PropertyValue, if 'PropertyName'
%    is not a valid field of the structure stored in the userdata
%    property of the object, or if the handle does not exist,
%    waitfor returns immediately without processing any events.
% 
%    While waitforudf blocks an execution stream, it processes
%    events as would drawnow, allowing callbacks to execute. Nested
%    calls to waitforudf are supported, and earlier calls to
%    waitforudf will not return until all later calls have returned,
%    even if the condition upon which the earlier call is blocking
%    has been met.
% 
%    See also SETUDF, WAITFOR.

% Copyright (c) 1999, H.R.A. Jagers, WL | delft hydraulics, The Netherlands

if nargin<2,
  error('Not enough input arguments.');
end;
if ~ishandle(Handle),
  return;
end;
UserData=get(Handle,'userdata');
if ~isfield(UserData,FieldName),
  return;
else,
  StartValue=getfield(UserData,FieldName);
  if (nargin==3) & isequal(StartValue,WaitforValue),
    return;
  end;
  while 1,
    waitfor(Handle,'userdata'); % waitfor a change of the userdata field
    if ~ishandle(Handle), % graphics object deleted
      return;
    end;
    UserData=get(Handle,'userdata');
    if ~isfield(UserData,FieldName), % field deleted
      return;
    else,
      CurrentValue=getfield(UserData,FieldName);
      if (nargin==2), % no WaitforValue specified
        if ~isequal(CurrentValue,StartValue), % changed
          return;
        end;
      elseif isequal(CurrentValue,WaitforValue), % changed and equal to WaitforValue
        return;
      end;
    end;
  end;
end;