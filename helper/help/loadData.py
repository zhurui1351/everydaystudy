
import pandas as pd
import os
import time

def loadData():

    t1 = time.time()
    path = '/Users/zhouzhirui/Documents/data/zillow/'
    os.chdir(path)

    print('load feature data ...')
    feat = pd.read_csv('properties_2016.csv')
    print('load train data ...')
    train = pd.read_csv('train_2016_v2.csv', parse_dates=["transactiondate"])
    print('load submission data ...')
    submission = (pd.read_csv('sample_submission.csv')).rename(columns={'Parcelid':'parcelid'})
    print('load faetutreinfo ...')
    featinfo = pd.read_csv('featureInfo_new.csv')

    map_dict = dict(zip(featinfo.Feature, featinfo.feature_map))
    feat.columns = map(lambda x: map_dict[x], feat.columns)

    print('load data cost time: %.2f  seconds' % (time.time() - t1))

    return feat, train, submission, featinfo