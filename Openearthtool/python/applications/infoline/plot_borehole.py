# -*- coding: utf-8 -*-
"""
Created on Mon Aug 31 11:35:43 2015

@author: vermaas
"""

import matplotlib.pyplot as plt
import datetime

#################################
#input array, to be retrieved from Geotop class
LS = [('DR', 'zand grof', 0.0),
 ('DR', 'grind', 3.5),
 ('DR', 'zand grof', 4.0),
 ('GE', 'zand grof', 8.0),
 ('ST', 'zand matig grof', 22.0),
 ('ST', 'zand grof', 24.5),
 ('ST', 'klei zandig, leem, kleiig fijn zand', 32.0),
 ('ST', 'zand matig grof', 32.5),
 ('ST', 'zand grof', 34.0),
 ('ST', 'zand matig grof', 35.5),
 ('ST', 'zand grof', 36.0),
 ('PZWA', 'zand grof', 37.0)]
 
LS = [('EC', 'klei', 0.0), ('EC', 'organisch materiaal (veen)', 2.0), ('BXWISIKO', 'zand fijn', 2.5), ('BX', 'zand matig grof', 3.5), ('BX', 'zand fijn', 5.5), ('KRBXDE', 'zand fijn', 7.5), ('KRBXDE', 'grind', 12.5), ('KRBXDE', 'zand fijn', 17.0), ('KRBXDE', 'zand grof', 19.0), ('KRBXDE', 'grind', 19.5), ('KRBXDE', 'zand grof', 23.5), ('KRBXDE', 'zand matig grof', 25.0), ('KRBXDE', 'klei zandig, leem, kleiig fijn zand', 25.5), ('KRBXDE', 'zand grof', 26.0), ('UR', 'zand fijn', 28.0), ('ST', 'klei', 33.5), ('ST', 'zand fijn', 35.5), ('ST', 'klei zandig, leem, kleiig fijn zand', 38.5), ('ST', 'klei', 41.0), ('ST', 'zand fijn', 41.5), ('ST', 'zand matig grof', 42.0), ('ST', 'organisch materiaal (veen)', 42.5), ('PZWA', 'zand fijn', 43.5), ('PZWA', 'zand grof', 46.0), ('PZWA', 'zand fijn', 46.5)] 
 
##################################


def timest ():
    return str(datetime.datetime.now()).replace('-','').replace('.','').replace(' ','').replace(':','')

#dictionary for colors of plot
#colorDict = {   
#    'antropogeen':  'grey',
#    'organisch materiaal (veen)': 'saddlebrown',
#    'klei': 'green',
#    'klei zandig, leem, kleiig fijn zand': 'lawngreen',
#    'zand fijn': 'gold',
#    'zand matig grof': 'orange',
#    'zand grof': 'darkorange',
#    'grind': 'red',
#    'schelpen': 'darkblue'}
colorDict = {   
    'antropogeen':  [float(x)/255 for x in [255,255,255]],
    'organisch materiaal (veen)': [float(x)/255 for x in [129, 96, 0]],
    'klei': [float(x)/255 for x in [0,189,46]],
    'klei zandig, leem, kleiig fijn zand': [float(x)/255 for x in [191,170,255]],
    'zand fijn': [float(x)/255 for x in [255,255,128]],
    'zand matig grof': [float(x)/255 for x in [255,255,0]],
    'zand grof': [float(x)/255 for x in [255,223,0]],
    'grind': [float(x)/255 for x in [255,0,63]],
    'schelpen': [float(x)/255 for x in [0,255,255]]}
    
#dictionary for symbols on plot
hatchDict = {   
    'antropogeen':  '+',
    'organisch materiaal (veen)': '',
    'klei': '-',
    'klei zandig, leem, kleiig fijn zand': '.',
    'zand fijn': '',
    'zand matig grof': '.',
    'zand grof': 'o',
    'grind': 'O',
    'schelpen': ''}

#dictionary for relative width of bars    
wDict = {   
    'antropogeen':  0.2,
    'organisch materiaal (veen)': 0.2,
    'klei': 0.2,
    'klei zandig, leem, kleiig fijn zand': 0.15,
    'zand fijn': 0.3,
    'zand matig grof': 0.4,
    'zand grof': 0.5,
    'grind': 0.7,
    'schelpen': 0.8}
    
