function DESettings = getDefaultDESettings

DESettings = struct(...
    'Flags',[],...          % for logical values that can be used to turn on / off various processes in the dune erosion calculation
    'Constants',[],...      % for constants during the calculation
    'Other',struct ...      % for all other (temporary) variables that are needed during calculation
    );

DESettings.Flags = struct(...
    'AdditionalErosionMax',true,...     % can be used to turn on / off boundary limitation of the additional erosion to 15 meters
    'ChannelSlopes',true,...            % can be used to turn on / off boundary limitation due to steep (channel) slopes
    'PreventLandwardTransport',true,... % can be used to turn on / off volume correction for landward directed sediment transport
    'AutoStrengthening',false,...       % can be used to turn on / off automated strenghtening of a landward profile part
    'DuneBreachCalculation',true ...    % can be used to turn on / off secondary calculations after a first dune row has been breached
    );

DESettings.Constants = struct(...
    'a',0.476,...       % first constant used in calculation of the fall velocity of sediment
    'b',2.18,...        % second constant used in calculation of the fall velocity of sediment
    'c',3.226,...       % third constant used in calculation of the fall velocity of sediment
    'rho',1024,...      % specific gravity of salt water
    'g',9.81...         % fall excelleration
    );

DESettings.Other = struct(...
    'AdditionalVolume','min([-20,.25*Volume])',...  % formulation to use to determine the target volume
    'Plus','-plus',...                              % DUROS-plus method (including Tp, as opposed to DUROS)
    'n_d',1, ...                                    % scale factor
    'Bend',0, ...                                   % Coastal Bend
    'ProfileFluct',0, ...                           % Profile fluctuation
    'maxRetreat',15,...                             % Limitation of additional erosion length
    'maxiter', 50, ...                              % Maximum number of iterations
    'verbosemessages',[45,1,3,60,61,-4,-5,-6],...      % Messages that have to be displayed whem verbose is set to true
    'FallVelocity', {{@getFallVelocity ...          % Fall velocity function
        'a' 0.476 ...                               % Fall velocity input arguments; these arguments will be passed through to the fall velocity function together with the D50
        'b' 2.18 ...
        'c' 3.226 ...
        'D50'}} ... % because getFallVelocity uses propertyname propertyvalue pairs for all variables, the last arguments is therefore the propertyname (!) D50, since the property value of D50 is included during the process
    );

DESettings.Actions = struct(...
    'Verbose',true, ...             % Display important messages at the end of the calculation
    'DUROS',true, ...               % can be used to turn on / off DUROS(-plus) calculation
    'AdditionalErosion',true, ...   % can be used to turn on / off additional erosion calculation
    'BoundaryProfile',true ...      % can be used to turn on / off boundary profile fitting
    );
