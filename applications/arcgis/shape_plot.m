function poly = shape_plot(results)
%SHAPE_PLOT   plots an arcview shapefile as read by shape_read
%
%    H = shape_plot(R),
%
% where R is a structure variable returned by read_shape() and 
% H is a structure variable with handles to the map polygons
%
%  H(i).handles(k) = a handle to each of (nobs=npoly) polygon regions and its k-parts
%  H(1).fig_handle = a handle to a figure containing the map
%
%
% 1) to load and plot a map involving npoly=nobs sample data observations
%    results = shape_read('myarcfile');
%    poly = make_map(results);
%    set(poly(1).fig_handle,'Visible','on');
% 2) Also you can do the following:
%    figure(1);
%    hold on;
%    h = []; % handles to each polygon
%    for i=1:results.npoly;
%     for k=1:results.nparts(i);
%   	mypoly.faces = get(poly(i).handles(k),'Faces');
%   	mypoly.vertices = get(poly(i).handles(k),'Vertices');
%   	h(i,k) = patch(mypoly);
%    end;
%    end;
% 3) to set the facecolor of the polygons, using the handles h
%    for i=1:npoly;
%     for k=1:results(i).nparts;
%     set(h(i,k),'FaceColor',[0 1 1]);
%     end;
%    end;
%
%See also: SHAPE_READ, POLY_FUN

   x = results.x;
   y = results.y;
   
   poly(1).fig_handle = figure('Visible','on');
   handles = polyplot(x,y,'fill',[0 0 0]);

%% Process chunks separated by NaN .................
 
   in = [0; find(isnan(x))];
   if ~isnan(x(end))
   in = [in; length(x)+1];
   end   
   cnt  = 1;
   jj   = 1;
   while (jj <= n)
     ii = in(jj)+1:in(jj+1)-1;
     ii = [ii ii(1)];
     xx = x(ii); yy = y(ii);
   if results.nparts(cnt) == 1
      poly(cnt).handles(1,1) = handles(jj);
      cnt = cnt+1;
      jj  = jj+1;
   else
      for k=1:results.nparts(cnt);
         poly(cnt).handles(1,k) = handles(jj);
         jj = jj+1;
      end;
   cnt = cnt+1;
   end;
   end;

%% EOF   
