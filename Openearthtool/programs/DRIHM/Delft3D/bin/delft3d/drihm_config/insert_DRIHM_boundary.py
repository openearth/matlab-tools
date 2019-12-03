import datetime
import waterml2
import os

#
# Scan files for location to insert
#
tstartDefined = False
tstopDefined  = False
files = os.listdir('.')
for f in files:
   if f.endswith('.mdf'):
      #print 'Processing "'+f+'"'
      #
      # for all mdf files
      #
      mdffile = open(f,'r').readlines()
      bctname = ''
      bndname = ''
      for line in mdffile:
         #
         # check if it contains a reference to a BCT file
         #
         key = line.split('=')[0].strip().lower()
         if key=='filbct':
            bctname = line[line.find('=')+1:].strip()
            if bctname.find('#')>=0:
               bctname = bctname.split('#')[1].strip()
         elif key=='itdate':
            itdate = line[line.find('=')+1:].strip()
            if itdate.find('#')>=0:
               itdate = itdate.split('#')[1].strip()
            itdate = datetime.datetime.strptime(itdate,'%Y-%m-%d')
         elif key=='tunit':
            tunit = line[line.find('=')+1:].strip().lower()
            if tunit.find('#')>=0:
               tunit = tunit.split('#')[1].strip()
            tunit = [1.0, 60.0, 3600.0, 86400.0, 604800.0]['smhdw'.find(tunit)]
         elif key=='dt':
            dt = float(line[line.find('=')+1:].split()[0])
         elif key=='tstart':
            tstartMdf = float(line[line.find('=')+1:].split()[0])
            if tstartDefined:
               tstart = max(tstart,tstartMdf)
            else:
               tstart = tstartMdf
               tstartDefined = True
         elif key=='tstop':
            tstopMdf = float(line[line.find('=')+1:].split()[0])
            if tstopDefined:
               tstop = min(tstop,tstopMdf)
            else:
               tstop = tstopMdf
               tstopDefined = True
      #
      tstart0 = tstart
      tstop0  = tstop
      #
      #print '  ITDate = '+str(itdate)
      #print '  TStart = '+str(tstart)
      #print '  TStop  = '+str(tstop)
      #print '  Dt     = '+str(dt)
      #print '  TUnit  = '+str(tunit)
      #print '  FilBCT = '+bctname
      #
      if len(bctname)>0:
         #print 'Processing "'+bctname+'"'
         #
         # for each BCT file check if it contains location 'DRIHM'
         #
         bctfile = open(bctname,'r').readlines()
         bctModified = False
         startLine = 0
         for i in range(len(bctfile)-1,-1,-1):
            bline = bctfile[i].split("'")
            if len(bline)>1 and bline[0].strip()=='location':
               Location =  bline[1].strip()
               #print '  Location found "'+Location+'"'
               isQbound = False
               for j in range(i+1,len(bctfile)):
                  bline = bctfile[j].split("'")
                  if len(bline)>1 and bline[0].strip()=='parameter' and not bline[1].strip()=='time':
                     isQbound = bline[1].strip()=='total discharge (t)  end A'
                     break
               #
               if not isQbound:
                  print 'MESSAGE: Boundary "'+Location+'" is not a total discharge boundary'
                  continue
               #
               FileName = Location+".wml"
               if not os.path.isfile(FileName):
                  print 'MESSAGE: There is no WaterML2 file for discharge boundary "'+Location+'"'
                  continue
               #
               F = waterml2.loadWaterML2(FileName)
               if len(F['TimeSeries']) != 1:
                  print 'ERROR: The WaterML2 file "'+FileName+'" should contain one time series'
                  continue
               #
               print 'MESSAGE: Inserting discharge data from "'+FileName+'"'
               startLine = i
               endLine = len(bctfile)
               for j in range(i+1,len(bctfile)):
                  bline = bctfile[j].split("'")
                  if len(bline)>1 and bline[0].strip()=='table-name':
                     endLine = j
                     break
               #
               # Prepare Time Series for insertion into BCT file
               #
               NewText = []
               TS = F['TimeSeries'][0]['Time']
               VL = F['TimeSeries'][0]['Value']
               NewText.append("time-function        'non-equidistant'\n")
               NewText.append("reference-time       "+itdate.strftime('%Y%m%d')+"\n")
               NewText.append("time-unit            'minutes'\n")
               NewText.append("interpolation        'linear'\n")
               NewText.append("parameter            'time                '                     unit '[min]'\n")
               NewText.append("parameter            'total discharge (t)  end A'               unit '[m**3/s]'\n")
               NewText.append("parameter            'total discharge (t)  end B'               unit '[m**3/s]'\n")
               NewText.append("records-in-table     "+str(len(TS))+"\n")
               for i in range(len(TS)):
                  dTS   = TS[i]-itdate
                  dTSdt = round(dTS.total_seconds()/(dt*tunit))
                  dTSmn = dTSdt*(dt*tunit/60.0)
                  if i==0:
                     tstart = max(tstart,dTSdt*dt)
                  elif i==len(TS)-1:
                     tstop = min(tstop,dTSdt*dt)
                  NewText.append(str(dTSmn)+' '+str(VL[i])+' '+str(999.999)+'\n')
               #
               bctfile = bctfile[0:startLine+1]+NewText+bctfile[endLine:]
               bctModified = True
         #
         if bctModified:
            fwr = open(bctname,'w')
            for line in bctfile:
               fwr.write(line)
            fwr.close()
#
# Process mdf files once the overall start and stop time have been determined
#
if tstart>=tstop:
   print 'ERROR: The resulting simulation time interval is empty'
else:
   for f in files:
      if f.endswith('.mdf'):
         #print 'Processing "'+f+'"'
         mdffile = open(f,'r').readlines()
         #
         # start and end time need to be adjusted
         #
         flncdf = False
         print 'MESSAGE: Updating Tstart, Tstop, Flmap, Flhis, FlNcdf fields in "'+f+'"'
         for i in range(len(mdffile)):
            #
            # check if it contains a reference to a BCT file
            #
            key = mdffile[i].split('=')[0].strip().lower()
            if key=='tstart':
               mdffile[i] = 'Tstart = '+str(tstart)+'\n'
            elif key=='tstop':
               mdffile[i] = 'Tstop  = '+str(tstop)+'\n'
            elif key=='flmap':
               times = mdffile[i].split('=')[1].split()
               fildt = times[1]
               mdffile[i] = 'Flmap  = '+str(tstart)+' '+fildt+' '+str(tstop)+'\n'
            elif key=='flhis':
               times = mdffile[i].split('=')[1].split()
               flsta = float(times[0])
               fildt = times[1]
               mdffile[i] = 'Flhis  = '+str(tstart)+' '+fildt+' '+str(tstop)+'\n'
            elif key=='flncdf':
               mdffile[i] = 'FlNcdf = #map his fou dro#'+'\n'
               flncdf = True
         #
         if not flncdf:
            mdffile.append('FlNcdf = #map his fou dro#'+'\n')
         #
         fwr = open(f,'w')
         for line in mdffile:
            fwr.write(line)
         fwr.close()
         