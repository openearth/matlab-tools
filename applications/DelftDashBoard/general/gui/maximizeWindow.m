function maximizeWindow(name)

h = actxserver('WScript.Shell');
%Put the title of your window as seen in the title bar
h.AppActivate(name);
h.SendKeys('% '); %this is shortcut key ALT + {SPACE}
h.SendKeys('{DOWN 4}');
h.SendKeys('~'); %This is enter
