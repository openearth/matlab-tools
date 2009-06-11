function CS = ConvertCoordinatesCheckInput(CS,STD)
if ~isempty(CS.type)
    switch lower(CS.type)
        case {'geographic 2d','geo','geographic2d','latlon','lat lon','geographic'}
            CS.type = 'geographic 2D';
        case {'projected','xy','proj','cartesian','cart'}
            CS.type = 'projected';
        case {'engineering', 'geographic 3D', 'vertical', 'geocentric',  'compound'}
            error(['input ''CType = ' CS.type ''' is not (yet) supported']); 
        otherwise
            error(['coordinate type ''' CS.type ''' is not known']);
    end
end
end
