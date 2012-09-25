function varargout = splash(fname, time, pos, siz) 
%SPLASH create a splash screen 
% 
% Usage: 
%        splash(fname, time) 
%        splash(fname, time, pos, siz) 
%        f = splash(...) 
%        [f,t] = splash(...) 
% 
% Where: 
% - fname : file name of an image to show 
% - time  : the time to show the splash screen for in seconds 
% - pos   : the position of the splash center in normalized screen 
%           coordinates (of the form [xpos, ypos]). 
%           defaults to [0.5 0.5] 
% - siz   : the size of the splash in pixels. defaults to the image size 
% - f     : the created frame 
% - t     : the timer object used to hide the splash screen after time 
% 
% REMARK: Don't forget to stop en delete the timer afterwards!



% set default position 
if nargin < 3 || isempty(pos) 
   pos = [0.5,0.5]; 
end 


% read the image 
if exist(fname,'file') ~= 2
   error('The image %s does not exist!',fname) 
end 
img = imread(fname); 


% get the screen size 
tk = java.awt.Toolkit.getDefaultToolkit(); 
d = tk.getScreenSize(); 


% determine the default splash size and resize image 
if nargin < 4 
   siz = size(img); 
   siz = fliplr(siz(1:2)); 
else 
   img = imresize(img,fliplr(siz)); 
end 


% convert to java image 
jimg = im2java(img); 

%%
% create the frame 
frame = javax.swing.JFrame; 

% remove decorations 
frame.setUndecorated(true) 

% set text layer
textPane = javax.swing.JTextPane;
textPane.setContentType('text/html')
% set content in html
html = '<h1><center>test</center></h1>';
textPane.setText(html)
% make transparent
textPane.setOpaque(0)

% set icon layer
icon = javax.swing.ImageIcon(jimg); 
iconPane = javax.swing.JLabel;
iconPane.setIcon(icon); 

% put them together in layered pane
layeredPane = javax.swing.JLayeredPane;
layeredPane.add(iconPane, javax.swing.JLayeredPane.DEFAULT_LAYER)
layeredPane.add(textPane, javax.swing.JLayeredPane.PALETTE_LAYER)

% set size of both layers to size of image
iconPane.setBounds( 0, 0,  siz(1), siz(2)); 
textPane.setBounds( 0, 0,  siz(1), siz(2));

frame.setContentPane(layeredPane);

%%
% set the size and location of the frame 
frame.setSize(siz(1),siz(2)); 
frame.setLocation(pos(1) * d.width - siz(1)/2, ... 
                   pos(2) * d.height - siz(2)/2); 

% ta-daaaa 
frame.show; 
frame.setAlwaysOnTop(1)

% now create the timer to close the thing again 
t = timer('TimerFcn',@(a,b,c) frame.hide, ... 
           'ExecutionMode', 'SingleShot', 'StartDelay', time); 
start(t); 

% output arguments 
if nargout > 0 
   varargout{1} = frame; 
   if nargout > 1 
     varargout{2} = t; 
   end 
end 


