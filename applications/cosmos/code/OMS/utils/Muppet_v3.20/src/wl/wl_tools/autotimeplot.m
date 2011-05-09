function autotimeplot(ID,value,time)
%AUTOTIMEPLOT Tool for online visualisation of time series
%   AUTOTIMEPLOT('Name',Value)
%       Creates a time series plot of specified quantity by adding each
%       value to the time series plot. Uses index counter as time indicator
%       on horizontal axes.
%   AUTOTIMEPLOT('Name',Value,Time)
%       Uses specified time instead of index as time indicator on
%       horizontal axes.
%   AUTOTIMEPLOT('clear')
%       Clear all plot data in memory

% (c) 2005 WL | Delft Hydraulics
% created by: dr.ir. H.R.A. Jagers
% creation date: 2005-10-27

% keep plot data between function calls
persistent plots
if isempty(plots) | isequal(lower(ID),'clear')
   plots = cell(0,5);
   if isequal(lower(ID),'clear')
      return
   end
end

% find plot using ID
i = strmatch(ID,plots(:,1),'exact');
if isempty(i)
   i = size(plots,1)+1;
   Ln = makenewplot(ID);
   plots(i,1:5) = {ID Ln [] [] 0};
end

% get data from persistent data set
Ln = plots{i,2};
xdata = plots{i,3};
ydata = plots{i,4};
it = plots{i,5}+1;

% if handle does not exist anymore, create new plot
if ~ishandle(Ln)
   Ln = makenewplot(ID);
   plots{i,2} = Ln;
end

% add buffer space (prevent reallocation of new data space at each time
% step).
if it>length(ydata)
   buffer = repmat(NaN,1,1000);
   xdata = cat(2,xdata,buffer);
   ydata = cat(2,ydata,buffer);
end

% add new data to time series
ydata(it) = value;
if nargin>2
   xdata(it) = time;
else
   xdata(it) = it;
end

% plot data and store data in persistent structure
set(Ln,'xdata',xdata,'ydata',ydata)
plots(i,3:5) = {xdata ydata it};


%--------------------------------------------------------------------------
% Function to create a new plot for a new case.
function Ln=makenewplot(ID)
Fg = figure('name',ID);
Ax = axes('parent',Fg);
set(get(Ax,'title'),'string',ID)
set(get(Ax,'xlabel'),'string','time \rightarrow')
set(get(Ax,'ylabel'),'string','value \rightarrow')
Ln = line('color','b','parent',Ax,'xdata',[],'ydata',[]);
