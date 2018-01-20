import pickle
import os

data1 = {'aa': [1, 2.0, 3, 4+6j]}
data2 = {'aaa': [2, 2.0, 3, 4+6j]}
data3 = {'aa': [3, 2.0, 3, 4+6j]}

pkfile=open("D:\Myfiles\WorkSpace\Codes\PythonProjects\data.txt",'ab')
pickle.dump(data1,pkfile)
pickle.dump(data2,pkfile)
pickle.dump(data3,pkfile)
pkfile.close() 

pkfile2=open("D:\Myfiles\WorkSpace\Codes\PythonProjects\data.txt",'rb')
pkf=pickle.load(pkfile2)
pkf1=pickle.load(pkfile2)
pkf2=pickle.load(pkfile2)
pkfile2.close()

print(pkf)
print(pkf1)
print(pkf2)

os.remove('data.txt')