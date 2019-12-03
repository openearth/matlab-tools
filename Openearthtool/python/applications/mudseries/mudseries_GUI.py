# -*- coding: utf-8 -*-
"""
Created on Fri Aug 11 14:01:45 2017

- Simple GUI to launch mudseries.py

@authors:
Joan Sala Calero (joan.salacalero@deltares.nl)
"""

import sys
import os
import Tkinter
import logging
from tkFileDialog import askopenfilename, askdirectory
from mudseries import Mudseries


class simpleapp_tk(Tkinter.Tk):
    def __init__(self, parent):
        Tkinter.Tk.__init__(self, parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        self.grid()
        self.dir = '.'

        # Label configuration file
        self.labelVariable1 = Tkinter.StringVar()
        label1 = Tkinter.Label(
            self, textvariable=self.labelVariable1, anchor="w", fg="white", bg="darkblue")
        label1.grid(column=0, row=0, columnspan=2, sticky='EW')
        self.labelVariable1.set(u"Please select a configuration file")
        button = Tkinter.Button(self, text=u" ... ",
                                command=self.OnButtonClick1)
        button.grid(column=1, row=0)

        # Label mask file
        self.labelVariable2 = Tkinter.StringVar()
        label2 = Tkinter.Label(
            self, textvariable=self.labelVariable2, anchor="w", fg="white", bg="darkgreen")
        label2.grid(column=0, row=1, columnspan=2, sticky='EW')
        self.labelVariable2.set(u"Please select a white mask file")
        button = Tkinter.Button(self, text=u" ... ",
                                command=self.OnButtonClick2)
        button.grid(column=1, row=1)

        # Select input directory
        self.labelVariable0 = Tkinter.StringVar()
        label0 = Tkinter.Label(
            self, textvariable=self.labelVariable0, anchor="w", fg="white", bg="darkred")
        label0.grid(column=0, row=2, columnspan=2, sticky='EW')
        self.labelVariable0.set(u"Please select an input directory")
        button = Tkinter.Button(self, text=u" ... ",
                                command=self.OnButtonClick3)
        button.grid(column=1, row=2)

        # Select output directory
        self.labelVariable3 = Tkinter.StringVar()
        label3 = Tkinter.Label(
            self, textvariable=self.labelVariable3, anchor="w", fg="white", bg="darkred")
        label3.grid(column=0, row=3, columnspan=2, sticky='EW')
        self.labelVariable3.set(u"Please select an output directory")
        button = Tkinter.Button(self, text=u" ... ",
                                command=self.OnButtonClick3)
        button.grid(column=1, row=3)

        # Run button
        button = Tkinter.Button(self, text=u"            RUN script            ",
                                command=self.runScript, bg="black", fg="white")
        button.grid(column=0, row=4)

        # Finalize GUI
        self.grid_columnconfigure(0, weight=1)
        self.resizable(width=False, height=False)
        self.geometry('{}x{}'.format(900, 130))
        self.update()
        self.geometry(self.geometry())

    def OnButtonClick1(self):
        path = askopenfilename(title="Please select a config file", filetypes=(
            ("Mudseries config txt", "*.txt"), ("All files", "*.*")))
        if not(path is None) and len(path):
            self.labelVariable1.set(path)

    def OnButtonClick2(self):
        path = askopenfilename(title="Please select a mask file", filetypes=(
            ("Mudseries white mask JPG", "*mask*.jpg"), ("All files", "*.*")))
        if not (path is None) and len(path):
            self.labelVariable2.set(path)
            self.dir = os.path.dirname(path)
            self.labelVariable0.set(self.dir)
            self.labelVariable3.set(self.dir)

    def OnButtonClick0(self):
        path = askdirectory(title="Please select an input directory")
        if not (path is None) and len(path):
            self.labelVariable0.set(path)

    def OnButtonClick3(self):
        path = askdirectory(title="Please select an output directory")
        if not (path is None) and len(path):
            self.labelVariable3.set(path)

    def runScript(self):
        idir = self.labelVariable0.get()
        conf = self.labelVariable1.get()
        mask = self.labelVariable2.get()
        odir = self.labelVariable3.get()

        # Error check
        if os.path.exists(conf) and os.path.exists(mask) and os.path.exists(odir):
            m = Mudseries(conf, mask, idir, odir)
            msg = m.check_inputs()
            if len(msg) == 0:
                m.prepare()
                m.run()
            else:
                logging.error(msg)
        else:
            logging.error("You need to fill in all the required parameters")


if __name__ == "__main__":
    app = simpleapp_tk(None)
    app.title('- MudSeries 1.0 -')
    app.mainloop()
