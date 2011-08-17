function ah = rws_createFixedMapsOnAxes(ah, urls, varargin)
error('This function is deprecated in favour of grid_orth_createFixedMapsOnFigure   ')
%rws_createFixedMapsOnFigure   .
%
%See also: 

%% make the axes to use the current one
axes(ah);

%% for each available url get the actual_range and creat a patch
for i = 1:length(urls)
    x_range = nc_getvarinfo(url, 'x');
    y_range = nc_getvarinfo(url, 'y');
    
    if any(ismember({y_range.Attribute.Name}, 'actual_range')) && any(ismember({x_range.Attribute.Name}, 'actual_range'))

        x_range = str2num(x_range.Attribute(ismember({x_range.Attribute.Name}, 'actual_range')).Value); %#ok<*ST2NM>
        y_range = str2num(y_range.Attribute(ismember({y_range.Attribute.Name}, 'actual_range')).Value);

        ph = patch([x_range(1) x_range(2) x_range(2) x_range(1) x_range(1)], ...
                   [y_range(1) y_range(1) y_range(2) y_range(2) y_range(1)], 'r');

        drawnow
    end
    
    set(ph,'tag',urls{i});
end
box on
