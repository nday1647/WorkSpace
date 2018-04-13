import numpy as np

def Opennpz(filename):
    BPdata = np.load(filename)
    Firsttime = BPdata.f.fistsignal - 20/500.0
    Stim = BPdata.f.mark
    Data = BPdata.f.signal
    StiminSignal = np.zeros([Data.shape[0],2])
    for i in range(Data.shape[0]):
        StiminSignal[i,0] = Firsttime + i/500.0
    for i in range(1,Stim.shape[0]):
        index = int((Stim[i,0] - Firsttime) * 500)
        if(StiminSignal[index, 1] == 0):
            StiminSignal[index, 1] = Stim[i,1]
        else:
            StiminSignal[index+1, 1] = Stim[i, 1]
    return Data , StiminSignal
APData ,APStim= Opennpz('NSsignal_2018_04_10_19_34_41.npz')
#Data = np.zeros([APSignal.shape[0],APSignal.shape[1]+APData.shape[1] + 3])
#Data[0:Data.shape[0],0] = APSignal[0:APSignal.shape[0],0]
#for i in range(APSignal.shape[0]):
    #Data[i][1] = i//20
#Data[0:Data.shape[0],2:2+APData.shape[1]] = APData
#Data[0:Data.shape[0],2+APData.shape[1]] = APSignal[0:APSignal.shape[0],1]
#np.savetxt('data1.csv', Data, delimiter = ',')