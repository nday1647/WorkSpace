# we use numpy to compute the mean of an array of values
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
        self.signal_trial = None
        self.signal_label = None
        self.csp_ProjMatrix = None
        self.svm_model = None
        self.a = None


    # this time we also re-define the initialize method to directly prepare the header and the first data chunk
    def initialize(self):
        print('Initializing Python Box')

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
                    if (stim[i].identifier == 32770):
                        signal3d = np.zeros([self.signal_trial[1].shape[1],self.signal_trial[1].shape[0],len(self.signal_trial)])
                        for j in range(len(self.signal_trial)):
                            print(j)
                            for k in range(self.signal_trial[1].shape[0]):
                                for l in range(self.signal_trial[1].shape[1]):
                                    if(l < self.signal_trial[j].shape[1]):
                                        signal3d[l, k, j] = self.signal_trial[j][k, l]
                        print('signal done!!!!!!!!!!!!!!!!')
                        self.csp_ProjMatrix, self.svm_model = TrainModel(signal3d, self.signal_label)
                        output = open('D:\Myfiles\WorkSpace\Codes\PythonProjects\model.pkl','wb')
                        pickle.dump( self.csp_ProjMatrix,output)
                        pickle.dump(self.svm_model, output)
                        output.close()
                        print('CSP: ' + str(self.csp_ProjMatrix.shape))

                    elif (stim[i].identifier == 769 or stim[i].identifier ==770):
                        self.signal_label.append(stim[i].identifier - 769)
                        self.signal = np.empty(shape=[self.signalHeader.dimensionSizes[0], 0])
                    elif(stim[i].identifier == 800):
                        self.signal_trial.append(self.signal)
                        # TODO: Call data process function. Data in var signal
                        stimSet = OVStimulationSet(self.getCurrentTime(), self.getCurrentTime() + 1. / self.getClock())
                        stimSet.append(OVStimulation(0x00008207, self.getCurrentTime(), 0))
                        #self.output[0].append(stimSet)

        # this time we also re-define the uninitialize method to output the end chunk.
    def uninitialize(self):
         end = self.getCurrentTime()
          #self.output[0].append(OVStimulationEnd(end, end))
         print('Size of signal: ' + str(len(self.signal_trial)))
         #print(str(self.signal_trial[32].shape) + str(self.signal_trial[33].shape))
         print(self.signal_label)
         print('Uninitializing Python Box')
         # print(os.getcwd())
         print('CSP: ' + str(self.csp_ProjMatrix.shape))




# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
