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
      ii = varargin{1};
      varargin = {varargin{2:end}};
   end

   OPT = setproperty(OPT,varargin{:});
   
   if isnumeric(OPT.timeIn) ; OPT.timeIn  = datestr(OPT.timeIn ,OPT.dateStrStyle);end
   if isnumeric(OPT.timeOut); OPT.timeOut = datestr(OPT.timeOut,OPT.dateStrStyle);end
   
   if  ~isempty(OPT.timeIn)
       if length(OPT.timeIn)>1 & odd(nargin)
           tt = ii;
       else
           tt = 1;
       end
       if ~isempty(OPT.timeOut)
           timeSpan = sprintf([...
               '<TimeSpan>'...
               '<begin>%s</begin>'...% OPT.timeIn
               '<end>%s</end>'...    % OPT.timeOut
               '</TimeSpan>'],...
               OPT.timeIn(tt,:),OPT.timeOut(tt,:));
       else
           timeSpan = sprintf([...
               '<TimeStamp>'...
               '<when>%s</when>'...  % OPT.timeIn
               '</TimeStamp>'],...
               OPT.timeIn(tt,:));
       end
   else
       timeSpan ='';
   end
   
   varargout  = {timeSpan};
