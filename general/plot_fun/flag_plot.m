function varargout = flag_plot(X,Y,varargin)
%
%
%
%
%                ,--- flag_field_relative_width
%                |
%                |
%                v
%    ___        ___       ___
%   |   |--___--   --___--   --.
%   |   |                     / <--- flag_field_relative_height
%   |   |                    /
%   |   |      FLAG-FIELD   {<------ flag_field_relative_cut_out   
%   |   |                    \      (relative to flag field width)
%   |   |       ___ ^     ___ \ 
%   |   |--___--   -|___--  ^--'
%   |   |           |       |
%   |   |           |       '--- flag_field_type (type of flag)
%   | F |           |
%   | L |           '--- flag_field_plot_color (red by default)
%   | A |           
%   | G |
%   |   |
%   |   | <--- flag_pole_height (variables are relative to this height)
%   |   |  
%   | <-|------ flag_pole_plot_color (brown by default)
%   |   |  
%   | P |
%   | O |
%   | L |---__  
%   | E |     \  <--- flag_rotation (0 degrees is vertical)
%   |   |      |       
% __|   |__    V
%     ^
%     |
%     |--- provided X,Y position(s)
%     |
%     '--- flag_pole_relative_width
%
%

% Flag-pole:
OPT.flag_pole_height            = 1;
OPT.flag_pole_relative_width    = 0.02;

% Flag-field
OPT.flag_field_relative_height  = 0.2;
OPT.flag_field_relative_width   = 0.3;
OPT.flag_field_relative_cut_out = 0.3;
OPT.flag_field_type             = 'square_wave';

% Plotting flag-pole:
OPT.flag_pole_plot_color        = [139 69 19]./255;

% Plotting flag-field:
OPT.flag_field_plot_color       = 'r';

% Plotting general:
OPT.plot_to_figure              = true;
OPT.axis_equal                  = true;
OPT.flag_rotation               = 0;
OPT.flag_mirror                 = false;

% Patch general (no checks)
OPT.LineWidth                   = 0.5;
OPT.EdgeColor                   = 'k';
OPT.FaceAlpha                   = 1.0;

if nargin == 0 || nargin == 1
    varargout{1} = OPT;
    % Plot the different flags incl. naming
    flag_type_names = {'triangle','triangle_up','triangle_down','square','square_cut_in','square_cut_out','triangle_wave','square_wave','square_wave_cut_in'};
    subplot_size    = [3 3]; cols = jet(size(flag_type_names,2));
    fig = figure; set(fig,'color','w','inverthardcopy','off','ToolBar','none','DockControls','off','MenuBar','none','Resize','off','NumberTitle','off','Name','Flag types for the function ''plot_flag''');
    axes('position',[0 0 1 1]); axis off;
    text(0.5,1,'Types of flags available for the function flag_plot','fontweight','bold','horizontalalignment','center','verticalalignment','top','interpreter','none');
    for ii = 1:size(flag_type_names,2)
        axes('position',[mod(ii-1,3)*1/3 floor((ii-1)/3).*1/3 1/3 0.3]); axis off;
        flag_plot(0,0,'flag_field_type',flag_type_names{1,ii},'flag_field_plot_color',cols(ii,:),'flag_pole_relative_width',0.05,'flag_field_relative_width',0.5,'flag_field_relative_height',0.4,'flag_field_relative_cut_out',0.5);
        xlim([-1 1]); ylim([-0.5 1.5]);
        text(0,0,['''' flag_type_names{1,ii} ''''],'horizontalalignment','center','verticalalignment','top','interpreter','none');
    end
    return
end
if size(X,1) ~= size(Y,1) || size(X,2) ~= size(Y,2) || numel(X) ~= numel(Y) || numel(X) ~= size(X,1).*size(X,2)
    error(['The size of the X and Y input is inconsistent ([' num2str(size(X)) '] versus [' num2str(size(Y)) '])']);
end
if odd(nargin) && nargin > 2
    if iscell(varargin{1})
        if size(varargin{1},1) == 1 && size(varargin{1},2) == 1
            try
                varargin(1) = varargin{1};
            catch
                third_variable = varargin{1}; third_variable
                disp(' ');
                error(['Unknown third input variable']);
            end
        else
            third_variable = varargin{1}; third_variable
            disp(' ');
            error(['Unknown third input variable']);
        end
    end
    if ischar(varargin{1})
        if size(varargin{1},1) == 1
            if size(varargin{1},2) == 1
                % Just 1 letter specified, must be a flag_field_plot_color:
                varargin{length(varargin)+1} = 'flag_field_plot_color';
                varargin{length(varargin)+1} = varargin{1};
            else
                % A character string, must be the flag_field_type:
                varargin{length(varargin)+1} = 'flag_field_type';
                varargin{length(varargin)+1} = varargin{1};
            end
        else
            error('Multi-line character string input is not allowed');
        end
    elseif isnumeric(varargin{1})
        if size(varargin{1},1) == 1 && size(varargin{1},2) == 1
            varargin{length(varargin)+1} = 'flag_pole_height';
            varargin{length(varargin)+1} = repmat(varargin{1},size(X,1),size(X,2));
        elseif size(varargin{1},1) == size(X,1) && size(varargin{1},2) == size(X,2)
            varargin{length(varargin)+1} = 'flag_pole_height';
            varargin{length(varargin)+1} = varargin{1};
        elseif size(varargin{1},1) == 1 && size(varargin{1},2) == 3
            varargin{length(varargin)+1} = 'flag_field_plot_color';
            varargin{length(varargin)+1} = varargin{1};
        else
            third_variable = varargin{1}; third_variable
            disp(' ');
            error('Third input variable (assumed to be flag-pole height) has an inconsistent size compared to the X and Y input');
        end
    end
    varargin = varargin(2:end);
end

OPT = setproperty(OPT,varargin);

% Check all the input below:

% axis_equal
if iscell(OPT.axis_equal)
    OPT.axis_equal = OPT.axis_equal{:};
end
if isnumeric(OPT.axis_equal) || islogical(OPT.axis_equal)
    if size(OPT.axis_equal,1) ~= 1 || size(OPT.axis_equal,2) ~= 1
        axis_equal = OPT.axis_equal; axis_equal
        error(['Unknown input for keyword ''axis_equal''']);
    else
        if OPT.axis_equal ~= 0 && OPT.axis_equal ~= 1
            axis_equal = OPT.axis_equal; axis_equal
            error(['Unknown input for keyword ''axis_equal''']);
        end
    end
else
    axis_equal = OPT.axis_equal; axis_equal
    error(['Unknown input for keyword ''axis_equal''']);
end

% flag_mirror
if iscell(OPT.flag_mirror)
    OPT.flag_mirror = OPT.flag_mirror{:};
end
if isnumeric(OPT.flag_mirror) || islogical(OPT.flag_mirror)
    if size(OPT.flag_mirror,1) ~= 1 || size(OPT.flag_mirror,2) ~= 1
        flag_mirror = OPT.flag_mirror; flag_mirror
        error(['Unknown input for keyword ''flag_mirror''']);
    else
        if OPT.flag_mirror ~= 0 && OPT.flag_mirror ~= 1
            flag_mirror = OPT.flag_mirror; flag_mirror
            error(['Unknown input for keyword ''flag_mirror''']);
        end
    end
else
    flag_mirror = OPT.flag_mirror; flag_mirror
    error(['Unknown input for keyword ''flag_mirror''']);
end

% flag_field_plot_color
if iscell(OPT.flag_field_plot_color)
    OPT.flag_field_plot_color = OPT.flag_field_plot_color{:};
end
if ischar(OPT.flag_field_plot_color)
    if size(OPT.flag_field_plot_color,1) ~= 1 || size(OPT.flag_field_plot_color,2) ~= 1
        flag_field_plot_color = OPT.flag_field_plot_color; flag_field_plot_color
        error(['Unknown text input for keyword ''flag_field_plot_color''']);
    end
elseif isnumeric(OPT.flag_field_plot_color)
    if size(OPT.flag_field_plot_color,1) ~= 1 || size(OPT.flag_field_plot_color,2) ~= 3
        flag_field_plot_color = OPT.flag_field_plot_color; flag_field_plot_color
        error(['Numeric input for keyword ''flag_field_plot_color'' should be of size [1x3]']);
    else
        if min(OPT.flag_field_plot_color)<0 || max(OPT.flag_field_plot_color)>1 || sum(isnan(OPT.flag_field_relative_cut_out)) > 0
            flag_field_plot_color = OPT.flag_field_plot_color; flag_field_plot_color
            error(['Numeric input for keyword ''flag_field_plot_color'' should have values in between 0 and 1']);
        end
    end
else
    flag_field_plot_color = OPT.flag_field_plot_color; flag_field_plot_color
    error(['Unknown input for keyword ''flag_field_plot_color''']);
end

% flag_field_relative_cut_out
if iscell(OPT.flag_field_relative_cut_out)
    OPT.flag_field_relative_cut_out = OPT.flag_field_relative_cut_out{:};
end
if isnumeric(OPT.flag_field_relative_cut_out)
    if size(OPT.flag_field_relative_cut_out,1) ~= 1 || size(OPT.flag_field_relative_cut_out,2) ~= 1
        flag_field_relative_cut_out = OPT.flag_field_relative_cut_out; flag_field_relative_cut_out
        error(['Unknown input for keyword ''flag_field_relative_cut_out''']);
    else
        if OPT.flag_field_relative_cut_out<=0 || OPT.flag_field_relative_cut_out>1 || isnan(OPT.flag_field_relative_cut_out)
            error(['Unknown input for keyword ''flag_field_relative_cut_out'', should be in between 0 and 1']);
        end
    end
else
    flag_field_relative_cut_out = OPT.flag_field_relative_cut_out; flag_field_relative_cut_out
    error(['Unknown input for keyword ''flag_field_relative_cut_out''']);
end

% flag_field_relative_height
if iscell(OPT.flag_field_relative_height)
    OPT.flag_field_relative_height = OPT.flag_field_relative_height{:};
end
if isnumeric(OPT.flag_field_relative_height)
    if size(OPT.flag_field_relative_height,1) ~= 1 || size(OPT.flag_field_relative_height,2) ~= 1
        flag_field_relative_height = OPT.flag_field_relative_height; flag_field_relative_height
        error(['Unknown input for keyword ''flag_field_relative_height''']);
    else
        if OPT.flag_field_relative_height<0 || OPT.flag_field_relative_height>1 || isnan(OPT.flag_field_relative_height)
            error(['Unknown input for keyword ''flag_field_relative_height'', should be in between 0 and 1']);
        end
    end
else
    flag_field_relative_height = OPT.flag_field_relative_height; flag_field_relative_height
    error(['Unknown input for keyword ''flag_field_relative_height''']);
end

% flag_field_relative_width
if iscell(OPT.flag_field_relative_width)
    OPT.flag_field_relative_width = OPT.flag_field_relative_width{:};
end
if isnumeric(OPT.flag_field_relative_width)
    if size(OPT.flag_field_relative_width,1) ~= 1 || size(OPT.flag_field_relative_width,2) ~= 1
        flag_field_relative_width = OPT.flag_field_relative_width; flag_field_relative_width
        error(['Unknown input for keyword ''flag_field_relative_width''']);
    else
        if OPT.flag_field_relative_width<=0 || OPT.flag_field_relative_width>1 || isnan(OPT.flag_field_relative_width)
            error(['Unknown input for keyword ''flag_field_relative_width'', should be in between 0 and 1']);
        end
    end
else
    flag_field_relative_width = OPT.flag_field_relative_width; flag_field_relative_width
    error(['Unknown input for keyword ''flag_field_relative_width''']);
end

% flag_field_type
flag_type_names = {'triangle','triangle_up','triangle_down','square','square_cut_in','square_cut_out','triangle_wave','square_wave','square_wave_cut_in'};
if iscell(OPT.flag_field_type)
    OPT.flag_field_type = OPT.flag_field_type{:};
end
if ischar(OPT.flag_field_type)
    if size(OPT.flag_field_type,1) ~= 1
        flag_field_type = OPT.flag_field_type; flag_field_type
        error(['Unknown multi-line character input for keyword ''flag_field_type''']);
    else
        if sum(strcmp(flag_type_names,OPT.flag_field_type)) == 0
            error(['Unknown flag-field type ''' OPT.flag_field_type ''', call the function flag_plot() without input to see your options'])
        end
    end
else
    flag_field_type = OPT.flag_field_type; flag_field_type
    error(['Unknown input for keyword ''flag_field_type''']);
end

% flag_pole_height
if iscell(OPT.flag_pole_height)
    OPT.flag_pole_height = OPT.flag_pole_height{:};
end
if isnumeric(OPT.flag_pole_height)
    if size(OPT.flag_pole_height,1) == 1 && size(OPT.flag_pole_height,2) == 1 && numel(X)>1
        OPT.flag_pole_height = repmat(OPT.flag_pole_height,size(X,1),size(X,2));
    end
    if size(OPT.flag_pole_height,1) ~= size(X,1) || size(OPT.flag_pole_height,2) ~= size(X,2)
        flag_pole_height = OPT.flag_pole_height; flag_pole_height
        error(['Unknown numeric input size for keyword ''flag_pole_height''']);
    end
    if sum(isnan(OPT.flag_pole_height)) > 0
        error(['Unknown numeric input size for keyword ''flag_pole_height'', contains a NaN value']);
    end
else
    flag_pole_height = OPT.flag_pole_height; flag_pole_height
    error(['Unknown input for keyword ''flag_pole_height''']);
end

% flag_pole_plot_color
if iscell(OPT.flag_pole_plot_color)
    OPT.flag_pole_plot_color = OPT.flag_pole_plot_color{:};
end
if ischar(OPT.flag_pole_plot_color)
    if size(OPT.flag_pole_plot_color,1) ~= 1 || size(OPT.flag_pole_plot_color,2) ~= 1
        flag_pole_plot_color = OPT.flag_pole_plot_color; flag_pole_plot_color
        error(['Unknown text input for keyword ''flag_pole_plot_color''']);
    end
elseif isnumeric(OPT.flag_pole_plot_color)
    if size(OPT.flag_pole_plot_color,1) ~= 1 || size(OPT.flag_pole_plot_color,2) ~= 3
        flag_pole_plot_color = OPT.flag_pole_plot_color; flag_pole_plot_color
        error(['Numeric input for keyword ''flag_pole_plot_color'' should be of size [1x3]']);
    else
        if min(OPT.flag_pole_plot_color)<0 || max(OPT.flag_pole_plot_color)>1 || sum(isnan(OPT.flag_pole_plot_color)) > 0
            flag_pole_plot_color = OPT.flag_pole_plot_color; flag_pole_plot_color
            error(['Numeric input for keyword ''flag_pole_plot_color'' should have values in between 0 and 1']);
        end
    end
else
    flag_pole_plot_color = OPT.flag_pole_plot_color; flag_pole_plot_color
    error(['Unknown input for keyword ''flag_pole_plot_color''']);
end

% flag_pole_relative_width
if iscell(OPT.flag_pole_relative_width)
    OPT.flag_pole_relative_width = OPT.flag_pole_relative_width{:};
end
if isnumeric(OPT.flag_pole_relative_width)
    if size(OPT.flag_pole_relative_width,1) ~= 1 || size(OPT.flag_pole_relative_width,2) ~= 1
        flag_pole_relative_width = OPT.flag_pole_relative_width; flag_pole_relative_width
        error(['Unknown input for keyword ''flag_pole_relative_width''']);
    else
        if OPT.flag_pole_relative_width<0 || OPT.flag_pole_relative_width>0.2 || isnan(OPT.flag_pole_relative_width)
            error(['Unknown input for keyword ''flag_pole_relative_width'', should be in between 0 and 0.2']);
        end
    end
else
    flag_pole_relative_width = OPT.flag_pole_relative_width; flag_pole_relative_width
    error(['Unknown input for keyword ''flag_pole_relative_width''']);
end

% flag_rotation
if iscell(OPT.flag_rotation)
    OPT.flag_rotation = OPT.flag_rotation{:};
end
if isnumeric(OPT.flag_rotation)
    if size(OPT.flag_rotation,1) ~= 1 || size(OPT.flag_rotation,2) ~= 1
        flag_rotation = OPT.flag_rotation; flag_rotation
        error(['Unknown input for keyword ''flag_rotation'', should be a single value']);
    elseif isnan(OPT.flag_rotation)
        error(['Unknown input (NaN) for keyword ''flag_rotation'', should be a single value']);
    end
else
    flag_rotation = OPT.flag_rotation; flag_rotation
    error(['Unknown input for keyword ''flag_rotation''']);
end

% plot_to_figure
if iscell(OPT.plot_to_figure)
    OPT.plot_to_figure = OPT.plot_to_figure{:};
end
if isnumeric(OPT.plot_to_figure) || islogical(OPT.plot_to_figure)
    if size(OPT.plot_to_figure,1) ~= 1 || size(OPT.plot_to_figure,2) ~= 1
        plot_to_figure = OPT.plot_to_figure; plot_to_figure
        error(['Unknown input for keyword ''plot_to_figure''']);
    else
        if OPT.plot_to_figure ~= 0 && OPT.plot_to_figure ~= 1
            plot_to_figure = OPT.plot_to_figure; plot_to_figure
            error(['Unknown input for keyword ''plot_to_figure''']);
        end
    end
else
    plot_to_figure = OPT.plot_to_figure; plot_to_figure
    error(['Unknown input for keyword ''plot_to_figure''']);
end

% Default relative flag parts (pole and field):
flag_pole_rel = [-OPT.flag_pole_relative_width./2 0; -OPT.flag_pole_relative_width./2 1; OPT.flag_pole_relative_width./2 1; OPT.flag_pole_relative_width./2 0];
if strcmp(OPT.flag_field_type,'triangle')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height./2; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'triangle_up')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'triangle_down')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'square')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'square_cut_in')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1; min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height./2; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'square_cut_out')
    flag_field_rel = [OPT.flag_pole_relative_width./2 1; min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1; min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height./2; min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) 1-OPT.flag_field_relative_height; OPT.flag_pole_relative_width./2 1-OPT.flag_field_relative_height];
