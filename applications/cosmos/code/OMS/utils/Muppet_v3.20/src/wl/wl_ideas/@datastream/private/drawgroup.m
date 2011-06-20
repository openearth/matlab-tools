function [PHL,LHL]=drawgroup(Specs,Handles,OutputProcessColor,ProcessColor),

GridCell=20;

Process=Specs.Process;

NumberOfLinks=0;
for i=1:length(Process),
  for k=1:length(Process(i).InputFromProcess),
    NumberOfLinks=NumberOfLinks+length(Process(i).InputFromProcess{k});
  end;
end;

PHL=zeros(length(Process),1);  % PatchHandle
LHL=zeros(NumberOfLinks,5);    % LineHandle 1, ToProcess 2, ToConnector 3, FromProcess 4, FromConnector 5

L=1;
for i=1:length(Process),
  for j=1:length(Process(i).InputFromProcess),
    for k=1:length(Process(i).InputFromProcess{j}),
      LHL(L,2)=i; % ToProcess
      LHL(L,3)=j; % ToConnector
      LHL(L,4)=Process(i).InputFromProcess{j}(k);   % FromProcess
      LHL(L,5)=Process(i).InputFromConnector{j}(k); % FromConnector
      P1=Process(LHL(L,2)).PlotLocation+[GridCell*(LHL(L,3)-1/2) 10];
      P2=Process(LHL(L,4)).PlotLocation+[GridCell*(LHL(L,5)-1/2) 10];
      X=[P1(1) P1(1) P2(1) P2(1)];
      Y=[P1(2) P1(2)+20 P2(2)-20 P2(2)];
      LHL(L,1)=line(X,Y, ...
              -2*ones(1,4), ...
              'color','r', ...
              'linewidth',3, ...
              'parent',Handles.PlotAxes, ...
              'hittest','on', ...
              'buttondownfcn','setudf(gcbf,''CallbackHandle'',gcbo)', ...
              'uicontextmenu',Handles.InputLinkMenu);
      L=L+1;
    end;
  end;
end;

for i=1:length(Process),
  Width=GridCell*ceil(7*length(Process(i).Name)/GridCell);
  PHL(i)=processbutton(Process(i), ...
     'uicontextmenu',Handles.ProcessMenu, ...
     'parent',Handles.PlotAxes, ...
     'userdata',i, ...
     'buttondownfcn','setudf(gcbf,''CallbackHandle'',gcbo)');
  if ~isempty(Specs.OutputProcess),
    set(PHL(i), ...
     'facecolor',logicalswitch(i==Specs.OutputProcess,OutputProcessColor,ProcessColor));
  end;
end;
