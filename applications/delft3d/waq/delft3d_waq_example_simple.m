%DELFT3D_WAQ_EXAMPLE_SIMPLE  example of Delft3D-WAQ grid from Delft3D-FLOW DD grids
%
%   plot a Delft3D-WAQ map: read unstructured Delft3D-WAQ data vector,
%   rework it into a Delft3D-FLOW matrix, and plot it as if
%   it were Delft3D-FLOW data.
%
%   With the approach in this example script you can use 
%   unstructured Delft3D-WAQ arrays as if they were regular Delft3D-FLOW 
%   arrays. This is a useful aproach for Delft3D-online-Sed minded 
%   modellers who want to explore Delft3D-WAQ.
%
%See also: DELFT3D_WAQ_EXAMPLE_COMPLEX, DELWAQ (in 'C:\Delft3D\w32\matlab\')

%% relevant OET help
%  >> help waq

%% A WAQ simulation result file contains no coordinates, only cell vaklues.
%  One needs two grid files to be able to plot the data:
%  1) *.lga: aggregation (pointers)
%  2) *.cco: coordinates (list of random corodinates from which lga selects)

%% read grid

   A = delwaq('open','d36_coupling_extended4.lga'); % needs both lga and cco

%% read unstructured Delft3D-WAQ data = vector

    D = delwaq('open','Hs_assimilated_SWAN_with_buoys_2007.map') % no coordinates, needs A

   [D.datenum,D.vector]=delwaq('read',D,'Hs',0,1); % Hs found in D.SubsName

%% plot unstructured Delft3D-WAQ data = vector

   figure  ('name','WAQ_COURSE_WAQ: data vector')
   semilogy(D.vector)

%% make structured Delft3D-FLOW data = matrix

   D.matrix = waq2flow3d(D.vector,A.Index)

%% plot structured Delft3D-FLOW data = matrix

   figure('name','WAQ_COURSE_WAQ: data matrix')
   pcolorcorcen(A.X(1:end-1,1:end-1),...
                A.Y(1:end-1,1:end-1),D.matrix(2:end-1,2:end-1,end),[.5 .5 .5])
   colorbarwithtitle('Hs [m]');
   axis    equal
   view   (0,90)
   tickmap('xy')

%% EOF