elseif strcmp(OPT.flag_field_type,'triangle_wave')
    flag_field_rel = [[OPT.flag_pole_relative_width./2:(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-((min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100):-(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:OPT.flag_pole_relative_width./2]; [[1:-OPT.flag_field_relative_height./2./100:1-OPT.flag_field_relative_height./2 (1-OPT.flag_field_relative_height./2)-OPT.flag_field_relative_height./2./100:-OPT.flag_field_relative_height./2./100:1-OPT.flag_field_relative_height] + [(OPT.flag_field_relative_height./8).*sind([0:360/100:360 360-360/100:-360/100:0])]]]';
elseif strcmp(OPT.flag_field_type,'square_wave')
    flag_field_rel = [[OPT.flag_pole_relative_width./2:(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1):-(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:OPT.flag_pole_relative_width./2]; [repmat(1,1,101) repmat(1-OPT.flag_field_relative_height,1,101)] + [(OPT.flag_field_relative_height./8).*sind([0:360/100:360 360:-360/100:0])]]';
elseif strcmp(OPT.flag_field_type,'square_wave_cut_in')
    flag_field_rel = [[OPT.flag_pole_relative_width./2:(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) [(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-((min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1))./100):-(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1))./100:min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)) (min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) + ((min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1))./100):(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1))./100:min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1) -((min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-min(OPT.flag_field_relative_width - OPT.flag_field_relative_cut_out.*OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1))./100))] min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1):-(min(OPT.flag_field_relative_width + OPT.flag_pole_relative_width./2,1)-OPT.flag_pole_relative_width./2)./100:OPT.flag_pole_relative_width./2]; [repmat(1,1,101) [(1-(1-(1-OPT.flag_field_relative_height./2))./100:-(1-(1-OPT.flag_field_relative_height./2))./100:1-OPT.flag_field_relative_height./2) ((1-OPT.flag_field_relative_height./2)-(1-(1-OPT.flag_field_relative_height./2))./100:-(1-(1-OPT.flag_field_relative_height./2))./100:(1-OPT.flag_field_relative_height)+((1-(1-OPT.flag_field_relative_height./2))./100))] repmat(1-OPT.flag_field_relative_height,1,101)] + [(OPT.flag_field_relative_height./8).*sind([0:360/100:360 [(360-((OPT.flag_field_relative_cut_out.*360)./100):-(OPT.flag_field_relative_cut_out.*360)./100:360-(OPT.flag_field_relative_cut_out.*360)) (360-(OPT.flag_field_relative_cut_out.*360) + ((OPT.flag_field_relative_cut_out.*360)./100):(OPT.flag_field_relative_cut_out.*360)./100:360-((OPT.flag_field_relative_cut_out.*360)./100))] 360:-360/100:0])]]';
