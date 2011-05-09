function xx_beep,
try,
  sound(0.05*sin(1:1000),20000);
catch,
  fprintf(1,char(7));
end;