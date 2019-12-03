# python

import os 

# cita P.tss i transformise u Pcorr.tss
pcal=10
z=[]

os.chdir('work/river_case/river_hbv/meteo_prepare/')

# number of lines in file
file_open='P.tss'
a=open(file_open,'r')
lines = a.readlines()
last_line = lines[-1]
last_line=last_line.split()
vreme=int(last_line[0])
print 'vreme',vreme

f1=open('stations.txt','r')
liness =f1.readlines()
last_lines =liness[-1]
last_lines=last_lines.split()
broj_stanica=int(last_lines[2])
print 'broj stanica',broj_stanica

for line in f1:
  red=line.split()
  print 'red',red

f2=open('P.tss','r')
f3=open('Pcorr.tss','w')
f3.write('precipitation at zero level')

k=0 
for lines in f2.readlines():
  linija=lines.split()
  
  if k<=4 and k>=1:
    linija_striped=str(linija[0]).strip()
    f3.write(str(linija_striped))
    
  if k>=broj_stanica+3:
    stan=1
    f3.write(str(k-4)+' ')
    for stavka in liness:
      alt=stavka.split()
      z=float(alt[3])
      num=int(alt[2])
      print 'stavka',z
      hourly_prec=float(linija[stan])
      #print hourly_temp
      corr_prec=hourly_prec*(1-z*pcal/10000)
      print corr_prec
      
      f3.write(str(corr_prec)+' ')  
      stan=stan+1
    #a=raw_input()
  f3.write('\n')
      
  k=k+1    

os.chdir('../')
      

