function testresult = getG_test()
% GETG_TEST  unit test for getG
%  
% This test definition defines a unit test for getG
%
%
%   See also getG 

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
% Created: 01 Oct 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = getG unit test)
% getG calculates the amount of sediment loss that has to be taken into account when calculating
% dune erosion at the location of a bend in the coastline according to:
%
% $$G = {{A^* } \over {300}}\left( {{{H_{0s} } \over {7.6}}} \right)^{0.72} \left( {{w \over {0.0268}}} \right)^{0.56} G_0$$
%
% G0 depends on the bend of the coastline:
%
% <html>
%   <table>
%       <tr>
%           <th>class</th>
%           <th>Coastal bend</th>
%           <th>G0 [m3/m]</th>
%       </tr>
%       <tr>
%           <td>1</td><td>0 - 6</td><td>0</td>
%       </tr>
%       <tr>
%           <td>2</td><td>6 - 12</td><td>50</td>
%       </tr>
%       <tr>
%           <td>3</td><td>12 - 18</td><td>75</td>
%       </tr>
%       <tr>
%           <td>4</td><td>18 - 24</td><td>100</td>
%       </tr>
%       <tr>
%           <td>5</td><td>> 24</td><td>further research required</td>
%       </tr>
%   </table>
% </html>
%
% This test checks whether an input of |A* = 300|, |H0s = 7.6 [s]|, |w = 0.0268; [m/s]| and |Bend = 10| returns
% the manually calculated |G = 50|.

%% $RunCode
A1 = 300;
Hs1 = 7.6;
w1 = 0.0268;
Bend1 = 10;
G = getG(A1,Hs1,w1,Bend1);

testresult = G==50;

%% Vary bend
Bend = 1:1:30;
G1 = nan(size(Bend));
for i=1:length(Bend)
    Gtemp = getG(A1,Hs1,w1,Bend(i));
    if ~isempty(Gtemp)
        G1(i) =Gtemp;
    end
end

%% vary Hs
Hs = 12:0.2:18;
G2 = nan(size(Hs));
for i=1:length(Hs)
    Gtemp = getG(A1,Hs(i),w1,Bend1);
    if ~isempty(Gtemp)
        G2(i) =Gtemp;
    end
end

%% Vary w
w = 0.02:0.001:0.03;
G3 = nan(size(w));
for i=1:length(w)
    Gtemp = getG(A1,Hs1,w(i),Bend1);
    if ~isempty(Gtemp)
        G3(i) =Gtemp;
    end
end

%% vary A
A = 100:10:400;
G4 = nan(size(A));
for i=1:length(A)
    Gtemp = getG(A(i),Hs1,w1,Bend1);
    if ~isempty(Gtemp)
        G4(i) =Gtemp;
    end
end

%% $PublishResult (EvalueatCode = true & IncludeCode = false)
% The testresult consists of two parts:
%
% # Outcome of the unit test with default values
% # Results of getG with various values for the coastal bend
%

%% Rersult unit test
% The result of the unit test was:

disp(['G = ' num2str(G,'%0.0f') ' [m3 / m]']);

%% Regression test
% The following figure shows the outcome of getG with various input parameters:

figure('Color','w');
subplot(2,2,1)
hold on
grid on
plot(Bend,G1,'Marker','o','MarkerEdgeColor','k');
xlabel('Coastal bend');
ylabel('G');
subplot(2,2,2)
hold on
grid on
plot(Hs,G2,'Marker','o','MarkerEdgeColor','k');
xlabel('Hs [m]');
ylabel('G');
subplot(2,2,3)
hold on
grid on
plot(w,G3,'Marker','o','MarkerEdgeColor','k');
xlabel('w [m/s]');
ylabel('G');
subplot(2,2,4)
hold on
grid on
plot(A,G4,'Marker','o','MarkerEdgeColor','k');
xlabel('A [m3/m]');
ylabel('G');
