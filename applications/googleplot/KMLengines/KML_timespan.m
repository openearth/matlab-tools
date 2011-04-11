function varargout = KML_timespan(varargin)
%KML_TIMESPAN   kml string from dates
%
%   timeSpan = KML_timespan(i,'timeIn',ti,'timeOut',to)
%   timeSpan = KML_timespan( ,'timeIn',ti,'timeOut',to)
%
% where the optional i is the index into vectors ti and to.
%
%See also: GooglePlot

   OPT.timeIn       = [];
   OPT.timeOut      = [];
   OPT.dateStrStyle = 'yyyy-mm-ddTHH:MM:SS'; %29;
   
   if nargin==0; varargout = {OPT}; return; end

   if odd(nargin)
      tt = varargin{1};
      varargin = {varargin{2:end}};
   else
       tt = 1;
   end

   OPT = setproperty(OPT,varargin{:});
   
   if  ~isempty(OPT.timeIn)

       if tt > length(OPT.timeIn)
          error('tt to big')
       end
       
       if isnumeric(OPT.timeIn) ; 
           timeIn  = datestr(OPT.timeIn(tt) ,OPT.dateStrStyle);
       elseif iscellstr(OPT.timeIn)
           timeIn  = OPT.timeIn{tt};
       else
           timeIn  = OPT.timeIn(tt,:);
       end
       
       if isnumeric(OPT.timeOut) ; 
           timeOut  = datestr(OPT.timeOut(tt) ,OPT.dateStrStyle);
       elseif iscellstr(OPT.timeOut)
           timeOut  = OPT.timeOut{tt};
       else
           timeOut  = OPT.timeOut(tt,:);
       end

       if ~isempty(OPT.timeOut)
           timeSpan = sprintf([...
               '<TimeSpan>'...
               '<begin>%s</begin>'...% OPT.timeIn
               '<end>%s</end>'...    % OPT.timeOut
               '</TimeSpan>'],...
               timeIn,timeOut);
       else
           timeSpan = sprintf([...
               '<TimeStamp>'...
               '<when>%s</when>'...  % OPT.timeIn
               '</TimeStamp>'],...
               timeIn);
       end
   else
       timeSpan ='';
   end
   
   varargout  = {timeSpan};
