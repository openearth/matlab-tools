function varargout  = load_template(fname,varargin)
%LOAD_TEMPLATE   template for making a function that rads/loads a file
%
% [DATA,<iostat>] = load_template(filename)
% where <iostat> is optional
%
% Opens and closes file for ASCII reading.
% The actual reading has stiull to be implemented.
%
% Cathes the following errors:
% - error finding: iostat=-1
% - error opening: iostat=-2
% - error reading: iostat=-3
%
% and returns the following fields:
% -  filename: 'foo.txt'
% -  filedate: '23-May-2006 10:56:48'
% - filebytes: 2652688
% -  iomethod: ''
% -   read_at: '28-Jul-2006 13:20:55'
% -  iostatus: 1

% G.J. de Boer, 28-Jul-2006 13:20:55
   
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   DAT.filename     = fname;
   iostat           = 1;
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fname])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      DAT.filedate  = tmp.date;
      DAT.filebytes = tmp.bytes;
   
      filenameshort = filename(fname);
      
      fid       = fopen  (fname,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fname])
         else
            iostat = -2;
         end
      
      elseif fid > 2
      
         try

            %% Implement actual reading of the ASCII file here
            %--------------------------------
          
         catch
          
            if nargout==1
               error(['Error reading file: ',fname])
            else
               iostat = -3;
            end      
         
         end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
   DAT.iomethod = '';
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;

   if nargout==1
      varargout  = {DAT};
   elseif nargout==2
      varargout  = {DAT,iostat};
   end
