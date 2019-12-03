import sys
sys.path.append('../../..')
import matplotlib
matplotlib.use('MacOSX')
import kmldap.model
kmldap.model.makejarkustransect(7003800)
t = kmldap.model.makejarkustransect(7003800)
z = t.interpolate_z()
import matplotlib.pyplot as plt
nprofiles = z.shape[0]
plt.figure()
for i in range(nprofiles-1):
    alpha = (float(i+1)/nprofiles)*(0.2) # gradually increase alpha over time from 0.0something to 0.5
    fig = plt.plot(t.cross_shore, z[i,:], alpha=alpha, lw=3, color=(0,0,1))
fig = plt.plot(t.cross_shore, z[nprofiles-1,:], alpha=1, lw=3, color=(0,0,0))
fig = plt.hlines([0], [t.cross_shore.min()], [t.cross_shore.max()], color="green")

