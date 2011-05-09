function hPos=gelm_hpos(hInd,SubInd);

switch hInd,
case 0,
  if SubInd==1,
    hPos=[0 0 115 0];
  elseif SubInd==2,
    hPos=[125 0 115 0];
  elseif SubInd==3,
    hPos=[0 0 55 0];
  elseif SubInd==4,
    hPos=[60 0 55 0];
  elseif SubInd==5,
    hPos=[125 0 55 0];
  elseif SubInd==6,
    hPos=[185 0 55 0];
  else, % 0
    hPos=[0 0 240 0];
  end;
case 1,
  if SubInd==1,
    hPos=[0 0 55 0];
  elseif SubInd==2,
    hPos=[60 0 55 0];
  elseif SubInd==3,
    hPos=[0 0 35 0];
  elseif SubInd==4,
    hPos=[40 0 35 0];
  elseif SubInd==5,
    hPos=[80 0 35 0];
  else, % 0
    hPos=[0 0 115 0];
  end;
case 2,
  if SubInd==1,
    hPos=[125 0 55 0];
  elseif SubInd==2,
    hPos=[185 0 55 0];
  elseif SubInd==3,
    hPos=[125 0 35 0];
  elseif SubInd==4,
    hPos=[165 0 35 0];
  elseif SubInd==5,
    hPos=[205 0 35 0];
  else, % 0
    hPos=[125 0 115 0];
  end;
case 3,
  if SubInd==1,
    hPos=[0 0 35 0];
  elseif SubInd==2,
    hPos=[40 0 75 0];
  else, % 0
    hPos=[0 0 115 0];
  end;
case 4,
  if SubInd==1,
    hPos=[125 0 35 0];
  elseif SubInd==2,
    hPos=[165 0 75 0];
  else, % 0
    hPos=[125 0 115 0];
  end;
case 5,
  if SubInd==1,
    hPos=[0 0 75 0];
  elseif SubInd==2,
    hPos=[80 0 35 0];
  else, % 0
    hPos=[0 0 115 0];
  end;
case 6,
  if SubInd==1,
    hPos=[125 0 75 0];
  elseif SubInd==2,
    hPos=[205 0 35 0];
  else, % 0
    hPos=[125 0 115 0];
  end;
case 7,
  if SubInd==1,
    hPos=[63 0 55 0];
  elseif SubInd==2,
    hPos=[122 0 55 0];
  else, % 0
    hPos=[63 0 114 0];
  end;
case 8,
  if SubInd==1,
    hPos=[63 0 35 0];
  elseif SubInd==2,
    hPos=[102 0 75 0];
  else, % 0
    hPos=[63 0 114 0];
  end;
case 9,
  if SubInd==1,
    hPos=[63 0 75 0];
  elseif SubInd==2,
    hPos=[142 0 35 0];
  else, % 0
    hPos=[63 0 114 0];
  end;
case 10,
  if SubInd==1,
    hPos=[0 0 55 0];
  elseif SubInd==2,
    hPos=[65 0 175 0];
  else, % 0
    hPos=[0 0 240 0];
  end;
case 11,
  if SubInd==1,
    hPos=[0 0 175 0];
  elseif SubInd==2,
    hPos=[185 0 55 0];
  else, % 0
    hPos=[0 0 240 0];
  end;
otherwise,
  hPos=[10 0 10 0];
end;
hPos(1)=hPos(1)+10;