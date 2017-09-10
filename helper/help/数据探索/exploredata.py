import os
import sys
import pandas as pd
import numpy as np
import scipy as sp
import seaborn as sns
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

import xgboost as xgb
from sklearn.metrics import make_scorer

#%matplotlib inline
plt.style.use(u'fivethirtyeight')

path = 'D:/zillow'
os.chdir(path)
os.listdir()

properties = pd.read_csv('properties_2016.csv')
train = pd.read_csv('train_2016_v2.csv',parse_dates=["transactiondate"])
properties_info = pd.read_csv('featureInfo_utf8.csv')


fig, ax = plt.subplots(figsize=(10,6))
ax.scatter(range(train.shape[0]), np.sort(train.logerror.values),label='logerror')
ax.set_ylabel('logerror',size=16)
ax.set_xlabel('count',size=16)
ax.axhline(train.logerror.mean(),linestyle='--',label='mean logerror')
ax.legend(fontsize=14)
ax.set_title('mean logerror %.4f'%(train.logerror.mean()), size=16)

fig, ax = plt.subplots(figsize=(12,4))
sns.distplot(train.logerror.where((train.logerror<1)&(train.logerror>-1)).dropna(),label='logerror distribution')
sns.distplot(sp.stats.norm.rvs(sp.stats.tmean(train.logerror),
                  sp.stats.tstd(train.logerror),
                  size=train.shape[0]), hist=False, label='normal distribution')
ax.set_xlabel('logerror', size=16)
ax.set_ylabel('density', size=16)
ax.legend(fontsize=16)
ax.set_title('logerror & normal distribution', size=16)

(train.groupby(np.sign(train.logerror))['logerror'].agg(['count','mean','std','min','max','median']))\
.rename(index={-1:'negative logerror',0:'zero logerror',1:'positive logerror'})


error_mean = train.groupby(train.transactiondate.apply(lambda x: x.month))['logerror'].mean()
p_error_mean = train[train.logerror>0].groupby(train[train.logerror>0].transactiondate.apply(lambda x: x.month))['logerror'].mean()
n_error_mean = train[train.logerror<0].groupby(train[train.logerror<0].transactiondate.apply(lambda x: x.month))['logerror'].mean()

fig, ax =plt.subplots(figsize=(12,4))
ax.plot(range(12),error_mean, label='mean_error', c='blue')
ax.plot(range(12),p_error_mean, label='positive_mean_error', c='red')
ax.plot(range(12),n_error_mean, label='negative_mean_error', c='g')
ax.legend(fontsize=12,loc='center right')
ax.set_xticks(range(12))
ax.set_title('month error')

(train.groupby('parcelid')['logerror'].count().reset_index()).groupby('logerror').count()


parcelid_t_count = train.groupby('parcelid')['logerror'].count().reset_index().rename(columns={'logerror':'transaction_count'})
parcelid_repeat_teansaction = parcelid_t_count[parcelid_t_count.transaction_count>1].parcelid.values

r_mean = train[train.parcelid.isin(parcelid_repeat_teansaction)].logerror.mean()

_mean = train.logerror.mean()

r_abs_mean = train[train.parcelid.isin(parcelid_repeat_teansaction)].logerror.abs().mean()

_abs_mean = train.logerror.abs().mean()

fig, ax = plt.subplots(figsize=(12,4))
ax.bar([1,2,3,4], [r_mean,_mean,r_abs_mean,_abs_mean])
ax.set_xticks([1,2,3,4])
ax.set_xticklabels(['r_mean','mean','r_abs_mean','abs_mean'], size=15)
ax.set_title('logerror',size=18)


cm = plt.get_cmap('RdYlGn')
c = [cm(i/4) for i in range(6)]

fig, ax = plt.subplots(figsize=(16,6))
ax.scatter(range(train.shape[0]), np.sort(train.logerror.values),label='logerror', s=1)
ax.set_ylabel('logerror',size=16)
ax.set_xlabel('count',size=16)
ax.axhline(np.percentile(train.logerror, 5),linestyle='--',label='logerror 5% percentile', c=c[0], linewidth=2)
ax.axhline(np.percentile(train.logerror, 95),linestyle='--',label='logerror 95% percentile', c=c[1],linewidth=2)
ax.axhline(np.percentile(train.logerror, 1),linestyle='--',label='logerror 1% percentile', c=c[2],linewidth=2)
ax.axhline(np.percentile(train.logerror, 99),linestyle='--',label='logerror 99% percentile', c=c[3],linewidth=2)
ax.legend(fontsize=14)
ax.set_title('mean logerror %.4f'%(train.logerror.mean()), size=20)


map_dict = dict(zip(properties_info.Feature,properties_info.feature_map))
properties.columns = map(lambda x: map_dict[x], properties.columns)
region_columns = [i for i in properties.columns if i[:6] == 'region']
region_columns.extend(['longitude','latitude','fips'])

region_columns

fig, ax = plt.subplots(figsize=(12,4))
ax.bar(range(len(region_columns)),properties[region_columns].isnull().sum()/properties.shape[0])
ax.set_xticks(range(len(region_columns)))
ax.set_xticklabels(region_columns, size=14)
ax.set_title('region features nan percentage',size= 18)

for a,b in zip(range(len(region_columns)), properties[region_columns].isnull().sum()/properties.shape[0]):
    ax.text(a,b+0.05,'%.2f%%'%(b*100), ha='center', va= 'bottom',fontsize=14)

fig, ax = plt.subplots(figsize=(12,4))
ax.bar(range(len(region_columns)), properties[region_columns].nunique())
ax.set_xticks(range(len(region_columns)))
ax.set_xticklabels(region_columns, size=14)
ax.set_title('region features unique values num',size= 18)

for a,b in zip(range(len(region_columns)), properties[region_columns].nunique()):
    ax.text(a,b+0.05,'%d'%(b), ha='center', va= 'bottom',fontsize=14)

sns.countplot(properties.region_county)

tmp = properties[['region_county','latitude','longitude']].dropna().copy()
fig = plt.figure(figsize=(10,6))
ax = fig.add_subplot(111)
ax.scatter(tmp[tmp.region_county==3101].latitude,tmp[tmp.region_county==3101].longitude,c='r',label='county_3101',alpha=0.5)
ax.scatter(tmp[tmp.region_county==1286].latitude,tmp[tmp.region_county==1286].longitude,c='g',label='county_1286',alpha=0.5)
ax.scatter(tmp[tmp.region_county==2061].latitude,tmp[tmp.region_county==2061].longitude,c='b',label='county_2061',alpha=0.5)
ax.legend(fontsize=16)
ax.set_title('County Plot', size=20)
del tmp

properties[(properties.region_county.isnull().astype(bool))&(-properties.latitude.isnull())].shape
properties[['region_county','fips']].drop_duplicates()

properties.groupby('region_city')['region_county'].value_counts().rename(index='count').head()
