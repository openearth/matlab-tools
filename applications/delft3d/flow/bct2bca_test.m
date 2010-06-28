function bct2bca_test()
% BCT2BCA_TEST  test script for BCT2BCA
%  
% More detailed description of the test goes here.
%
%
%   See also bca2bct bct2bca 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

H.components  = {'K1','O1','P1','Q1','K2','M2','N2','S2'};
H.latitude    = 52; % eps; %52;
H.plot        = 0;
H.pause       = 0;
H.output      = 'none';
H.residue     = ['.\bct2bca_test\TMP_cas_residue_'   ,num2str(H.latitude),'noa0.bct'];
H.prediction  = ['.\bct2bca_test\TMP_cas_prediction_',num2str(H.latitude),'noa0.bct'];

%% Analyse raw time series with a strong meteo tide
%% -------------------------

H.A0          = 0;
bct2bca('.\bct2bca_test\TMP_cas.bct',...
       ['.\bct2bca_test\bct2bca_',num2str(H.latitude),'noa0.bca'],...
        '.\bct2bca_test\bca.bnd',H);

%% Analyse raw time series with a strong meteo tide
%% -------------------------

H.A0          = 1;
bct2bca('.\bct2bca_test\TMP_cas.bct',...
       ['.\bct2bca_test\bct2bca_',num2str(H.latitude),'.bca'],...
        '.\bct2bca_test\bca.bnd',H);


%% Now analyse predicted water levels and test whether the residual is zero
%% -------------------------

H.residue    =['.\bct2bca_test\TMP_cas_residue_of_prediction_'   ,num2str(H.latitude),'.bct'];
H.prediction =['.\bct2bca_test\TMP_cas_prediction_of_prediction_',num2str(H.latitude),'.bct'];
        

H.A0          = 0;
bct2bca(['.\bct2bca_test\TMP_cas_prediction_'   ,num2str(H.latitude),'noa0.bct'],...
        ['.\bct2bca_test\bct2bca_of_prediction_',num2str(H.latitude),'noa0.bca'],...
        '.\bct2bca_test\bca.bnd',H);        
        
H.A0          = 1;
bct2bca(['.\bct2bca_test\TMP_cas_prediction_'   ,num2str(H.latitude),'.bct'],...
        ['.\bct2bca_test\bct2bca_of_prediction_',num2str(H.latitude),'.bca'],...
        '.\bct2bca_test\bca.bnd',H);        