stratLongDict = {
    'AAOP': 'Antropogene afzettingen', 
    'NIGR': 'Formatie van Nieuwkoop, Laagpakket van Griendtsveen', 
    'NINB': 'Formatie van Nieuwkoop, Laag van Nij Beets', 
    'NASC': 'Formatie van Naaldwijk, Laagpakket van Schoorl', 
    'ONAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (gedeelte boven NAZA)', 
    'NAZA': 'Formatie van Naaldwijk, Laagpakket van Zandvoort', 
    'NAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren, gelegen onder Formatie van Naaldwijk, Laagpakket van Zandvoort', 
    'BHEC': 'Formatie van Echteld (gedeelte buiten NIHO)', 
    'OEC': 'Formatie van Echteld (gedeelte boven NIHO)', 
    'NAWOBE': 'Formatie van Naaldwijk, Laagpakket van Wormer, Laag van Bergen', 
    'NIHO': 'Formatie van Nieuwkoop, Hollandveen Laagpakket', 
    'NAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer', 
    'NWNZ': 'Formatie van Naaldwijk, laagpakketten van Wormer en Zandvoort', 
    'NAWOVE': 'Formatie van Naaldwijk, Laagpakket van Wormer, Laag van Velsen', 
    'NIBA': 'Formatie van Nieuwkoop, Basisveen Laag', 
    'NA': 'Formatie van Naaldwijk', 
    'EC': 'Formatie van Echteld', 
    'NI': 'Formatie van Nieuwkoop', 
    'KK': 'Kreekrak Formatie', 
    'BXKO': 'Formatie van Boxtel, Laagpakket van Kootwijk', 
    'BXSI': 'Formatie van Boxtel, Laagpakket van Singraven', 
    'BXWI': 'Formatie van Boxtel, Laagpakket van Wierden', 
    'BXWISIKO': 'Formatie van Boxtel, laagpakketten van Wierden, Singraven en Kootwijk', 
    'BXDE': 'Formatie van Boxtel, Laagpakket van Delwijnen', 
    'BXSC': 'Formatie van Boxtel, Laagpakket van Schimmert', 
    'BXLM': 'Formatie van Boxtel, Laagpakket van Liempde', 
    'BXBS': 'Formatie van Boxtel, Laagpakket van Best', 
    'BX': 'Formatie van Boxtel', 
    'KRWY': 'Formatie van Kreftenheye, Laag van Wijchen', 
    'KRBXDE': 'Formatie van Kreftenheye en Formatie van Boxtel, Laagpakket van Delwijnen', 
    'KRZU': 'Formatie van Kreftenheye, Laagpakket van Zutphen', 
    'KROE': 'Formatie van Kreftenheye, gelegen onder de Eem Formatie', 
    'KRTW': 'Formatie van Kreftenheye, Laagpakket van Twello', 
    'KR': 'Formatie van Kreftenheye', 
    'BEWY': 'Formatie van Beegden, Laag van Wijchen', 
    'BERO': 'Formatie van Beegden, Laag van Rosmalen', 
    'BE': 'Formatie van Beegden', 
    'KW': 'Formatie van Koewacht', 
    'WB': 'Formatie van Woudenberg', 
    'EE': 'Eem Formatie', 
    'EEWB': 'Formatie van Woudenberg en Eem Formatie', 
    'DR': 'Formatie van Drente', 
    'DRGI': 'Formatie van Drente, Laagpakket van Gieten', 
    'GE': 'Door landijs gestuwde afzettingen', 
    'DN': 'Formatie van Drachten', 
    'URTY': 'Formatie van Urk, Laagpakket van Tijnje', 
    'PE': 'Formatie van Peelo', 
    'UR': 'Formatie van Urk', 
    'ST': 'Formatie van Sterksel', 
    'AP': 'Formatie van Appelscha', 
    'SY': 'Formatie van Stramproy', 
    'PZ': 'Formatie van Peize', 
    'WA': 'Formatie van Waalre', 
    'PZWA': 'Formatie van Peize en Formatie van Waalre', 
    'MS': 'Formatie van Maassluis', 
    'KI': 'Kiezeloöliet Formatie', 
    'OO': 'Formatie van Oosterhout', 
    'IE': 'Formatie van Inden', 
    'VI': 'Formatie van Ville', 
    'BR': 'Formatie van Breda', 
    'RUBO': 'Rupel Formatie, Laagpakket van Boom', 
    'RU': 'Rupel Formatie', 
    'TOZEWA': 'Formatie van Tongeren, Laagpakket van Zelzate, Laag van Watervliet', 
    'TOGO': 'Formatie van Tongeren, Laagpakket van Goudsberg', 
    'TO': 'Formatie van Tongeren', 
    'DOAS': 'Formatie van Dongen, Laagpakket van Asse', 
    'DOIE': 'Formatie van Dongen, Laagpakket van Ieper', 
    'DO': 'Formatie van Dongen', 
    'LA': 'Formatie van Landen', 
    'HT': 'Formatie van Heijenrath', 
    'HO': 'Formatie van Holset', 
    'MT': 'Formatie van Maastricht', 
    'GU': 'Formatie van Gulpen', 
    'VA': 'Formatie van Vaals', 
    'AK': 'Formatie van Aken', 
    'AEC': 'Formatie van Echteld (geulafzettingen generatie A)', 
    'ANAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (geulafzettingen generatie A)', 
    'ANAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer (geulafzettingen generatie A)', 
    'BEC': 'Formatie van Echteld (geulafzettingen generatie B)', 
    'BNAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (geulafzettingen generatie B)', 
    'BNAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer (geulafzettingen generatie B)', 
    'CEC': 'Formatie van Echteld (geulafzettingen generatie C)', 
    'CNAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (geulafzettingen generatie C)', 
    'CNAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer (geulafzettingen generatie C)', 
    'DEC': 'Formatie van Echteld (geulafzettingen generatie D)', 
    'DNAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (geulafzettingen generatie D)', 
    'DNAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer (geulafzettingen generatie D)', 
    'EEC': 'Formatie van Echteld (geulafzettingen generatie E)', 
    'ENAWA': 'Formatie van Naaldwijk, Laagpakket van Walcheren (geulafzettingen generatie E)', 
    'ENAWO': 'Formatie van Naaldwijk, Laagpakket van Wormer (geulafzettingen generatie E)', 
    'NN': 'Niet formeel ingedeelde afzettingen of onbekend'}

