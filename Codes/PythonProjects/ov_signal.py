# -*- coding: utf-8 -*-
import numpy as np
import sys
import pickle
sys.path.append("D:\Myfiles\WorkSpace\Codes\PythonProjects")
from TrainModel import TrainModel



# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
    def __init__(self):
        OVBox.__init__(self)
        # we add a new member to save the signal header information we will receive
        self.signalHeader = None
        # self.signal_trial = None
        self.signal_label = None
        self.signal_stim = None
        self.signal_start = None
        self.signal_latest = None
        self.csp_ProjMatrix = None
        self.svm_model = None
        self.a = None
        self.trained = False
    # this time we also re-define the initialize method to directly prepare the header and the first data chunk
    # 初始化
    def initialize(self):
        print('Initializing Python Box')
        self.signal_label = []
        self.signal_trial = []
        self.signal_stim = []
        self.output[0].append(OVStimulationHeader(0., 0.))

    # The process method will be called by openvibe on every clock tick
    #  循环调用
    def process(self):
        chunkNum = len(self.input[0])
        if self.signal_latest != None and chunkNum == 0 and self.getCurrentTime() - self.signal_latest > 10:
            self.appendStopStimulation()
        # we iterate over all the input chunks in the input signal buffer 遍历输入信号缓冲区中的所有输入块
        for chunkIndex in range(chunkNum):
            chunk = self.input[0].pop();
            if (type(chunk) == OVSignalHeader):
                self.signalHeader = chunk
                self.signal_start = chunk.startTime
                self.signal = np.empty(shape=[self.signalHeader.dimensionSizes[0], 0])
                print('Data chunk size:' + str(self.signalHeader.dimensionSizes))
            # if it's a buffer we pop it and put it in a numpy array at the right dimensions
            elif (type(chunk) == OVSignalBuffer):
                npBuffer = np.array(chunk).reshape(
                    tuple(self.signalHeader.dimensionSizes))
                self.signal = np.concatenate((self.signal, npBuffer), axis=1)
            # if it's a end-of-stream we just forward that information to the output
            elif (type(chunk) == OVSignalEnd):
                print('Data Read Finished')
            self.signal_latest = self.getCurrentTime()


        for stimIndex in range(len(self.input[1])):
            stim = self.input[1].pop()
            if (type(stim) != OVStimulationHeader):
                for i in range(len(stim)):
                    if (stim[i].identifier == 32770):
                        self.train()
						# Call data process function. Data in var signal
                        self.trained = True
                        self.appendStopStimulation()
                    else:
						self.signal_stim.append((stim[i].identifier,stim[i].date,stim[i].duration))


        # this time we also re-define the uninitialize method to output the end chunk.
    def uninitialize(self):
        if (self.trained == False):
            self.train()
        end = self.getCurrentTime()
        # self.output[0].append(OVStimulationEnd(end, end))
        # print('Size of signal: ' + str(len(self.signal_trial)))
        # print(str(self.signal_trial[12].shape) + str(self.signal_trial[13].shape))
        self.output[0].append(OVStimulationEnd(end, end))
        print(self.signal_label)
        print('Uninitializing Python Box')

    def appendStopStimulation(self):
        stimSet = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime() + 1. / self.getClock())
        stimSet.append(OVStimulation(0x00008207, self.getCurrentTime(), 0))
        self.output[0].append(stimSet)

    def train(self):
		# TODO: Signal Epoching base on Stimulation
		# Using signal_start, signal, singal_stim[id,date,duration] in self
        trialsize = 0
        for stim in self.signal_stim:
            if stim[0] == 769 or stim[0] == 770:
                trialsize = trialsize + 1
        print("trial_size:"+str(trialsize))
        Fs = self.signalHeader.samplingRate
        width = 500
        overlap = 0.5
        length = 2500
        window_num = int((length-width)/((1-overlap)*width) + 1)
        j = 0
        signal3d = np.zeros([width, self.signal.shape[0], trialsize*window_num])
        for stim in self.signal_stim:
            if stim[0] == 769 or stim[0] == 770:
                pos = int((stim[1] - self.signal_start)/(1.0/Fs))
                for i in range(window_num):
                    self.signal_label.append(stim[0] - 769)
                    start = int(pos+i*((1-overlap)*width))
                    signal3d[:, :, j] = np.transpose(self.signal[:, start:start+width])
                    j = j + 1
        print(str(signal3d.shape))
        self.csp_ProjMatrix, self.svm_model = TrainModel(signal3d, self.signal_label)
        output = open('D:\Myfiles\WorkSpace\Codes\PythonProjects\model.pkl', 'wb')
        pickle.dump(self.csp_ProjMatrix, output)
        pickle.dump(self.svm_model, output)
        output.close()
        print('CSP: ' + str(self.csp_ProjMatrix.shape))


# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
