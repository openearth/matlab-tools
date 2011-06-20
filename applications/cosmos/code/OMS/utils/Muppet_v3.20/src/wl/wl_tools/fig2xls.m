function fig2xls( figs )

%FIG2XLS Convert MATLAB figures to Excel Charts.
%   FIG2XLS converts all open figures to Excel charts. Only
%   scatter 2-D plots are supported. One chart and one sheet
%   are created per subplot. FIG2XLS(FIGS) converts just 
%   figure numbers FIGS.

% $Id$

% global h; h = [];        % for debugging

if nargin==0,
    figs = get( 0, 'child' );
end

if isempty(figs)
   error('Can''t find any MATLAB figures.')
end

h.App = actxserver( 'Excel.Application' );
set( h.App, 'Visible', 1 );
set( h.App, 'DefaultFilePath', pwd );

h.Wookbooks = get( h.App, 'Workbooks' );
h.myBook = invoke( h.Wookbooks, 'Add' );
h.myCharts = get( h.myBook, 'Charts' );
h.mySheets = get( h.myBook, 'Sheets' );

sheet = 1;
try
  for fig = figs(:)';
  
      ax = fliplr( findobj( fig, 'type', 'axes', 'tag', [] )' );
      for j = 1:length(ax),
          
          % Find Legend for axes, if any
          %
          userdata = [];
          for hleg = findobj( fig, 'type', 'axes', 'tag', 'legend' )',
              ud = get( hleg, 'user' );
              if( ud.PlotHandle == ax(j) ),
                  userdata = ud;
                  break
              end
          end
          
        if sheet > get(h.mySheets,'Count') - get(h.myCharts,'Count'),
           invoke( h.mySheets, 'Add'  );
        end
          
          h.myChart = invoke( h.myCharts, 'Add' );
          try
            invoke( h.myChart, 'Activate' );
            set( h.myChart, 'ChartType', -4169 );      % xlXYScatter
            
            h.mySeriesCollection = get( h.myChart, 'SeriesCollection' );
            try
              for i = 1:double(get( h.mySeriesCollection, 'Count' )),
                  h.mySeries = invoke( h.mySeriesCollection, 'Item', 1 );
                  invoke( h.mySeries, 'Delete' );
              end
              
              org = [3 3];
              
              series = 1;
              for hh = fliplr( findobj( ax(j), 'type', 'line' )' ),
                  
                  x = get( hh, 'xdata' );
                  y = get( hh, 'ydata' );
                  ix = find(isnan(x));
                  iy = find(isnan(y));
                  N = length(y);
                  if length(ix)~=N & length(iy)~=N,
                      
                      % write Y data to sheet
                      %
                      yrange = sprintf('Sheet%d!r%dc%d:r%dc%d', sheet, org+[0 1], org+[N-1 1]  );
                      invoke( h.App, 'goto', yrange );
                      h.Values = h.App.selection;
                      set( h.Values, 'Value', y(:) );
                      if ~isempty(iy),          % Handle NaNs
                          temp = get( h.Values, 'Value' );
                          temp(iy) = {char(0)};
                          set( h.Values, 'Value', temp );
                      end
                      
                      
                      % write x data to sheet
                      %
                      xrange = sprintf('Sheet%d!r%dc%d:r%dc%d', sheet, org, org+[N-1 0]  );
                      invoke( h.App, 'goto', xrange );
                      h.XValues = h.App.selection;
                      set( h.XValues, 'Value', x(:) );
                      if ~isempty(ix),          % handle NaNs
                          temp = get( h.XValues, 'Value' ); % temp is cell array
                          temp(ix) = {char(0)};
                          set( h.XValues, 'Value', temp );
                      end
                      
                      
                      % add a series for the X and Y data
                      %
                      invoke( h.mySeriesCollection, 'Add', h.Values );
                      h.mySeries = invoke( h.mySeriesCollection, 'Item', series );
                      set( h.mySeries, 'XValues', h.XValues );
                      
                      
                      % Line styles for each series
                      %
                      rgb = get( hh, 'Color' ) * 2.^[0 8 16]' * 255;
                      set( h.mySeries.Border, 'Color', rgb );
                      out = xlsLineStyle( get( hh, 'LineStyle' ) );
                      set( h.mySeries.Border, 'LineStyle', out );
                      
                      
                      % Markers for each series
                      %
                      out = get( hh, 'MarkerEdgeColor' );
                      if isnumeric(out),
                          rgb = out * 2.^[0 8 16]' * 255;
                      end
                      set( h.mySeries, 'MarkerForegroundColor', rgb );
                      
                      out = get( hh, 'MarkerFaceColor' );
                      if ischar(out),
                          out = [1 1 1];
                      end
                      rgb = out * 2.^[0 8 16]' * 255;
                      set( h.mySeries, 'MarkerBackgroundColor', rgb );
                      
                      set( h.mySeries, 'MarkerSize', get(hh,'MarkerSize')+2 );
                      out = xlsMarkerStyle( get( hh, 'Marker' ) );
                      set( h.mySeries, 'MarkerStyle', out );
                      
                      
                      % Legend
                      %
                      if isfield( userdata, 'handles' ),
                          i = find( userdata.handles == hh );
                          if ~isempty( i ),
                              set( h.mySeries, 'Name', userdata.lstrings{i} );
                          end
                      end
                      org = org + [0 3];
                      series = series + 1;
                  end
              end
              
              
              % Title
              %
              hl = get(ax(j),'title');
              str = get( hl, 'String' );
              if ~isempty( str ),
                  set( h.myChart, 'HasTitle', 1 );
                  set( h.myChart.ChartTitle, 'Text', str );
                  set( h.myChart.ChartTitle.Font, 'Bold', 1 );
              end
              set( h.myChart.PlotArea.Fill, 'Visible', 0 );
              
              
              % X-axis setup
              %
              sel = get( h.myChart, 'Axes', 1 );
              try
                if strcmp( get( ax(j), 'xscale' ), 'log' ),
                    set( sel, 'ScaleType', -4133 );              % xlScaleLogarithmic
                end
                lim = get( ax(j), 'xlim' );
                set( sel, 'MinimumScale', lim(1) );
                set( sel, 'MaximumScale', lim(2) );
                set( sel, 'MajorTickMark', 2 );                  % xlTickMarkInside
                
                out = get( ax(j), 'xgrid' );
                set( sel, 'HasMajorGridlines', out(2)=='n' );
                if out(2)=='n',
                    out = xlsLineStyle( get( ax(j), 'GridLineStyle' ) );
                    set( sel.MajorGridlines.Border, 'LineStyle', out );
                    set( sel.MajorGridlines.Border, 'Weight', 2 );     % xlThin
                end
                
                set( sel, 'Crosses', -4114 );                 % xlCustom
                set( sel, 'CrossesAt', lim(1) );
                
                
                % X-axis label
                %
                hl = get(ax(j),'xlabel');
                str = get( hl, 'String' );
                if ~isempty( str ),
                    set( sel, 'HasTitle', 1 );
                    set( sel.AxisTitle, 'Caption', str );
                end
              catch
              end
              release( sel )
              
              
              % Y-axis setup
              %
              sel = get( h.myChart, 'Axes', 2 );
              try
                if strcmp( get( ax(j), 'yscale' ), 'log' ),
                    set( sel, 'ScaleType', -4133 );              % xlScaleLogarithmic
                end
                lim = get( ax(j), 'ylim' );
                set( sel, 'MinimumScale', lim(1) );
                set( sel, 'MaximumScale', lim(2) );
                set( sel, 'MajorTickMark', 2 );                  % xlTickMarkInside
                set( sel.MajorGridlines.Border, 'Weight', 2 );      % xlThin
                
                out = get( ax(j), 'ygrid' );
                set( sel, 'HasMajorGridlines', out(2)=='n' );
                if out(2)=='n',
                    out = xlsLineStyle( get( ax(j), 'GridLineStyle' ) );
                    set( sel.MajorGridlines.Border, 'LineStyle', out );
                    set( sel.MajorGridlines.Border, 'Weight', 2 );     % xlThin
                end
                
                set( sel, 'Crosses', -4114 );                 % xlCustom
                set( sel, 'CrossesAt', lim(1) );
                
                
                % Y-axis label
                %
                hl = get(ax(j),'ylabel');
                str = get( hl, 'String' );
                if ~isempty( str ),
                    set( sel, 'HasTitle', 1 );
                    set( sel.AxisTitle, 'Caption', str );
                end
                
                s = get( h.App, 'ActiveSheet' );
                if length(ax)==1,
                    set( s, 'Name', sprintf( 'Sht %d', fig ) );
                    set( h.myChart, 'Name', sprintf( 'Fig %d', fig ) );
                else
                 c = 'a' + length(ax) - j;
                 c = 'a' + j - 1;
                    set( s, 'Name', sprintf( 'Sht %d-%c', fig, c ) );
                    set( h.myChart, 'Name', sprintf( 'Fig %d-%c', fig, c ) );
                end
                
                invoke( h.myChart, 'Activate' );
              catch
              end
              release( sel )
            catch
            end
            release(h.mySeriesCollection);
          catch
          end
          release(h.myChart);
          sheet = sheet + 1;
      end
  end
catch
end

% Release objects
release(h.Wookbooks);
release(h.myBook);
release(h.myCharts);
release(h.mySeries);

delete(h.App);



function out = xlsLineStyle( str )
switch str
case '-',         out = 1;       % xlContinuous 
case ':',         out = -4118;      % xlDot  
case '-.',        out = 4;       % xlDashDot 
case '--',        out = -4115;      % xlDash 
case 'none',      out = -4142;      % xlLineStyleNone 
otherwise,        out = -4142;      % xlLineStyleNone 
end


function out = xlsMarkerStyle( str )
switch str
case 'square',    out = 1;       % xlMarkerStyleSquare
case 'diamond',      out = 2;       % xlMarkerStyleDiamond  
case {'v','^'},      out = 3;       % xlMarkerStyleTriangle 
case '*',         out = 5;       % xlMarkerStyleStar  
case 'o',         out = 8;       % xlMarkerStyleCircle
case '+',         out = 9;       % xlMarkerStylePlus  
case '.',         out = -4118;      % xlMarkerStyleDot   
case 'none',      out = -4142;      % xlMarkerStyleNone  
case 'x',         out = -4168;      % xlMarkerStyleX  
otherwise,        out = -4142;      % xlMarkerStyleNone  
end