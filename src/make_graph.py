import matplotlib.pyplot as plt 
import csv 
import pandas as pd
import sys 
import os

mypath = os.path.abspath(__file__)
mypath = mypath.split('/')[:-1]
mypath = '/'.join(mypath)

#file path
var1 = sys.argv[1]
#freq number
var2 = int(sys.argv[2])

colors = ['b', 'g', 'r', 'c', 'm', 'y']
idx = 0 

dataframe = pd.read_csv(var1)
columns = list(dataframe)

x_axis = dataframe[columns[0]]

y_axis1 = list(dataframe[columns[1]])
y_axis1 = [x/1000 for x in y_axis1]
y_axis2 = list(dataframe[columns[2]])
y_axis2 = [x/1000 for x in y_axis2]

if "cpu" in var1:
    x_axis = [x/1000 for x in x_axis]
    

t_iter = (int)(len(y_axis2)/var2)
if(t_iter < 1):
    t_iter = 1

# Get average data
arrx = []
arry1 = []
arry2 = []

for i in range(0,var2):
    tempx = 0
    tempy1 = 0
    tempy2 = 0
    for j in range(0,t_iter):
        t_idx = j*var2+i
        tempx += x_axis[t_idx]
        tempy1 += y_axis1[t_idx]
        tempy2 += y_axis2[t_idx]
    arrx.append((int)(tempx/t_iter))
    arry1.append((int)(tempy1/t_iter))
    arry2.append((int)(tempy2/t_iter))

fig, ax1 = plt.subplots()
ax1.plot(arrx, arry1, color=colors[0])
plt.scatter(arrx,arry1)
ax1.set_xlabel(columns[0]+" (MHz)")
ax1.set_ylabel(columns[1], color=colors[0])
ax1.tick_params('y', colors=colors[0])


print(arry2)
print(arry1)
ax2 = ax1.twinx()
ax2.plot(arrx, arry2, color=colors[1])
plt.scatter(arrx,arry2)
ax2.set_ylabel(columns[2]+' ( ms ) ', color=colors[1])
ax2.tick_params('y', colors=colors[1])

plt.title(var1.split('/')[3])

fig.tight_layout()

#print('.'+sys.argv[1].split('.')[1]+'.png')
arr_png_file='.'+sys.argv[1].split('.')[1]+'.png'
arr_pdf_file='.'+sys.argv[1].split('.')[1]+'.pdf'

plt.savefig(arr_png_file) 
fig.savefig(arr_pdf_file) 
#fig.savefig('plot.pdf')