else
    error(['Unknown flag-field type ''' OPT.flag_field_type ''', call the function flag_plot() without input to see your options'])
end

% Mirror the flag field
if OPT.flag_mirror
    flag_field_rel(:,1) = -flag_field_rel(:,1);
end

% Rotate the entire flag:
if mod(OPT.flag_rotation,360) ~= 0
    flag_pole_rel  = [sqrt((flag_pole_rel(:,1).^2)+(flag_pole_rel(:,2).^2)).*sind(atand(flag_pole_rel(:,1)./flag_pole_rel(:,2))+OPT.flag_rotation),sqrt((flag_pole_rel(:,1).^2)+(flag_pole_rel(:,2).^2)).*cosd(atand(flag_pole_rel(:,1)./flag_pole_rel(:,2))+OPT.flag_rotation)]; flag_pole_rel(isnan(flag_pole_rel)) = 0;
    flag_field_rel = [sqrt((flag_field_rel(:,1).^2)+(flag_field_rel(:,2).^2)).*sind(atand(flag_field_rel(:,1)./flag_field_rel(:,2))+OPT.flag_rotation),sqrt((flag_field_rel(:,1).^2)+(flag_field_rel(:,2).^2)).*cosd(atand(flag_field_rel(:,1)./flag_field_rel(:,2))+OPT.flag_rotation)];  flag_field_rel(isnan(flag_field_rel)) = 0;
end

% Store the data to a patch-data variable
for ii=1:size(X,1)
    for jj=1:size(X,2)
        patch_data{ii,jj}.flag_pole               = [X(ii,jj) + (OPT.flag_pole_height(ii,jj).*flag_pole_rel(:,1))  Y(ii,jj) + (OPT.flag_pole_height(ii,jj).*flag_pole_rel(:,2))];
        patch_data{ii,jj}.flag_field              = [X(ii,jj) + (OPT.flag_pole_height(ii,jj).*flag_field_rel(:,1)) Y(ii,jj) + (OPT.flag_pole_height(ii,jj).*flag_field_rel(:,2))];
        patch_data{ii,jj}.plot_flag_pole_command  = ['patch(patch_data{' num2str(ii) ',' num2str(jj) '}.flag_pole(:,1),patch_data{' num2str(ii) ',' num2str(jj) '}.flag_pole(:,2),[' strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(num2str(OPT.flag_pole_plot_color),'yellow','1 1 0'),'magenta','1 0 1'),'cyan','0 1 1'),'red','1 0 0'),'green','0 1 0'),'blue','0 0 1'),'white','1 1 1'),'black','0 0 0'),'y','1 1 0'),'m','1 0 1'),'c','0 1 1'),'r','1 0 0'),'g','0 1 0'),'b','0 0 1'),'w','1 1 1'),'k','0 0 0') '],''LineWidth'',' num2str(OPT.LineWidth) ',''EdgeColor'',[' strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(num2str(OPT.EdgeColor),'yellow','1 1 0'),'magenta','1 0 1'),'cyan','0 1 1'),'red','1 0 0'),'green','0 1 0'),'blue','0 0 1'),'white','1 1 1'),'black','0 0 0'),'y','1 1 0'),'m','1 0 1'),'c','0 1 1'),'r','1 0 0'),'g','0 1 0'),'b','0 0 1'),'w','1 1 1'),'k','0 0 0') ']);'];
        patch_data{ii,jj}.plot_flag_field_command = ['patch(patch_data{' num2str(ii) ',' num2str(jj) '}.flag_field(:,1),patch_data{' num2str(ii) ',' num2str(jj) '}.flag_field(:,2),[' strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(num2str(OPT.flag_field_plot_color),'yellow','1 1 0'),'magenta','1 0 1'),'cyan','0 1 1'),'red','1 0 0'),'green','0 1 0'),'blue','0 0 1'),'white','1 1 1'),'black','0 0 0'),'y','1 1 0'),'m','1 0 1'),'c','0 1 1'),'r','1 0 0'),'g','0 1 0'),'b','0 0 1'),'w','1 1 1'),'k','0 0 0') '],''LineWidth'',' num2str(OPT.LineWidth) ',''EdgeColor'',[' strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(strrep(num2str(OPT.EdgeColor),'yellow','1 1 0'),'magenta','1 0 1'),'cyan','0 1 1'),'red','1 0 0'),'green','0 1 0'),'blue','0 0 1'),'white','1 1 1'),'black','0 0 0'),'y','1 1 0'),'m','1 0 1'),'c','0 1 1'),'r','1 0 0'),'g','0 1 0'),'b','0 0 1'),'w','1 1 1'),'k','0 0 0') '],''FaceAlpha'',' num2str(OPT.FaceAlpha) ');'];
    end
end

% Plotting:
if OPT.plot_to_figure
    figure(gcf); hold on;
    % Plot ii flags:
    for ii=1:size(X,1)
        for jj=1:size(X,2)
            % First plot the pole:
            p1 = patch(patch_data{ii,jj}.flag_pole(:,1),patch_data{ii,jj}.flag_pole(:,2),OPT.flag_pole_plot_color,'LineWidth',OPT.LineWidth,'EdgeColor',OPT.EdgeColor);
            % Now plot the field:
            p2 = patch(patch_data{ii,jj}.flag_field(:,1),patch_data{ii,jj}.flag_field(:,2),OPT.flag_field_plot_color,'LineWidth',OPT.LineWidth,'EdgeColor',OPT.EdgeColor,'FaceAlpha',OPT.FaceAlpha);
            patch_data{ii,jj}.flag_pole_handle  = p1;
            patch_data{ii,jj}.flag_field_handle = p2;
        end
    end
    if OPT.axis_equal
        if sum(get(gca,'dataAspectRatio') == [1 1 1])~=3
            axis equal;
        end
    end
end

varargout{1} = patch_data;
if nargout>1
    for ii=2:nargout
        if ii == 2
            varargout{ii} = OPT;
        else
            varargout{ii} = 'This output variable is ignored';
        end
    end
end

end