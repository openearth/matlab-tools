"""Dit is de main routine voor de beslissingstool. Het beslisschema staat hier ook in. In grote lijnen: 
In dit script wordt de GUI opgeroepen, informatie van de gebruiker wordt ontvangen, 
het beslisschema wordt doorlopen en de conclusie wordt op een nieuw aangemaakt scherm getoond.

"""
#%%   Importeer te gebruiken classes en paketten.

import sys
import os
import datetime

#Voeg lokale folder toe voor hulpmethods
sys.path.insert(1, os.path.abspath('.'))

#Kijk nu ook in lokale folder naar hulpmethods.
#from dialog_window import GenericPicDialogCheck , GenericPicDialogRadio, Projectcode
from trees import Tree

#%%   Functies beslisstructuur
def profieleffecten(d_peil, Prof, Ing, eff):
    """Functie die een deel van de beslisstructuur bevat. Er wordt gekeken of een profielaanpassing een effect gaat hebben op de flux tussen kanaal en grondwater of niet.
    
    Parameters
    ----------        
    d_peil : string/boolean
        Het peil van het kanaal t.o.v de omgeving. Kan "hoger", "lager", of False zijn. In het laatste geval betekent het dat er geen peilverschil is (peilen zijn gelijk)
        
    Prof : instance
        De boomstructuur van het profiel.
    
    Ing : instance
        De boomstructuur van de te ondernemen ingrepen.
    
    eff : list
        Lijst waarin mogelijke effecten komen te staan.
    
    Returns
    -------
    eff : list
        Lijst waarin mogelijke effecten komen te staan. Nu misschien aangevuld met nieuwe effecten.
    """        
    
    isRunning = True
    
    while isRunning == True:
        if Ing.check_node('Profiel') == True:
    
            if d_peil == False and Ing.check_node('Peilwijziging') == False: break
    
            if Prof.check_node("OevAfd Dicht tot Klei") == True: break
    
            if Prof.check_node("OevAfd Dicht") == True and Prof.check_node("BodAfd Dicht") == True: break
         
            while True:
                if Ing.check_node('Verbreding') == True:
    
                    #if Prof.check_node('Oever') == False: break
    
                    if Prof.check_node('Oever Slib') == False: break              
                
                    else:
                        if d_peil == 'hoger':
                            eff.append(('Verbreding','Meer inzijging', 'permanent')) #als gevolg van een grotere doorlatendheid + infiltratieoppervlak
                        elif d_peil== 'lager':
                            eff.append(('Verbreding','Meer drainage', 'permanent')) #als gevolg van een grotere doorlatendheid + infiltratieoppervlak
                         
                break
    
    
            while True:
                if Ing.check_node('Verdieping') == True:
    
                    if Prof.check_node('Dik') == True: break
    
                    if Prof.check_node('Bodem') == False: break
                        
                    if Prof.check_node('BodAfd Dicht') == True: break
                    
                    else:
                        if d_peil == 'hoger':
                            eff.append(('Verdieping','Meer inzijging', 'permanent')) #als gevolg van een grotere doorlatendheid + infiltratieoppervlak
                        elif d_peil == 'lager':
                            eff.append(('Verdieping','Meer drainage', 'permanent')) #als gevolg van een grotere doorlatendheid + infiltratieoppervlak                      
                break
        isRunning = False
    return eff

