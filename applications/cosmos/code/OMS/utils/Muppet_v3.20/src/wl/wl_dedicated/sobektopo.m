function sobektopo(filename)

%NODE id '0' nm 'Knoop51' px 75000.0 py 1000.0 node
%BRCH id '8' nm 'BRANCH 04' bn '0' en '11' al 7327 brch
[id,nm,rm]=textread(filename,['%*[^'']''%[^'']''%*[^'']''%[^'']''%*s%[^' char(10) ']']);

%75000.0 py 1000.0 node
%'0' en '11' al 7327 brch
i0=[];
for i=1:length(id)
  if rm{i}(1)~='''' % NODE
    %75000.0 py 1000.0 node
    Network.Node(i).ID=id{i};
    Network.Node(i).NM=nm{i};
    Network.Node(i).XY=sscanf(rm{i},'%f py %f',[1 2]);
  else % BRANCH
    %'0' en '11' al 7327 brch
    if isempty(i0), i0=i-1; end
    Network.Branch(i-i0).ID=id{i};
    Network.Branch(i-i0).NM=nm{i};
    Str=rm{i}(2:end);
    [X,numrd,errmsg,next]=sscanf(Str,'%[^'']',1);
    Network.Branch(i-i0).FROM=X;
    Str=Str(next:end);
    [X,numrd,errmsg,next]=sscanf(Str,''' en ''%[^'']'' al %f',[1 2]);
    Network.Branch(i-i0).TO=char(X(1:end-1));
    Network.Branch(i-i0).LENGTH=X(end);
  end
end
