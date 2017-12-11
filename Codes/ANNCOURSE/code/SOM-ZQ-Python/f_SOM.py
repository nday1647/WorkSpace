from numpy import *
import matplotlib.pyplot as plt
import datetime

#初始化输入层与竞争层神经元的连接权值矩阵
def initCompetition(n , m , d):
    #随机产生0-1之间的数作为权值
    array = random.random(size=n * m *d)
    com_weight = array.reshape(n,m,d)
    return com_weight

#计算向量的二范数
def cal2NF(X):
    res = 0
   # return linalg.norm(X)
    for x in X:
        res += x*x
    return res ** 0.5 #res的0.5次方

#对数据集进行归一化处理
def normalize(dataSet):
    old_dataSet = copy(dataSet)
    for data in dataSet:
        two_NF = cal2NF(data)
        for i in range(len(data)):
            data[i] = data[i] / two_NF
    return dataSet , old_dataSet
#对权值矩阵进行归一化处理
def normalize_weight(com_weight):
    for x in com_weight:
        for data in x:
            two_NF = cal2NF(data)
            for i in range(len(data)):
                data[i] = data[i] / two_NF
    return com_weight

#得到获胜神经元的索引值
def getWinner(data , com_weight):
    max_sim = 0
    n,m,d = shape(com_weight)
    mark_n = 0
    mark_m = 0
    for i in range(n):
        for j in range(m):
            if sum(data * com_weight[i,j]) > max_sim:#取点积的最大值
                max_sim = sum(data * com_weight[i,j])
                mark_n = i
                mark_m = j
    return mark_n , mark_m, max_sim

#得到神经元的N邻域
def getNeibor(n , m , N_neibor , com_weight):
    res = []
    nn,mm , _ = shape(com_weight)
    for i in range(nn):
        for j in range(mm):
            N = int(((i-n)**2+(j-m)**2)**0.5)
            if N<=N_neibor:
                res.append((i,j,N))
    return res

#学习率函数
def eta(t,N):
    return (1/(t+1))* (math.e ** -N)

#SOM算法的实现
#T:最大迭代次数
#N_neibor:初始近邻数
def do_som(dataSet , com_weight, T , N_neibor):
    for t in range(T):
        com_weight = normalize_weight(com_weight)
        for data in dataSet:
            n , m , max_sim= getWinner(data , com_weight)
            neibor = getNeibor(n , m , N_neibor , com_weight)
            for x in neibor:
                j_n=x[0];j_m=x[1];N=x[2]
                #===权值调整===
                com_weight[j_n][j_m] = com_weight[j_n][j_m] + eta(t,N)*(data - com_weight[j_n][j_m])
            #===邻域调整函数===
            N_neibor = N_neibor+1-(t+1)/200
    # res = {}
    # N , M , _ =shape(com_weight)
    # for i in range(len(dataSet)):
    #     n, m = getWinner(dataSet[i], com_weight)
    #     key = n*M + m
    #     if key in res:
    #         res[key].append(i)
    #     else:
    #         res[key] = []
    #         res[key].append(i)
    # return res
    winner_x=[]
    winner_y=[]
    for i in range(len(dataSet)):
        n, m, max_sim= getWinner(dataSet[i], com_weight)
        winner_x.append(n)
        winner_y.append(m)
    return winner_x, winner_y,com_weight


# def draw(res , dataSet):
#     color = ['r', 'y', 'g', 'b', 'c', 'k', 'm' , 'd']
#     count = 0
#     for i in res.keys():
#         X = []
#         Y = []
#         datas = res[i]
#         for j in range(len(datas)):
#             X.append(dataSet[datas[j]][0])
#             Y.append(dataSet[datas[j]][1])
#         #scatter绘制散点图
#         plt.scatter(X, Y, marker='o', color=color[count % len(color)], label=i)
#         count += 1
#     #legend显示图例
#     plt.legend(loc='upper right')
#     plt.show()

def drawSOM(winner_x, winner_y, label):
    color = ['r', 'y', 'g', 'b', 'c']
    plt.title('SOM Model')
    plt.subplot(211)
    plt.grid(True)
    for i in range(len(winner_x)):
        # scatter绘制散点图
        plt.scatter(winner_x[i], winner_y[i], marker='o', color=color[i], label=label[i])
    # legend显示图例
    plt.legend(loc='upper right')
    plt.axis([-1,5,-1,5])

 # SOM算法主方法
def SOM(dataSet,com_n,com_m,T,N_neibor,dataSetLabel):
    dataSet, old_dataSet = normalize(dataSet)
    com_weight = initCompetition(com_n,com_m,shape(dataSet)[1])
    winner_x, winner_y, com_weight = do_som(dataSet, com_weight, T, N_neibor)
    drawSOM(winner_x, winner_y, dataSetLabel)
    return com_weight

# def loadDataSet(fileName):  # 加载数据文件
#     fr = open(fileName)
#     dataMat=[]
#     for line in fr.readlines():
#         curLine = line.strip().split(",")
#         lineArr = []
#         lineArr.append(float(curLine[0]))
#         lineArr.append(float(curLine[1]))
#         dataMat.append(lineArr)
#     dataMat = mat(dataMat)
#     return dataMat

# def loadDataSet(fileName):
#     dataMat = []
#     fr = open(fileName)
#     for line in fr.readlines():
#         curLine = line.strip().split(' ')
#         fltLine = map(float,curLine)
#         dataMat.append(fltLine)
#     return dataMat

# def file2matrix(path, delimiter):
#     recordlist = []
#     fp = open(path, "rb")  # 读取文件内容
#     content = fp.read()
#     fp.close()
#     rowlist = content.splitlines()  # 按行转换为一维表
#      # 逐行遍历         # 结果按分隔符分割为行向量
#     recordlist = [map(eval, row.split(delimiter)) for row in rowlist if row.strip()]
#         # 返回转换后的矩阵形式
#     return recordlist

def testSOM(test_data,com_weight,dataSetLabel):
    test_x, test_y, max_sim = getWinner(test_data, com_weight)
    plt.subplot(212)
    plt.grid(True)
    plt.scatter(test_x, test_y, marker='^', color='m')
    plt.axis([-1,5,-1,5])
    plt.show()

#dataSet = file2matrix("dataset2.txt",'\t')
dataSet = [[1,0,0,0],
           [1,1,0,0],
           [1,1,1,0],
           [0,1,0,0],
           [1,1,1,1]]
dataSetLabel = ['X1','X2','X3','X4','X5']
com_weight = SOM(dataSet,5,5,10000,2,dataSetLabel)
test_data = [0.4,0,0,0]
testSOM(test_data, com_weight, dataSetLabel)