# we use numpy to compute the mean of an array of values
import numpy as np
import sys
import pickle
import serial
import time
from Filter import BPFilter
from CSP import CSPSpatialFilter
from SVM import SVMPredict
sys.path.append("D:\Myfiles\WorkSpace\Codes\PythonProjects")



# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
    def __init__(self):
        OVBox.__init__(self)
        # we add a new member to save the signal header information we will receive
        self.signalHeader = None
        self.signal_trial = None
        self.signal_label = None
        self.csp_ProjMatrix = None
        self.svm_model = None
        self.a = None
        self.t = None

    # this time we also re-define the initialize method to directly prepare the header and the first data chunk
    def initialize(self):
        print('Initializing Python Box')
        try:
            self.t = serial.Serial('COM5', 115200)
        except Exception, e:
            print 'open serial failed.'
    # The process method will be called by openvibe on every clock tick
    def process(self):
        # we iterate over all the input chunks in the input signal buffer
        for chunkIndex in range(len(self.input[0])):
            if (type(self.input[0][chunkIndex]) == OVSignalHeader):
                self.signal_trial = []
                self.signal_label = []
                self.signalHeader = self.input[0].pop()
                self.signal = np.empty(shape=[self.signalHeader.dimensionSizes[0], 0])
                print('Data chunk size:' + str(self.signalHeader.dimensionSizes))
            # if it's a buffer we pop it and put it in a numpy array at the right dimensions
            elif (type(self.input[0][chunkIndex]) == OVSignalBuffer):
                chunk = self.input[0].pop()
                npBuffer = np.array(chunk).reshape(
                    tuple(self.signalHeader.dimensionSizes))
                self.signal = np.concatenate((self.signal, npBuffer), axis=1)
            # if it's a end-of-stream we just forward that information to the output
            elif (type(self.input[0][chunkIndex]) == OVSignalEnd):
                print('Data Read Finished')
        for stimIndex in range(len(self.input[1])):
            stim = self.input[1].pop()
            if (type(stim) != OVStimulationHeader):
                for i in range(len(stim)):
                    if (stim[i].identifier == 769 or stim[i].identifier ==770):
                        self.signal_label.append(stim[i].identifier - 769)
                        self.signal = np.empty(shape=[self.signalHeader.dimensionSizes[0], 0])
                    elif(stim[i].identifier == 800):
                        #self.signal_trial.append(self.signal)
                        signal_onetiral = np.transpose(self.signal)
                        input = open('D:\Myfiles\WorkSpace\Codes\PythonProjects\model.pkl','rb')
                        csp_ProjMatrix = pickle.load(input)
                        svm_model = pickle.load(input)

                        Fs = 500
                        filter_low = 8
                        filter_high = 30

                        AfterFilter_test_x = BPFilter(signal_onetiral, Fs, filter_low, filter_high)
                        AfterCSP_test_x = CSPSpatialFilter(AfterFilter_test_x, csp_ProjMatrix)
                        predict = SVMPredict(svm_model, AfterCSP_test_x)

                        self.t.write(str(predict[0]))
                        print(str(predict[0]))
                        time.sleep(1)

                        # TODO: Call data process function. Data in var signal
                        stimSet = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime() + 1. / self.getClock())
                        stimSet.append(OVStimulation(0x00008207, self.getCurrentTime(), 0))
                        #self.output[0].append(stimSet)

        # this time we also re-define the uninitialize method to output the end chunk.
    def uninitialize(self):
         end = self.getCurrentTime()
          #self.output[0].append(OVStimulationEnd(end, end))

         print('Uninitializing Python Box')
         # print(os.getcwd())
         self.t.close()



# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
