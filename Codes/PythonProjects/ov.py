# we use numpy to compute the mean of an array of values
import numpy as np

# let's define a new box class that inherits from OVBox
class MyOVBox(OVBox):
	def __init__(self):
		OVBox.__init__(self)
		# we add a new member to save the signal header information we will receive
		self.signalHeader = None

	# this time we also re-define the initialize method to directly prepare the header and the first data chunk
	def initialize(self):
		print('Initializing Python Box')
		
	# The process method will be called by openvibe on every clock tick
	def process(self):
	   # we iterate over all the input chunks in the input signal buffer
		for chunkIndex in range(len(self.input[0])):
			if(type(self.input[0][chunkIndex]) == OVSignalHeader):
				self.signalHeader = self.input[0].pop()
				self.signal = np.empty(shape=[0, self.signalHeader.dimensionSizes[1]])
				print('Data size:'+str(self.signalHeader.dimensionSizes[1]))
			# if it's a buffer we pop it and put it in a numpy array at the right dimensions
			elif(type(self.input[0][chunkIndex]) == OVSignalBuffer):
				chunk = self.input[0].pop()
				npBuffer = np.array(chunk).reshape(
					tuple(self.signalHeader.dimensionSizes))
				np.concatenate((self.signal, npBuffer), axis=0)
			# if it's a end-of-stream we just forward that information to the output
			elif(type(self.input[0][chunkIndex]) == OVSignalEnd):
				print('Data Read Finished')
		for stimIndex in range(len(self.input[1])):
			stim = self.input[1].pop()
			if stim.identifier==0x00008201:
				print('Start Training')
				#TODO: Call data process function. Data in var signal
				self.output[0].append(OVStimulation(0x00008207, stim.date, stim.duration))
	# this time we also re-define the uninitialize method to output the end chunk.
	def uninitialize(self):
		print('Uninitializing Python Box')

# Finally, we notify openvibe that the box instance 'box' is now an instance of MyOVBox.
# Don't forget that step !!
box = MyOVBox()
