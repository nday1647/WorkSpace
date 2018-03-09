import loadov
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt
data, label, info = loadov.loadov('D:\Myfiles\openvibefiles\MI-CSP-r1\signals\GH\GH-171225-online-1.mat') #!Path
left=[]
right=[]
ch=info['channal']
for i in range(0,len(label)):
	if label[i]==0:
		left.append(data[:,:,i])
	else:
		right.append(data[:,:,i])
l=np.array(left)
r=np.array(right)
fig1, ax1 =plt.subplots(nrows=4,ncols=2)
ax1=ax1.flat
fig1.suptitle('Label left')
fig2,ax2 =plt.subplots(nrows=4,ncols=2)
ax2=ax2.flat
fig2.suptitle('Label right')
for i in range(0,8):
	f1,P1=signal.welch(l[1,:,i],500,nperseg=1000)
	f2,P2=signal.welch(r[1,:,i],500,nperseg=1000)
	ax1[i].set_title(ch[i])
	ax2[i].set_title(ch[i])
	for j in range(1,30):
		f1,p1=signal.welch(l[j,:,i],500,nperseg=1000)
		f2,p2=signal.welch(r[j,:,i],500,nperseg=1000)
		P1=P1+p1
		P2=P2+p2
		ax1[i].plot(f1[16:60],p1[16:60],linewidth=0.5)
		ax2[i].plot(f2[16:60],p2[16:60],linewidth=0.5)
	#max=np.max(P1[16:60]) if np.max(P1[16:60])>np.max(P2[16:60]) else np.max(P2[16:60])
	#P1=P1/max
	#P2=P2/max
	ax1[i].set_ybound(upper=0.03)
	ax2[i].set_ybound(upper=0.03)
	plt.figure(101)
	plt.subplot(4,2,i+1)
	plt.title(ch[i])
	plt.plot(f1[16:60],P1[16:60],'r',f2[16:60],P2[16:60],'b')
	plt.figure(102)
	plt.subplot(4,2,i+1)
	plt.title(ch[i])
	plt.plot(f1[16:60],P1[16:60]-P2[16:60],'g')
	
	print ('finish ch'+str(i+1))
plt.show()