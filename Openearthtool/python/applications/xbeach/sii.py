import numpy as np

def get_sii(dataset, ti, var, threshold):
    """
    get storm surge indicator, constructed fromt original dataset
    """
    
    zb = dataset.variables['zb'][ti,:]
    zs = dataset.variables['zs'][ti,:]
    
    dry = np.absolute(zb-zs) < 1e-5
    deep = (-zb+zs) > 5.0
    
    if var == 'sii_vel':
        u = dataset.variables['u'][ti,:]
        val = (np.absolute(u)-u)/2
    elif var == 'sii_depvel':
        u = dataset.variables['u'][ti,:]
        v = dataset.variables['v'][ti,:]
        
        flow = np.sqrt(u**2 + v**2)
        val = (flow * (-zb+zs))
    else:
        assert False, "Unknown storm impact indicator ["+var+"]"
        
    sii = np.zeros(zb.shape, dtype='int')
    np.putmask(sii, val >= threshold, 4)
    np.putmask(sii, val < threshold, 3)
    np.putmask(sii, dry, 2)
    np.putmask(sii, deep, 1)
    
    return sii