import sys

def progressbar(p, size=70, char='>'):

  p  = min(max(p,0),1)

  n1 = int(round(p * size))
  n2 = int(round(size - n1))

  s1 = char * n1
  s2 = ' ' * n2

  sys.stdout.write('[%s%s] %d%%\r' % (s1,s2,int(round(100*p))))