stratShortDict = {
    'AAOP': 'Antropogeen',
    'NIGR': 'Nieuwkoop, Griendtsveen',
    'NINB': 'Nieuwkoop, Nij Beets',
    'NASC': 'Naaldwijk, Schoorl',
    'ONAWA': 'Naaldwijk, Walcheren',
    'NAZA': 'Naaldwijk, Zandvoort',
    'NAWA': 'Naaldwijk, Walcheren',
    'BHEC': 'Echteld (buiten Nieuwkoop, Hollandveen)',
    'OEC': 'Echteld (boven Nieuwkoop, Hollandveen)',
    'NAWOBE': 'Naaldwijk, Wormer, Laag van Bergen',
    'NIHO': 'Nieuwkoop, Hollandveen',
    'NAWO': 'Naaldwijk, Wormer',
    'NWNZ': 'Naaldwijk, Wormer en Zandvoort',
    'NAWOVE': 'Naaldwijk, Wormer, Laag van Velsen',
    'NIBA': 'Nieuwkoop, Basisveen',
    'NA': 'Naaldwijk',
    'EC': 'Echteld',
    'NI': 'Nieuwkoop',
    'KK': 'Kreekrak',
    'BXKO': 'Boxtel, Kootwijk',
    'BXSI': 'Boxtel, Singraven',
    'BXWI': 'Boxtel, Wierden',
    'BXWISIKO': 'Boxtel, Wierden, Singraven en Kootwijk',
    'BXDE': 'Boxtel, Delwijnen',
    'BXSC': 'Boxtel, Schimmert',
    'BXLM': 'Boxtel, Liempde',
    'BXBS': 'Boxtel, Best',
    'BX': 'Boxtel',
    'KRWY': 'Kreftenheye, Wijchen',
    'KRBXDE': 'Kreftenheye en Boxtel, Delwijnen',
    'KRZU': 'Kreftenheye, Zutphen',
    'KROE': 'Kreftenheye, onder Eem',
    'KRTW': 'Kreftenheye, Twello',
    'KR': 'Kreftenheye',
    'BEWY': 'Beegden, Wijchen',
    'BERO': 'Beegden, Rosmalen',
    'BE': 'Beegden',
    'KW': 'Koewacht',
    'WB': 'Woudenberg',
    'EE': 'Eem',
    'EEWB': 'Woudenberg en Eem',
    'DR': 'Drente',
    'DRGI': 'Drente, Gieten',
    'GE': 'Gestuwde afzettingen',
    'DN': 'Drachten',
    'URTY': 'Urk, Tijnje',
    'PE': 'Peelo',
    'UR': 'Urk',
    'ST': 'Sterksel',
    'AP': 'Appelscha',
    'SY': 'Stramproy',
    'PZ': 'Peize',
    'WA': 'Waalre',
    'PZWA': 'Peize en Waalre',
    'MS': 'Maassluis',
    'KI': 'Kiezelooliet ',
    'OO': 'Oosterhout',
    'IE': 'Inden',
    'VI': 'Ville',
    'BR': 'Breda',
    'RUBO': 'Rupel, Boom',
    'RU': 'Rupel',
    'TOZEWA': 'Tongeren, Zelzate, Laag van Watervliet',
    'TOGO': 'Tongeren, Goudsberg',
    'TO': 'Tongeren',
    'DOAS': 'Dongen, Asse',
    'DOIE': 'Dongen, Ieper',
    'DO': 'Dongen',
    'LA': 'Landen',
    'HT': 'Heijenrath',
    'HO': 'Holset',
    'MT': 'Maastricht',
    'GU': 'Gulpen',
    'VA': 'Vaals',
    'AK': 'Aken',
    'AEC': 'Echteld (geulafz. A)',
    'ANAWA': 'Naaldwijk, Walcheren (geulafz. A)',
    'ANAWO': 'Naaldwijk, Wormer (geulafz. A)',
    'BEC': 'Echteld (geulafz. B)',
    'BNAWA': 'Naaldwijk, Walcheren (geulafz. B)',
    'BNAWO': 'Naaldwijk, Wormer (geulafz. B)',
    'CEC': 'Echteld (geulafz. C)',
    'CNAWA': 'Naaldwijk, Walcheren (geulafz. C)',
    'CNAWO': 'Naaldwijk, Wormer (geulafz. C)',
    'DEC': 'Echteld (geulafz. D)',
    'DNAWA': 'Naaldwijk, Walcheren (geulafz. D)',
    'DNAWO': 'Naaldwijk, Wormer (geulafz. D)',
    'EEC': 'Echteld (geulafz. E)',
    'ENAWA': 'Naaldwijk, Laagpakket van Walcheren (geulafz. E)',
    'ENAWO': 'Naaldwijk, Laagpakket van Wormer (geulafz. E)',
    'NN': 'Onbekend'}
    