def hulp_watereffecten(d_peil, Ing, eff):
    """Hulp functie bij de watereffecten functie. In deze functie wordt bij de genomen ingreep, een passend effect uitgezocht.
    
    Parameters
    ----------        
    d_peil : string/boolean
        Het peil van het kanaal t.o.v de omgeving. Kan "hoger", "lager", of False zijn. In het laatste geval betekent het dat er geen peilverschil is (peilen zijn gelijk)
    
    Ing : instance
        De boomstructuur van de te ondernemen ingrepen.
    
    eff : list
        Lijst waarin mogelijke effecten komen te staan.
    
    Returns
    -------
    eff : list
        Lijst waarin mogelijke effecten komen te staan. Nu misschien aangevuld met nieuwe effecten.        
    """
    watereff =     {'Peil kanaal omlaag':   ['Minder inzijging','Meer drainage'],
                    'Peil kanaal omhoog':   ['Meer inzijging','Minder drainage'],
                    'Peil omgeving omlaag': ['Meer inzijging','Minder drainage'],
                    'Peil omgeving omhoog': ['Minder inzijging','Meer drainage'],
                    'Peildynamiek':         ['Verandering peildynamiek omgeving','Verandering peildynamiek omgeving']}
        
    for ing in watereff.keys():
        if Ing.check_node(ing) == True:
            if d_peil == 'hoger':
                eff.append((ing,watereff[ing][0], 'permanent'))
            elif d_peil == 'lager':
                eff.append((ing,watereff[ing][1], 'permanent'))
            elif d_peil == False: #Als peil gelijk aan omgeving, dan bij verhoging meer inzijging en bij verlaging meer drainage.
                eff.append((ing,gelijk(watereff[ing]), 'permanent'))
    return eff

def watereffecten(d_peil, Prof, Ing, eff):
    """Functie die een deel van de beslisstructuur bevat. Er wordt gekeken of een profielaanpassing een effect gaat hebben op de flux tussen kanaal en grondwater of niet.
    
    Deze functie moet doorlopen worden nadat profieleffecten is doorlopen.
    
    Parameters
    ----------        
    d_peil : string/boolean
        Het peil van het kanaal t.o.v de omgeving. Kan "hoger", "lager", of False zijn. In het laatste geval betekent het dat er geen peilverschil is (peilen zijn gelijk)
        
    Prof : instance
        De boomstructuur van het profiel.
    
    Ing : instance
        De boomstructuur van de te ondernemen ingrepen.
    
    eff : list
        Lijst waarin mogelijke effecten komen te staan.
    
    Returns
    -------
    eff : list
        Lijst waarin mogelijke effecten komen te staan. Nu misschien aangevuld met nieuwe effecten.        
    """
    while True:
        if Ing.check_node('Peilwijziging') == True:
    
            ##Als er dichte bodem- en oeverweerstanden aanwezig zijn die niet doorgeprikt worden, geen effect onder voorwaarde.
            if (Prof.check_node('Oever') == True and Prof.check_node('Bodem') == True) and (Prof.check_node('BodAfd Semi') == False and Prof.check_node('OevAfd Semi') == False):
    
                ##Eerst check of er profielaanpassingen zijn gedaan. Hij zoekt in de effecten of deze de oorzaak zijn van bepaalde ingrepen.
                for i in eff:
                    if 'Profiel' in Ing.get_branch(i[0]): ##Dit moet aangepast worden voor alleen de profielaanpassingen die een weerstand lek kunnen prikken                                      
                        hulp_watereffecten(d_peil, Ing, eff)
                        break
                
                pass
            
            else:
                hulp_watereffecten(d_peil, Ing, eff)
    
        break
    return eff
#%%   Losse hulpfuncties

##The ExitFlag global variable is used to see whether the user has already closed the application or not.
ExitFlag = False

