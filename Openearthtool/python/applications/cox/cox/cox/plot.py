import matplotlib
import cStringIO
import numpy as np
import scipy.stats

# do not show any images
matplotlib.use('Agg')

import matplotlib.pyplot as plt

def plot_image(img, filename=None, cmap=None, dpi=96, slice=0, normalize=True, clim=None):
  'Plot image data'
  
  if len(img.shape)>2:
    img = img[:,:,:3]
  
#  if normalize:
#    img = (img - img.min()) / max(1,img.max() - img.min()) * 255.0
    
#  if not clim == None and len(clim) == 2:
#    img = (img - clim[0]) / max(1,clim[1] - clim[0])
#    img[img<0] = 0.0
#    img[img>1] = 1.0
  
  if slice > 0:
    img = img[::slice,::slice,:]
  
  i = float(img.shape[1] + 44)/dpi # correct for "invisible" tick label space
  j = float(img.shape[0] + 17)/dpi

  fig, ax = plt.subplots(figsize=(i,j))
  
  kwargs = {}
  if not cmap == None and len(img.shape)<3:
    kwargs["cmap"] = cmap
  
  if not normalize:
    kwargs["norm"] = None
    
  if not clim == None and len(clim) == 2:
    kwargs["norm"] = None
    kwargs["vmin"] = clim[0]
    kwargs["vmax"] = clim[1]
    
  ax.imshow(img, aspect='normal', **kwargs)
  ax.set_axis_off()
  
  plt.subplots_adjust(left=0., right=1., top=1., bottom=0.)
  plt.tight_layout(pad=0., h_pad=0., w_pad=0.)
  
  r = save_fig(fig, filename=filename, dpi=dpi)
  
  plt.close()
  
  return r
  
def save_fig(fig, filename=None, dpi=96, axis_only=True):

  if filename == None:
    filename = cStringIO.StringIO()
  
  if axis_only:
  
    extent = fig.axes[0].get_window_extent().transformed(fig.dpi_scale_trans.inverted())
    fig.savefig(filename, format='jpeg', bbox_inches=extent, pad_inches=0, dpi=dpi)
    
  else:
    fig.savefig(filename, format='jpeg', pad_inches=0, dpi=dpi)
  
  if filename == None:
    filename.seek(0)
    return filename.read()