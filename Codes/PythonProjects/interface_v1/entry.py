import wx
import wx.adv as wxadv

from Graz import *
from nsDataServer import *
from main import *

app = wx.App()
win = MainWindow()
win.Show()
print('Ready')
app.MainLoop()