def checkclosed(parent, title, path, picfolder, dic, picext, chadio, toptext = "Maak uw keuze hieronder", **kwargs):   
    """Functie die zowel nieuwe windows creeerd als checked of the applicatie al gesloten is of niet. Verder biedt
    het de keuze voor een window met checkboxes (meerdere selecties) of een window met radio buttons (1 selectie).
    
    Parameters
    ----------
    ExitFlag : boolean
        Global variable. Flag geeft aan of het programma al afgesloten is of niet. 
    
    parent : instance 
        Parent window, of wel Tk() instance. Dit is in de gebruikte toepassing het "master" window.
        
    title : string
        Naam van het scherm. Komt in de title bar te staan.
    
    path : string
        Path naar de working directory.
    
    picfolder : string
        Naam van de folder waar de plaatjes in staan
    
    dic : dictionary
        Dictionary met 3 keys: 'tree_leaf', 'labels' en 'pictures'. Iedere key heeft een list van strings als value.
        
        In het geval van 'pictures' zijn deze strings de namen van de plaatjes in de folder.
        In het geval van 'tree_leaf' is dat welke tak in de boom aangemaakt moet worden (zie Tree() class) als er op het plaatje geklikt wordt.
        In het geval van 'labels' is dat een lijst met de beschrijvingen die bij de plaatjes horen Deze komen boven het plaatje te staan en in de rapportage aan het eind.
    
    picext : string
        De extensie van de plaatjes. Moet .gif zijn omdat deze GUI met het Anaconda pakket gemaakt is. 
        
        Deze ondersteunt alleen een oudere versie van de ImageClass van Tkinter, waarin alleen .gif ondersteunt wordt.
        .png plaatjes (tevens de enige bitmap die door Inkscape wordt ondersteunt) kunnen omgezet worden naar .gif 
        met een script wat als het goed is ook in deze folder staat. Dit hulpscript maakt gebruik van de PIL library.

    chadio : string
        Flag om aan te geven of je checkbuttons wil of radiobuttons. Moet 'check' of 'radio' zijn.
    
    toptext : string
        Tekst die bovenaan komt te staan, bijv. voor wat eenvoudige instructies. Deze komt vlak onder de title bar te staan.

    Returns
    -------
    d.result : string (radio) of list van strings (check)
        Geeft aan welke knop of knoppen er geselecteerd door de gebruiker. 
        
        Returnt de bijbehorende waarde in de tree_leaf in het in te voeren dictionary.
     
    d.label : string (radio) of list van strings (check)
        Bijbehorende beschrijving bij d.result.
     
    """
    
    if "description" in kwargs:
        desc = kwargs["description"]
    else:
        desc = ""
    
    if "thresh" in kwargs:
        thres = kwargs["thresh"]
    else:
        thres = 2

    
    global ExitFlag
    if ExitFlag:
        return '', ''
    if not ExitFlag:
        if chadio == "check":
            d = GenericPicDialogCheck(parent, title, path, picfolder, dic, picext, toptext, thresh = thres, description = desc,)
            if d.result == None:
                #parent.destroy()
                ExitFlag = True
                return d.result, []
            else:
                return d.result, d.label
        elif chadio == "radio":
            d = GenericPicDialogRadio(parent, title, path, picfolder, dic, picext, toptext, thresh = thres, description = desc)
            if d.result == None:
                #parent.destroy()
                ExitFlag = True
                return d.result, ''
            else:
                return d.result, d.label
        else: 
            raise ValueError("Please fill in 'check' or 'radio'")  

#Functie met simpel template voor message schem
def mes_temp(parent, topmessage, bottommessage, text):
    """Functie met simpel template voor een message scherm. Voegt ook tekst bij elkaar om een korte rapportage 
    te schrijven aan het eind.
    
    Parameters
    ----------
    parent : instance 
        Parent window, of wel Tk() instance. Dit is in de gebruikte toepassing het "master" window.    

    topmessage : string
        Tekst die in bold moet komen.
    
    bottommesage : string
        Tekst die in roman moet komen
    
    text : string
        Tekst die samengvoegd moet worden. Bedoeld voor rapportage.
    
    Returns
    -------
    text : string
        Tekst samengevoegd. Bedoeld voor rapportage
    """    
    global ExitFlag    
    if ExitFlag == False:    
        mes = Message(parent, text=topmessage, width = 500, font = ("Helvetica",9,"bold"), justify = 'left')
        mes.grid(sticky = "W")
        mes = Message(parent, text=bottommessage, width = 500, font = ("Helvetica",9,"roman"), justify = 'left')
        mes.grid(sticky = "W")
        text += '\n' + topmessage + '\n' + bottommessage
        return text

