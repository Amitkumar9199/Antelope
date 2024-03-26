# -*- coding: utf-8 -*-
# Python code to train models that predict congestion control reward
# For initial data, consult TRAINING.md
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier, XGBRegressor
from sklearn.metrics import mean_squared_error as MSE
import numpy as np
import pickle

# NOTE: Change the congestion algorithm here
CCNAME = "cubic"
CAL_ACCURACY = 1

DATAPATH = "traindata/" + CCNAME + "_output.txt"
MODELPATH = "traindata/models/" + CCNAME + ".pickle"


def loadData(dir):
    data = []
    target = []
    fileName = dir
    try:
        rawData = np.loadtxt(fileName)
        for item in rawData:
            data.append(item[:-1])
            target.append(item[-1])
    except Exception as e:
        print(e)
        pass

    return np.array(data), np.array(target)


# load data
data, target = loadData(DATAPATH)
# shape log
print(data.shape)
print(target.shape)

# split data into train and test sets
x_train, x_test, y_train, y_test = train_test_split(data, target, test_size=0.2, random_state=33)

### fit model for train data
model = XGBRegressor(n_estimators=40, max_depth=3, subsample=1, gamma=1, learning_rate=0.15)
model.fit(x_train, y_train)

# Accuracy
if CAL_ACCURACY == 1:
    # rmse computation
    pred = model.predict(x_test)
    rmse = np.sqrt(MSE(y_test, pred))
    print("RMSE : % f" %(rmse))

# save the model
with open(MODELPATH, "wb") as fw:
    pickle.dump(model, fw)
