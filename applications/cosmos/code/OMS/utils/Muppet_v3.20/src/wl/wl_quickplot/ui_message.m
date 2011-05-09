function H = ui_message(Cmd,varargin)
%UI_MESSAGE Graphical display for errors/warnings.
%   UI_MESSAGE shows a resizable dialog for log messages. The log messages
%   persist even when the dialog is temporarily closed.
%
%   UI_MESSAGE('error',ErrorMessage) shows the error message (if necessary
%   it opens the dialog) and produces a beep. An error is separated from
%   the previous message by means of a separator line.
%
%   UI_MESSAGE('warning',WarningMessage) shows the warning but it does not
%   open the dialog if it has been previously closed. A warning is
%   separated from the previous message by means of a separator line.
%
%   UI_MESSAGE('',Message) shows the message but it does not open the
%   dialog if it has been previously closed. The message is separated from
%   previous errors or warnings by means of a separator line, but it is not
%   separated from previous regular messages.
%
%   UI_MESSAGE('max',MaximumNumberOfMessages) changes the maximum number of
%   messages; multiple regular messages (i.e. without separator) count as
%   one. The default value of the maximum number of messages is 10.
%
%   Example
%      ui_message('','First message')
%      ui_message('','Second message continues first')
%      ui_message('warning','A warning separated from regular messages!')
%      ui_message('error','An error too, but forces a show and beep!!')

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