def gelijk(lijsteffect):
    """Functie die zoekt of er een effect met "Meer" in de lijst staat. 
    
    Parameters
    ----------
    lijsteffect : list
        Lijst met effecten die genereerd wordt gedurende het script
    
    x : string
        In het gebruik van dit script geeft aan of er meer inzijging komt of meer drainage door een ingreep.
    """
    
    #functie zoekt of er een effect met "Meer" in de lijst staat.
    for x in lijsteffect:
        if x.count('Meer') > 0:
            return x
        else: pass        


#%%De script routine start hier
if __name__ == '__main__':

#%%   Maak een boom aan voor alle mogelijke ingrepen
    Ingrepen = Tree()
    Ingrepen.add('Permanent>Water>Peilwijziging>Peil kanaal omhoog')
    Ingrepen.add('Permanent>Water>Peilwijziging>Peil kanaal omlaag')
    Ingrepen.add('Permanent>Water>Peilwijziging>Verandering Peildynamiek')
    Ingrepen.add('Permanent>Water>Debiet>Toename debiet')
    Ingrepen.add('Permanent>Water>Debiet>Afname debiet')
    Ingrepen.add('Permanent>Water>Peilwijziging>Peil omgeving omhoog')
    Ingrepen.add('Permanent>Water>Peilwijziging>Peil omgeving omlaag')
    Ingrepen.add('Permanent>Profiel>Oever>Verbreding')
    Ingrepen.add('Permanent>Profiel>Bodem>Verdieping')
    Ingrepen.add('Permanent>Profiel>Bodem>Verondieping')
    Ingrepen.add('Permanent>Profiel>Oever>Aanzanding')
    Ingrepen.add('Permanent>Contact Ondergrond>Aanleg Oeverconstructie')
    Ingrepen.add('Permanent>Contact Ondergrond>Damwand/Scherm')
    Ingrepen.add('Permanent>Contact Ondergrond>Oeverbekleding')
    Ingrepen.add('Permanent>Contact Ondergrond>Bodembedekking Slib/Klei')
    Ingrepen.add('Permanent>Contact Ondergrond>Injectie voor oeverweerstand')
    Ingrepen.add('Tijdelijk>Bouwput met bemaling')
    Ingrepen.add('Tijdelijk>Verdiepte ligging')
    Ingrepen.add('Tijdelijk>Zinktunnel')
    Ingrepen.add('Tijdelijk>Bouwkuip')
    Ingrepen.add('Tijdelijk>Tijdelijke peilwijziging')    
    
    #%%   Initialiseer GUI
    
    ##Create TK instance, a master window for the GUI.
    root = Tk()
    root.withdraw()  
    
    #%%   Projectcode opvragen
    code = Projectcode(root, "Projectcode")
    
    #%%   Ingrepen opvragen
    
    ##Create ingreep tree
    Ingreep = Tree()
    
    ##Maak relatief pad aan. Hij kijkt naar de folder waar het script/executable in staat.
    scrptpth = os.path.dirname(os.path.realpath(sys.argv[0]))
    
    folder = r"/Pictures/Ingreep/"
    ext = r".gif"
    title = "Ingreep"
    ttext = "Kies de te nemen ingreep/ingrepen hieronder:"
    
    ingdic = {"tree_leaf" : ["Verbreding","Verdieping","Peil kanaal omhoog", "Peil kanaal omlaag"],
               "pictures" : ["Verbreding","Verdieping","Peilverhoging","Peilverlaging"],
                "labels"  : ["Verbreding","Verdieping","Peil kanaal omhoog", "Peil kanaal omlaag"]}
    
    uitleg = "Meerdere ingrepen kunnen aangevinkt worden."
    
    
    situatie, inglabels = checkclosed(root, title, scrptpth, folder, ingdic, ext, "check", ttext, description = uitleg)
    
    ##Zoek tak op bij in boom van alle ingrepen en zet hem in de boom van de gekozen ingreep.
    if situatie is not None:
        for k in situatie:
            tak = Ingrepen.get_branch(k)
            Ingreep.add(tak+k)
    else:
        pass #root.destroy()
    
    #print('\n Boom van de gekozen ingrepen: \n')
    #print Ingreep
    
    #%%   Lijst aanmaken van mogelijke effecten die plaats kunnen vinden
    effecten = []
    
    #%% Profiel tree aanmaken
    
    Profiel = Tree()
    
    #%%   Oever kiezen
    
    folder = r"/Pictures/Profiel/Oever/"
    title = "Huidige situatie"
    ttext = "Kies het type oeverweerstand hieronder:"
    
    
    oevdic = {"tree_leaf" : ['','Oever>Oever Kleilaag','Oever>Oever Slib','Oever>Oever Afdichting'],
              "pictures" : ["OeverNiks","OeverKlei","OeverSlib","OeverConstr"],
                "labels" : ["Weerstandsloze oever","Oever in weerstandslaag", "Oever bedekt met slib", "Oeverconstructie aanwezig"]}
 
    uitleg = "Een weerstandslaag houdt in: een laag met meer dan 10 dagen weerstand. De weerstand valt te berekenen door de dikte van de laag te delen door de hydraulische doorlatendheid. \nVoorbeelden van mogelijke weerstandslagen zijn rotsformaties en grondsoorten als keileem, leem, klei, en verweerd veen."
    
    oev, oevlabel = checkclosed(root,title,scrptpth, folder, oevdic, ext, "radio", ttext, description = uitleg)
    
    if oev is not None:
        if len(oev) > 0:
            Profiel.add(oev)
    
    if oev is "Oever>Oever Afdichting":
        oevdic_afd = {"tree_leaf" : [">OevAFd Dicht", ">OevAFd Dicht tot Klei", ">OevAFd Semi"],
                      "pictures" : ["OeverConstr_Dicht", "OeverConstr_Dicht_Klei", "OeverConstr_Semi"],
                        "labels" : ["Ondoorlatende oeverconstructie \nreikt niet tot weerstandslaag \nin de ondergrond", "Ondoorlatende oeverconstructie \nreikt wel tot weerstandslaag \nin de ondergrond", "Semi-doorlatende \noeverconstructie"]}
        
        ttext = "Verdere specificaties oeverconstructie:"
        
        uitleg = "In het geval van een ondoorlatende oeverafdichting is het van groot belang of deze tot een weerstandslaag reikt of niet."
        
        oev_afd, oevlabel_afd = checkclosed(root, title, scrptpth, folder, oevdic_afd, ext, "radio", ttext, description = uitleg)
        oevlabel = oevlabel_afd    

        
        if oev_afd is not None:
            if len(oev_afd) > 0:
                Profiel.add(oev + oev_afd)
    
    #%%   Bodem kiezen
    
    folder = r"/Pictures/Profiel/Bodem/"
    ttext = "Kies het type kanaalbodemweerstand hieronder:"
    
    boddic = {"tree_leaf" : ['', 'Bodem>Bodem Kleilaag', 'Bodem>Bodem Slib','Bodem>Bodem Afdichting'],
              "pictures" : ['BodemNiks','BodemKleiDik','BodemSlib','BodemAfd'],
                "labels" : ["Weerstandsloze kanaalbodem","Weerstandslaag onder bodem","Slib op de bodem","Bodem met afdichting"]}
    
    uitleg = "Een weerstandslaag houdt in: een laag met meer dan 10 dagen weerstand. De weerstand valt te berekenen door de dikte van de laag te delen door de hydraulische doorlatendheid. \nVoorbeelden van mogelijke weerstandslagen zijn rotsformaties en grondsoorten als keileem, leem, klei, en verweerd veen."    
    
    bod, bodlabel = checkclosed(root,title,scrptpth, folder, boddic, ext, "radio", ttext, description = uitleg)
    
    if bod is not None:
        if len(bod) > 0:
            Profiel.add(bod)
    
    if bod is "Bodem>Bodem Kleilaag":
        boddic_dek = {"tree_leaf" : ['>Dik', '>Dun'],
                      "pictures" : ['BodemKleiDik','BodemKleiDun'],
                        "labels" : ["Dikke weerstandslaag","Dunne weerstandslaag"]}
    
        ttext = "Is de weerstandslaag onder de kanaalbodem dik of dun?"

        uitleg = "Deze specificatie is voornamelijk belangrijk in het geval van een verdieping. Een dikke weerstandslaag houdt in dat er, na verdieping, nog 10 dagen weerstand onder de kanaalbodem over blijft. Een dunne weerstandslaag dat er minder dan 10 dagen weerstand overblijft."
    
        bod_dek, bodlabel_dek = checkclosed(root,title,scrptpth, folder, boddic_dek, ext, "radio", ttext, description = uitleg, thresh = 1)
        bodlabel = bodlabel_dek
    
        if bod_dek is not None:
            if len(bod_dek) > 0:
                Profiel.add(bod+bod_dek)
    
    if bod is "Bodem>Bodem Afdichting":
        boddic_afd = {"tree_leaf" : ['>BodAfd Dicht>Onbeslagen', '>BodAfd Dicht>Beslagen', '>BodAfd Semi>Onbeslagen', '>BodAfd Semi>Beslagen'],
                      "pictures" : ['BodemAfd','BodemAfd_Bezw','BodemAfdSemi','BodemAfdSemi_Bezw'],
                        "labels" : ["Onbeslagen, \ndichte bodemconstructie","Beslagen, \ndichte bodemconstructie","Onbeslagen, semi-\ndoorlatend bodemconstructie","Beslagen, semi-\ndoorlatend bodemconstructie"]}
    
        ttext = "Verdere specificaties bodem afdichting:"

        uitleg = "Een beslagen bodemafdichting houdt in dat er maatregelen getroffen zijn tegen opbarsting. Een grotere flux naar het kanaal (meer drainage) resulteert in een kans op opbarsting."    

        bod_afd, bodlabel_afd = checkclosed(root,title,scrptpth, folder, boddic_afd, ext, "radio", ttext, description = uitleg)
        bodlabel = bodlabel_afd
    
        if bod_afd is not None:
            if len(bod_afd) > 0:
                Profiel.add(bod+bod_afd)
    
    #print Profiel
    #%%   Peilverschil checken
    
    folder = r"/Pictures/Peilverschil/"
    
    testdic = {"tree_leaf" : ["hoger","lager",False],
               "pictures"  : ["PeilHoog","PeilLaag","PeilGelijk"],
                "labels"   : ["Peil hoger dan omgeving", "Peil lager dan omgeving", "Peil gelijk aan omgeving"]}
    
    ttext = "Specificeer het kanaalpeil t.o.v. het omgevingspeil"

    uitleg = "Kies hierboven hoe, in de huidige situatie, het kanaalpeil zich verhoudt tot het peil in de omgeving."
    
    peilverschil, peillabel = checkclosed(root, title, scrptpth, folder, testdic, ext, "radio", ttext, description = uitleg)
    
    
    #%%   Hier vindt de kern plaats van het bepalen plaats of de ingreep invloed gaat hebben op de grondwaterstand of niet.

    ###Het is van belang dat eerst profieleffecten wordt aangeroepen, en daarna pas watereffecten!
    effecten = profieleffecten(peilverschil,Profiel,Ingreep,effecten)
    effecten = watereffecten(peilverschil,Profiel,Ingreep,effecten)
    #print(effecten)
    
    #%%   Destroy GUI
    
    root.destroy()
    
    #%%   Rapport met keuzes, effecten en risico's opstellen en doorgeven.
    ##Genereer de berichten als het root scherm niet voortijdig afgesloten is.
    if ExitFlag == False:
        
        tekst = ''    
        
        #Stop de gekozen ingreep in een bericht
        ingmes_top = "De volgende ingrepen zijn gekozen:"
        ingmes_bot = ''
        for i in inglabels: 
            ingmes_bot += "-" + i + "\n"
        
        #Het gekozen profiel in een bericht
        oev_top = "De volgende oeverweerstand is gekozen:"
        oev_bot = oevlabel 
        if Profiel.check_node("Oever Kleilaag"):
            oev_bot += " (meer dan 10 dagen weerstand aanwezig)"
        oev_bot += "\n"
        
        bod_top = "De volgende bodemweerstand is gekozen:"
        bod_bot = bodlabel 
        if Profiel.check_node("Dik"):
            bod_bot += " (meer dan 10 dagen weerstand onder kanaalbodem aanwezig na ingreep)"
        if Profiel.check_node("Dun"):
            bod_bot += " (minder dan 10 dagen weerstand onder kanaalbodem aanwezig na ingreep)"
        bod_bot += "\n"
    
        #Het gekozen peilverschil in een bericht
        peil_top = "Het volgende peilverschil is gekozen:"
        peil_bot = peillabel + "\n"
        
        #De resulterende effecten in een bericht
        eff_top = "De resulterende effecten zijn:"
        eff_bot = ''
        
        if len(effecten) == 0:
            eff_bot += "De ingreep zal geen effect hebben op het grondwater in de omgeving \n"
        else:
            for i in effecten:
                eff_bot += "Er komt " + i[2] + ' ' + i[1].lower() + " door ingreep:  '" + i[0].lower() + "'\n"
            eff_bot += "\n \tRaadpleeg een adviseur over de grootte van de effecten en hun schaal. \n"
        
        #De risico's die deze effecten met zich meebrengen in een bericht
        riskdic = {'R1' : 'Grondwateroverlast in de omgeving door hogere grondwaterstanden.',
                   'R2' : 'Schade bebouwing in de  omgeving door een verlaging van de grondwaterstand.',
                   'R3' : 'Verslechtering waterkwaliteit omgeving.',
                   'R4' : 'Verplaatsing van het verspreidingsgebied van een grondwaterverontreiniging in de omgeving.',
                   'R5' : 'Extra aanvoer van water naar het kanaal nodig om het peil te handhaven.',
                   'R6' : 'Droogte door verlaging van de grondwaterstand, kan schadelijk zijn voor gewassen en/of natuur.'}
        
        riskmes_top = "De volgende risico's worden verwacht:"
        riskmes_bot = ''
        
        if len(effecten) == 0:
            riskmes_bot += "Er wordt geen effect van de ingreep verwacht \n"
        else:
            if any(i[1].lower() in ('meer inzijging','minder drainage') for i in effecten):
            #Als er "meer inzijging" of "minder drainage" in effecten staat, doe dan slechts 1 keer:
                riskmes_bot += '-' + riskdic['R1'] + '\n'
            if any(i[1].lower() in ('meer inzijging') for i in effecten):
                riskmes_bot += '-' + riskdic['R3'] + '\n'
                riskmes_bot += '-' + riskdic['R4'] + '\n'
                riskmes_bot += '-' + riskdic['R5'] + '\n'
            if any(i[1].lower() in ('minder inzijging', 'meer drainage') for i in effecten):
                riskmes_bot += '-' + riskdic['R2'] + '\n'
                riskmes_bot += '-' + riskdic['R6'] + '\n'
            if any(i[1].lower() in ('meer drainage') for i in effecten):   
                riskmes_bot += '-' + riskdic['R4'] + '\n'
                if Profiel.check_node('Oever Slib') == True or Profiel.check_node('Bodem Slib') == True or Profiel.check_node("Onbeslagen"):
                    riskmes_bot += ' \n \tEr bestaat tevens de kans dat, door de grotere drainage, \n \ter opbarsting van aanwezig slib of de onbeslagen bodemafdichting kan\n \toptreden, wat weer leidt tot een nog grotere drainage. \n'
    
        
        #De maatregelen die genomen kunnen worden in een bericht
        miti_top = 'Mogelijke maatregelen hiertegen zijn:'
        
        miti_bot = ''
        
        if len(effecten) == 0:
            miti_bot += 'Er hoeven geen maatregelen genomen te worden\n'
        else:
            if any(i[1].lower() in ('meer drainage','meer inzijging') for i in effecten) == True and any(i[1].lower() in ('minder drainage','minder inzijging') for i in effecten) == True:
                miti_bot += 'Er worden tegengestelde effecten verwacht. Raadpleeg een adviseur om uit te zoeken welk effect zal domineren. \n'
            
            else:
                if any(i[1].lower() in ('meer inzijging','meer drainage') for i in effecten):
                #Als er "meer inzijging" of "meer drainage" in effecten staat, doe dan slechts 1 keer:
                    miti_bot += 'Weerstandsvermeerdering:'
                    miti_bot += '\n\t-Schermen plaatsen die reiken tot weerstandslaag in de ondergrond'
                    miti_bot += '\n\t-Injectie van een weerstand'
                    miti_bot += '\n\t-Dichte bodem- en oeverconstructie aanleggen'
                
                if any(i[1].lower() in ('meer drainage',) for i in effecten):                
                    miti_bot += ', let op dat deze beslagen moet zijn vanwege het risico op opbarsting.'
                
                if any(i[1].lower() in ('meer inzijging',) for i in effecten):
                    miti_bot += '\n\t-Indien er een sedimentatieregime aanwezig is: slib opbrengen'
                
                if any(i[1].lower() in ('meer inzijging','meer drainage') for i in effecten):             
                    miti_bot += '\n\nPeilverschilsvermindering:'
                    if Ingreep.check_node("Peil kanaal omhoog") == False and Ingreep.check_node("Peil kanaal omlaag") == False:
                        miti_bot += '\n\t-Peil kanaal aanpassen'
                    
                    if Ingreep.check_node("Peil omgeving omhoog") == False and Ingreep.check_node("Peil omgeving omlaag") == False:
                        miti_bot += '\n\t-Peil omgeving aanpassen'
                        
                if any(i[1].lower() in ('minder drainage','minder inzijging') for i in effecten):
                    miti_bot += 'Weerstandvermindering:'
                    if Profiel.check_node("Bodem Kleilaag") == True or Profiel.check_node("Oever Kleilaag") == True:
                        miti_bot += '\n\t-Weerstandslagen afgraven'
                    if Profiel.check_node("Bodem Afdichting") == True or Profiel.check_node("Oever Afdichting") == True:
                        miti_bot += '\n\t-Oever- of bodemconstructies verwijderen'
                    if Profiel.check_node("Oever Slib") == True or Profiel.check_node("Bodem Slib") == True:
                        miti_bot += '\n\t-Baggeren'
                    
                    miti_bot += '\n\nPeilverschilvergroting:'
                    if Ingreep.check_node("Peil kanaal omhoog") == False and Ingreep.check_node("Peil kanaal omlaag") == False:
                        miti_bot += '\n\t-Peil kanaal aanpassen'
                    if Ingreep.check_node("Peil omgeving omhoog") == False and Ingreep.check_node("Peil omgeving omlaag") == False:
                        miti_bot += '\n\t-Peil omgeving aanpassen'
            
    
        #Genereer het message scherm
        root2 = Tk()
        
        #Voeg alle berichten samen in dit message scherm
        tekst = mes_temp(root2,ingmes_top, ingmes_bot, tekst)
        tekst = mes_temp(root2,oev_top, oev_bot, tekst)
        tekst = mes_temp(root2,bod_top, bod_bot, tekst)
        tekst = mes_temp(root2,peil_top,peil_bot, tekst)
        tekst = mes_temp(root2,eff_top,eff_bot, tekst)
        tekst = mes_temp(root2,riskmes_top,riskmes_bot, tekst)
        tekst = mes_temp(root2,miti_top,miti_bot, tekst)
        
        mainloop()
    
        #Vind tijd om toe te voegen in de naam van de rapportage file    
        nu = datetime.datetime.now()
        nu_str = nu.strftime("%Y-%m-%d__%H_%M")
                
        
        #Schrijf tekst in rapportage, die opgeslagen wordt in een .txt bestand in de working directory.
        rapport = open('rapportage_'+code.result+ "___" + nu_str + '.txt', 'w')
        rapport.write(tekst)
        rapport.close()
