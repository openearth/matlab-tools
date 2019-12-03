'''
DISPER  Linear dispersion relation.

absolute error in k*h < 5.0e-16 for all k*h

Syntax:
k = disper(omega, h, g)

Input:
w = 2*pi/T, where T is the wave period
h = water depth
g = gravity constant

Output:
k = wave number

Example
k = disper(2*pi/5,5,9.81);
'''

import numpy as np

def disper(w, h, g=9.81):
    if not type(w) == list:
        w=[w]
    if not type(h) == list:
        h=[h]
    w2 = [iw**2 * ih / g for (iw,ih) in zip(w,h)]
    q = [iw2 / (1 - np.exp(-(iw2**(5/4))))**(2/5) for iw2 in w2]

    thq = np.tanh(q)
    thq2 = 1 - thq**2

    a = (1 - q * thq) * thq2
    b = thq + q * thq2
    c = q * thq - w2

    D = b**2 - 4 * a * c
    arg = (-b + np.sqrt(D)) / (2 * a)
    iq = np.where(D < 0)[0]
    if iq:
        print(iq)
        arg[iq] = -c[iq] / b[iq]
    q = q + arg

    k = np.sign(w) * q / h
    if np.isnan(k).any():
        k = np.array(k)
        k[np.isnan(k)] = 0

    return k

def disper_fentonmckee(sigma, d, g=9.81):

    def coth(x):
        return 1. / np.tanh(x)

    k = (sigma**2 / g) * (coth(sigma * np.sqrt(d / g))**(3 / 2))**(2 / 3)
    # k = sigma**2 / g * coth((sigma * np.sqrt(d / g))**(3 / 2))**(2 / 3)

    return k

