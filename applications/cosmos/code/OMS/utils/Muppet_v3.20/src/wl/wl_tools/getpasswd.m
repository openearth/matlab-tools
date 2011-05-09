function p = getpasswd(action)
%GETPASSWD Dialog to get a password.
%   p = GETPASSWD opens a password dialog box.  p is the password
%   given.  If the dialog is closed, the Cancel button is pushed,
%   or an empty string is given then p = [].

% Jordan Rosenthal, Apr-18-2000
% jr@ece.gatech.edu

if nargin == 0, action = 'Run'; end
OKAY = 1; CANCELLED = 0;

switch action
   %---------------------------------------------------------------------
case 'Run'
   %---------------------------------------------------------------------
   %---  Setup dialog  ---%
   dlgPos = getdlgPos;
   hDlg = dialog('pos',dlgPos,'Name','Get Password');
   uicontrol(hDlg,'style','text','units','pixels','pos',[17 54 50 20], ...
      'string','Password:','Horiz','Left');
   hTxt = actxcontrol('Forms.TextBox.1',[72 55 175 20],hDlg);
   uicontrol(hDlg,'Style','PushButton','pos',[275 60 75 30],'string','Okay', ...
      'callback','getpasswd Okay');
   uicontrol(hDlg,'Style','PushButton','pos',[275 20 75 30],'string','Cancel', ....
      'callback','getpasswd Cancel');
   set(hTxt,'PasswordChar','*');
   set(hDlg,'UserData',CANCELLED);

   %---  Wait for user action  ---%
   uiwait(hDlg);

   %---  Process user action  ---%
   % If the windows close button is pushed then hDlg will not
   % be a valid handle so must check for that.
   p = [];
   if ishandle(hDlg)
      OKAYPUSHED = get(hDlg,'UserData');
      if OKAYPUSHED
         p = deblank( get(hTxt,'Text') );
      end
      delete(hDlg);
   end

   %---------------------------------------------------------------------
case 'Okay'
   %---------------------------------------------------------------------
   set(gcbf,'UserData',OKAY);
   uiresume(gcbf);

   %---------------------------------------------------------------------
case 'Cancel'
   %---------------------------------------------------------------------
   set(gcbf,'UserData',CANCELLED);
   uiresume(gcbf);

   %---------------------------------------------------------------------
otherwise
   %---------------------------------------------------------------------
   error('Illegal action.');
end

%---------------------------------------------------------------------
%---------------------------------------------------------------------

function dlgPos = getdlgPos()
%GETDLGPOS This function gets the position setting for the dialog.
OldUnits = get(0,'Units');
set(0,'units','pixels');
ScreenSize = get(0,'ScreenSize');
set(0,'units',OldUnits);
center = ScreenSize(3:4)/2;
dlgPos = [center(1)-188  center(2)-50  375  105];