#lithology
L = [] 
L.append(LS[0])
for i in range(1,len(LS)):
    if not LS[i][1]==LS[i-1][1]:
        L.append(LS[i])
#stratigrapy
S = [] 
S.append(LS[0])
for i in range(1,len(LS)):
    if not LS[i][0]==LS[i-1][0]:
        S.append(LS[i]) 

#longest name of stratigraphy (to make width of plot fit)
mx=0
for s in S:
    if len(stratShortDict[s[0]])>mx:
        mx=len(stratShortDict[s[0]])


#### plot lithology###
fig = plt.figure(figsize(2,10))#,frameon=False)
for i in range(0,len(L)-1):
    plt.bar(1,L[i+1][2]-L[i][2],width=wDict[L[i][1]],bottom=-L[i+1][2],color=colorDict[L[i][1]],hold='on',hatch=hatchDict[L[i][1]])

bar = plt.bar(1,50-L[i+1][2],width=wDict[L[i+1][1]],bottom=-50,color=colorDict[L[i+1][1]],hatch=hatchDict[L[i+1][1]])

plt.tick_params(axis='x',which='both',bottom='off',top='off', labelbottom='off')
plt.tick_params(axis='y',which='both', right='off')    
plt.ylabel('Diepte onder maaiveld [m]')
fig.tight_layout()

fig1 = plt.gcf()
fig1.savefig('D:/' + timest() + '.png',dpi=150)

#### plot stratigraphy ####
fig = plt.figure(figsize(1+2*mx/20,10))#,frameon=False)
for i in range(0,len(S)-1):
    plt.plot([0,6],[-S[i+1][2],-S[i+1][2]],'--',color='black',linewidth=2)
    y = (S[i+1][2]-S[i][2])/2 + S[i][2] + 0.2
    plt.text(0.1,-y,stratShortDict[S[i][0]])

y = (50-S[i+1][2])/2 + S[i+1][2] + 0.2
plt.text(0.1,-y,stratShortDict[S[i+1][0]])
# labels and ticks
plt.tick_params(axis='x',which='both',bottom='off',top='off', labelbottom='off')
plt.tick_params(axis='y',which='both', right='off')    
plt.ylim([-50,0])
plt.ylabel('Diepte onder maaiveld [m]')
fig.tight_layout()

fig1 = plt.gcf()
fig1.savefig('D:/' + timest() + '.png',dpi=150)