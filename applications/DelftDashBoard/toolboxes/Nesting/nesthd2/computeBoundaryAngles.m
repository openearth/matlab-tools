function [x,y,alphau,alphav]=computeBoundaryAngles(Flow)

for i=1:Flow.nrOpenBoundaries

    % End A
    
    x(i,1)=0.5*(Flow.openBoundaries(i).x(1) + Flow.openBoundaries(i).x(2));
    y(i,1)=0.5*(Flow.openBoundaries(i).y(1) + Flow.openBoundaries(i).y(2));

    dx=Flow.openBoundaries(i).x(2)-Flow.openBoundaries(i).x(1);
    dy=Flow.openBoundaries(i).y(2)-Flow.openBoundaries(i).y(1);
    if strcmpi(Flow.openBoundaries(i).orientation,'negative')
        dx=dx*-1;
        dy=dy*-1;
    end
    switch lower(Flow.openBoundaries(i).side)
        case{'left','right'}
            % u-point
            alphau(i,1)=atan2(dy,dx)-0.5*pi;
            alphav(i,1)=atan2(dy,dx);
        case{'bottom','top'}
            % v-point
            alphau(i,1)=atan2(dy,dx)+0.5*pi;
            alphav(i,1)=atan2(dy,dx);
    end

    % End B

    x(i,2)=0.5*(Flow.openBoundaries(i).x(end-1) + Flow.openBoundaries(i).x(end));
    y(i,2)=0.5*(Flow.openBoundaries(i).y(end-1) + Flow.openBoundaries(i).y(end));

    dx=Flow.openBoundaries(i).x(end)-Flow.openBoundaries(i).x(end-1);
    dy=Flow.openBoundaries(i).y(end)-Flow.openBoundaries(i).y(end-1);
    if strcmpi(Flow.openBoundaries(i).orientation,'negative')
        dx=dx*-1;
        dy=dy*-1;
    end
    switch lower(Flow.openBoundaries(i).side)
        case{'left','right'}
            % u-point
            alphau(i,2)=atan2(dy,dx)-0.5*pi;
            alphav(i,2)=atan2(dy,dx);
        case{'bottom','top'}
            % v-point
            alphau(i,2)=atan2(dy,dx)+0.5*pi;
            alphav(i,2)=atan2(dy,dx);
    end

end
