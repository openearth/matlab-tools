function [dataset,d]=muppet_determineDatasetComponent(dataset,d)

%% Determine component
switch dataset.quantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                d.Val=sqrt(d.XComp.^2+d.YComp.^2);
                dataset.quantity='scalar';
            case('angle (radians)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
                dataset.quantity='scalar';
%            case('angledegrees')
            case('angle (degrees)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
                dataset.quantity='scalar';
            case('m-component')
                d.Val=d.XComp;
                dataset.quantity='scalar';
            case('n-component')
                d.Val=d.YComp;
                dataset.quantity='scalar';
            case{'x-component','x component','xcomponent'}
                d.Val=d.XComp;
                dataset.quantity='scalar';
            case{'y-component','y component','ycomponent'}
                d.Val=d.YComp;
                dataset.quantity='scalar';
        end
end
