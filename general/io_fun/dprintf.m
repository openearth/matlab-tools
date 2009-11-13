function dprintf(debug,varargin)
%DPRINTF   fprintf with option to write to screen
%
%   dprintf(fid,text)
%
% writes text and '\n' to fid, and to screen when fid=0,
% as used to work with FPRITNF in earlier Matlab versions.
%
% Useful for debug purposes: messages can be written to a log file or screen.
%
% Example:
%
%   dprintf(0,'read such and so succesfully')
%
%See also: FPRINTF, WARNING, DISP

   if debug
       fprintf(debug,varargin{:});
       fprinteol(debug);
   else
       disp(varargin{:});
   end

%% EOF
