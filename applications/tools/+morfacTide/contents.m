% Morphological tide toolbox (morfacTide)
%
% Syntax:
% OUT = morfacTide.getSignal(input,lat,varargin)
%
% Script returns a representative periodic tidal signal determined from a
% tidal input signal. The input signal needs to be a scalar quantity.
% This can be, for example, tidal water levels, velocity magnitudes,
% or velocity u and v components.
% Function requires equidistant time-interval of the input signal.
%
% Options for the output are a representative double tide (cf. Lesser, 2009)
% or a representative spring-neap cycle (cf. Schrijvershof et al., 2023).
%
%
% INPUT:
% input         Mx2 numeric array [time,val] consisting of
%               - time: array of matlab datenum values
%               - val:  array of values (scalar quantity)
%               OR
%               Mx3 cell array consisting of
%               - Constituent names (e.g. M2, M4 etc.)
%               - Constituent amplitudes
%               - Constituent phases (in degrees)
% lat           Latitude (for nodal corrections in tidal analysis)
%
% Optional:
% type          'springneap' (default) or 'doubletide'
% nCycles       Number of cycles (repetitions) of the repr. signal (default = 2)
%               Use this option if the hydro. sim. time is to be preserved
%               Although not recommended, it can a have non-integer value
%               doubletide: length = nCycles * 24.84 hr (2 M2 cycles)
%               springneap: length = nCycles * 14.4907 days (28 M2 cycles)
% morTime       Morphological timespan to simulate (in days)
%               Use this option if the morph. sim. time is is to be preserved
% morFac        APPROX. MorFac wanted for simulation
% tStart        Datenum value for start of repr. cycle(s).
%               If tStart is not specified 01-01-2000 is used.
%
%               Logical switches:
% ampFac        0 or 1 (default), only in combination with type = 'doubletide'
%               Switch to apply a scaling factor on M2 amplitude to
%               account for a residual flow in the tidal frequencies
% histScaling   0 or 1 (default), only in combination with type = 'springneap'
%               Switch to scale the amplitudes and phases of the repr.
%               cycle(s) to histograms of the full tidal signal
%               Takes about 1.5 minutes!
% plot          0 or 1 (default 0)
%
%
% OUTPUT:
% OUT           representative tidal signal
%
% Example (1) with timeseries:
% time = datenum(2000,1,1):datenum(0,0,0,0,1,0):datenum(2001,1,1);
% val  =
%
% OUT = morfacTide.getSignal([time,val],53,'type','springneap')
%
%
% Example (2) with tidal constituents
% input = {'M2',1.00,0;
%          'S2',0.10,100;
%          'O1',0.09,120;
%          'K1',0.08,130;
%          'M4',0.10,50;
%          'M6',0.05,30};
% lat   = 53;
% OUT = morfacTide.getSignal(input,53,'type','springneap');
%
% References
%
% Lesser, G. R. (2009). An Approach to Medium-term Coastal Morphological Modelling. 
%   http://www.narcis.nl/publication/RecordID/oai:tudelft.nl:uuid:62caa573-4fc0-428e-8768-0aa47ab612a9
% Roelvink, D., & Reniers, A. (2011). A Guide to Modeling Coastal Morphology. 
%   WORLD SCIENTIFIC. https://doi.org/10.1142/7712
% Schrijvershof, R. A., van Maren, D. S., Torfs, P. J. J. F., & Hoitink, A. J. F. (2023). 
%   A Synthetic Spring-Neap Tidal Cycle for Long-Term Morphodynamic Models. Journal of Geophysical Research: Earth Surface, 128(3), e2022JF006799. https://doi.org/10.1029/2022JF006799

