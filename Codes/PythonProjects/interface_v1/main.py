import wx

from Graz import *
from nsDataServer import *
from lslDataServer import *


class MainWindow(wx.Frame):
    def __init__(self):
        super(MainWindow, self).__init__(None, title="Main", size=(480, 640))
        self.SetWindowStyle(wx.DEFAULT_FRAME_STYLE & ~(
            wx.RESIZE_BORDER | wx.MAXIMIZE_BOX))
        self.Centre()
        self.initUI()
        self.OnReset(None)
        self.Fit()

        self.resetBtn.Bind(wx.EVT_BUTTON, self.OnReset)
        self.okBtn.Bind(wx.EVT_BUTTON, self.OnOk)
        self.dataServer = None

    def initUI(self):
        self.DestroyChildren()
        panel = wx.Panel(self)

        gs = wx.FlexGridSizer(cols=2, vgap=10, hgap=10)
        stimSet = ['OVTK_GDF_Left', 'OVTK_GDF_Right',
                   'OVTK_GDF_Down', 'OVTK_GDF_Up']
        imgWildcard = "Image File (.gif, .bmp, .jpg, .png)" + \
            "|*.gif;*.bmp;*.jpg;*.png"

        self.firstClassCtrl = wx.Choice(
            panel, name="First Class", choices=stimSet)
        self.firstClassCtrl.SetSelection(0)
        label = wx.StaticText(panel)
        label.SetLabel("First Class Stimulation")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.firstClassCtrl, 0, wx.ALL, 5)

        self.firstClassNumCtrl = wx.SpinCtrl(panel, value='10', min=0, max=20)
        label = wx.StaticText(panel)
        label.SetLabel("First Class Stimulation Number")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.firstClassNumCtrl, 0, wx.ALL, 5)

        self.customFirstClassCtrl = wx.FilePickerCtrl(
            panel, wildcard=imgWildcard)
        label = wx.StaticText(panel)
        label.SetLabel("First Class Custom Cue")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.customFirstClassCtrl, 0, wx.ALL, 5)

        self.secondClassCtrl = wx.Choice(
            panel, name="Second Class", choices=stimSet)
        self.secondClassCtrl.SetSelection(1)
        label = wx.StaticText(panel)
        label.SetLabel("Second Class Stimulation")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.secondClassCtrl, 0, wx.ALL, 5)

        self.secondClassNumCtrl = wx.SpinCtrl(panel, value='10', min=0, max=20)
        label = wx.StaticText(panel)
        label.SetLabel("Second Class Stimulation Number")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.secondClassNumCtrl, 0, wx.ALL, 5)

        self.customFirstClassCtrl = wx.FilePickerCtrl(
            panel, wildcard=imgWildcard)
        label = wx.StaticText(panel)
        label.SetLabel("First Class Custom Cue")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.customFirstClassCtrl, 0, wx.ALL, 5)

        self.baselineCtrl = wx.SpinCtrl(panel, value='10', min=0, max=20)
        label = wx.StaticText(panel)
        label.SetLabel("Baseline Duration (sec)")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.baselineCtrl, 0, wx.ALL, 5)

        self.waitCueCtrl = wx.SpinCtrl(panel, value='2', min=0, max=10)
        label = wx.StaticText(panel)
        label.SetLabel("Waiting For Cue Duration (sec)")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.waitCueCtrl, 0, wx.ALL, 5)

        self.dispCueCtrl = wx.SpinCtrl(panel, value='4', min=0, max=20)
        label = wx.StaticText(panel)
        label.SetLabel("Display Cue Duration (sec)")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.dispCueCtrl, 0, wx.ALL, 5)

        self.feedbackCtrl = wx.SpinCtrl(panel, value='4', min=0, max=20)
        label = wx.StaticText(panel)
        label.SetLabel("Feedback Duration (sec)")
        gs.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 10)
        gs.Add(self.feedbackCtrl, 0, wx.ALL, 5)

        self.resetBtn = wx.Button(panel, label="Reset", size=wx.Size(72, 36))
        self.okBtn = wx.Button(panel, label="OK", size=wx.Size(72, 36))
        gs.Add(self.okBtn, 0, wx.ALL, 20)
        gs.Add(self.resetBtn, 0, wx.ALL, 20)

        panel.SetSizerAndFit(gs)
        panel.Center()
        self.Fit()

    def OnOk(self, event):
        firstClass = self.firstClassCtrl.GetCurrentSelection()
        firstClass = self.firstClassCtrl.GetString(firstClass)
        firstClassNum = self.firstClassNumCtrl.GetValue()
        secondClass = self.secondClassCtrl.GetCurrentSelection()
        secondClass = self.secondClassCtrl.GetString(secondClass)
        secondClassNum = self.secondClassNumCtrl.GetValue()
        baseline = self.baselineCtrl.GetValue()
        waitCue = self.waitCueCtrl.GetValue()
        dispCue = self.dispCueCtrl.GetValue()
        feedback = self.feedbackCtrl.GetValue()

        self.graz = Graz(self)
        self.stim = MIStimulator(self.graz,
                                 first_class=firstClass,
                                 number_of_first_class=firstClassNum,
                                 second_class=secondClass,
                                 number_of_second_class=secondClassNum,
                                 baseline_duration=baseline,
                                 wait_for_cue_duration=waitCue,
                                 display_cue_duration=dispCue,
                                 feedback_duration=feedback)
        self.dataServer = nsDataServer(self)
        msg = "Graz Stimulator is Ready!\n" + \
            "Total Time of the Session is: " + \
            str(self.stim.T)+"s\n"+"Start Now?"
        style = wx.OK | wx.CANCEL | wx.CENTRE
        msgbox = wx.MessageDialog(self, msg, "Experiment is Ready", style)
        if(msgbox.ShowModal() == wx.ID_OK):
            self.graz.Show()
            self.graz.startStim()
            if self.dataServer:
                self.dataServer.configure()
                if(not self.dataServer.connected):
                    self.dataServer.start()
        else:
            return

    def OnReset(self, event):
        self.initUI()

    def setDataServer(self, dataServer=None):
        self.dataServer = dataServer

    def grazFinish(self):
        if self.dataServer:
            self.dataServer.stop()
            print('Saving Signal...')
            self.dataServer.saveData()
            print('Signal Saved')
