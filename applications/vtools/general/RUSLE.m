function out = RUSLE(varargin)
%RUSLE Estimates annual sediment yield from a small catchment
%
% OUTPUT STRUCT:
%   out.A_hillslope      % t/ha/yr (gross erosion)
%   out.SDR              % sediment delivery ratio (-)
%   out.SY_t_yr          % total sediment yield (t/yr)
%   out.SY_t_km2_yr      % specific sediment yield (t/km2/yr)
%
% REQUIRED INPUTS (Name-Value pairs):
%   'Area_km2'   : Catchment area [km2]
%   'R'          : Rainfall erosivity factor
%   'K'          : Soil erodibility factor
%   'LS'         : Slope-length factor
%   'C'          : Cover factor
%   'P'          : Support practice factor
%
% OPTIONAL:
%   'SDR_k'      : SDR coefficient (default 0.42)
%   'SDR_m'      : SDR exponent (default 0.125)
%
% References:
%   Renard et al. (1997) RUSLE
%   Walling (1983) sediment delivery problem
%
%% Reasonable Values Documentation (markdown)

% # Revised Universal Soil Loss Equation (RUSLE) — SI Units

% The **Revised Universal Soil Loss Equation (RUSLE)** is commonly used in SI units to calculate **average annual soil loss (A)** in **metric tons per hectare per year (t·ha⁻¹·yr⁻¹)**.

% RUSLE formula:

% $$
% A = R \times K \times L \times S \times C \times P
% $$

% Below are typical **reasonable values** for each factor based on environmental studies and guidelines.

% ***

% ## 1. **Soil Loss (A) — Output**

% **Unit:** *t·ha⁻¹·yr⁻¹*

% **Reasonable Values:**

% *   **Very Low:** < 2 t·ha⁻¹·yr⁻¹
% *   **Moderate:** 5–10 t·ha⁻¹·yr⁻¹
% *   **High/Severe:** > 20–50+ t·ha⁻¹·yr⁻¹

% ## 2. **Rainfall Erosivity Factor (R)**

% **Unit:** *MJ·mm·ha⁻¹·hr⁻¹·yr⁻¹*

% **Reasonable Values:** (Highly dependent on rainfall intensity and duration)

% *   **Arid / Low Rainfall:** < 500
% *   **Moderate / Humid:** 1000–3000
% *   **High / Tropical:** > 4000+

% ## 3. **Soil Erodibility Factor (K)**

% **Unit:** *t·ha·hr / (ha·MJ·mm)*  
% (often simplified to *t·ha·hr·ha⁻¹·MJ⁻¹·mm⁻¹*)

% *   **Low (0.05–0.15):** High clay, resistant to detachment
% *   **Moderate (0.2–0.35):** Silt loams, medium resistance
% *   **High (0.4–0.6+):** High silt, low organic matter, highly erodible

% ## 4. **Slope Length (L) and Steepness (S) Factors**

% **Unit:** Dimensionless

% *   **Flat / Gentle:** 0.1–1.0
% *   **Moderate Slope:** 1.0–3.0
% *   **Steep / Hilly:** 3.0–10.0+ (strongly dependent on slope length)

% ## 5. **Cover-Management Factor (C)**

% **Unit:** Dimensionless (0–1)

% *   **Dense Forest / Good Pasture:** 0.001–0.05
% *   **Managed Crops / Agricultural Land:** 0.1–0.5
% *   **Bare Soil / Construction Sites:** 0.5–1.0

% ## 6. **Support Practice Factor (P)**

% **Unit:** Dimensionless (0–1)

% *   **No Practices / Downslope Tillage:** 1.0
% *   **Contour Farming:** 0.5–0.9
% *   **Terracing:** 0.1–0.5


%% Parse inputs
p = inputParser;

addParameter(p,'Area_km2',[]);
addParameter(p,'R',[]); %mm ha⁻¹ h⁻¹ yr⁻¹
addParameter(p,'K',[]);
addParameter(p,'LS',[]);
addParameter(p,'C',[]);
addParameter(p,'P',[]);
addParameter(p,'SDR_k',0.42);
addParameter(p,'SDR_m',0.125);
addParameter(p,'porosity',0.4);
addParameter(p,'density',2650); % kg/m3

parse(p,varargin{:});
pr = p.Results;

%% Checks
required = {'Area_km2','R','K','LS','C','P'};
for i = 1:length(required)
    if isempty(pr.(required{i}))
        error('Missing required input: %s',required{i});
    end
end

%% 1. RUSLE hillslope erosion (t/ha/yr)
A_hillslope = pr.R * pr.K * pr.LS * pr.C * pr.P;

%% 2. Sediment Delivery Ratio
SDR = pr.SDR_k * pr.Area_km2^(-pr.SDR_m);

% Constrain SDR to physically realistic bounds
SDR = max(min(SDR,1),0);

%% 3. Convert area to hectares
Area_ha = pr.Area_km2 * 100;

%% 4. Total sediment yield (t/yr)
SY_t_yr = A_hillslope * Area_ha * SDR;

%% 5. Specific sediment yield (t/km2/yr)
SY_t_km2_yr = SY_t_yr / pr.Area_km2;

%% Output structure
out.A_hillslope   = A_hillslope;
out.SDR           = SDR;
out.SY_t_yr       = SY_t_yr;
out.SY_t_km2_yr   = SY_t_km2_yr;

end