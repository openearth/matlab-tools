function [q1,q2,q3]=freeBoxPlot(data0, lineWidth, width)

% [lowerQuartile,median,upperQuartile]=freeBoxPlot(data0) - plot box-whiskers diagram, accept multiple columns
% Arguments: data0 -  unsorted data, mxn, m samples, n columns
%            lineWidth -  line thickness in the plot default = 1;
%            width -  the width of the box, default = 1;
% Returns:	 
% Notes: each column is considered as a single set	


    if(nargin < 3)
        width = 1;
    end;
    if(nargin < 2)
        lineWidth = 1;
    end;


    [m n] = size(data0);
    
    % account for nan's
    data = sort(data0, 1); % ascend
    data2=mat2cell(data,size(data,1),repmat(1,1,size(data,2)));
    data3=cellfun(@(x) x(~isnan(x)),data2,'UniformOutput',false);
    q2=cell2mat(cellfun(@median,data3,'UniformOutput',false));
%     q2 = median(data, 1);
    
%     if(rem(m,2) == 0)
%         
% %         upperA = data(1:m/2,:);
% %         lowA =  data(m/2+1:end,:);
% 
%         upperA = cellfun(@(x) x(1:m/2),data3,'UniformOutput',false);
%         lowerA = cellfun(@(x) x(m/2+1:end),data3,'UniformOutput',false);        
%     else
        
%         upperA = data(1:round(m/2), :);
%         lowA =  data(round(m/2):end, :);  

        upperA = cellfun(@(x) x(1:round(length(x)/2)),data3,'UniformOutput',false);
        lowA   = cellfun(@(x) x(round(length(x)/2)+1:end),data3,'UniformOutput',false);        
        
%     end;
    
%     q1 = median(upperA, 1);
%     q3 = median(lowA, 1);

    q1=cell2mat(cellfun(@median,upperA,'UniformOutput',false));
    q3=cell2mat(cellfun(@median,lowA,'UniformOutput',false));

%     min_v = data(1,:);
%     max_v = data(end,:);

    min_v = cellfun(@(x) x(1),data3);
    max_v = cellfun(@(x) x(end),data3);
    
    draw_data = [max_v; q3; q2; q1; min_v];
    
    % adjust the width
    drawBox(draw_data, lineWidth, width);


return;


function drawBox(draw_data, lineWidth, width)

    n = size(draw_data, 2);

    unit = (1-1/(1+n))/(1+9/(width+3));
    
    f1=gcf;    
    hold on;       
    for i = 1:n
        
        v = draw_data(:,i);
        
        % draw the min line
        plot([i-unit, i+unit], [v(5), v(5)], 'LineWidth', lineWidth,'color','k');
        % draw the max line
        plot([i-unit, i+unit], [v(1), v(1)], 'LineWidth', lineWidth,'color','k');
        % draw middle line
        plot([i-unit, i+unit], [v(3), v(3)], 'LineWidth', lineWidth,'color','r');
        % draw vertical line
        plot([i, i], [v(5), v(4)], 'LineWidth', lineWidth,'color','k','linestyle','--');
        plot([i, i], [v(2), v(1)], 'LineWidth', lineWidth,'color','k','linestyle','--');
        % draw box
        plot([i-unit, i+unit, i+unit, i-unit, i-unit], [v(2), v(2), v(4), v(4), v(2)], 'LineWidth', lineWidth,'color','b');
        
    end;

return;
