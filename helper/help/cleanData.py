
import pandas as pd
import time


def cleanData(feat, df, featinfo):
    t1 = time.time()
    print('create feat dict...')
    featcatdict = {}
    for cat in featinfo.category.unique():
        featcatdict[cat] = list(featinfo.loc[featinfo.category == cat, 'feature_map'].values)

    featdtypedict = {}
    for t in featinfo['dtype'].unique():
        featdtypedict[t] = list(featinfo.loc[featinfo['dtype'] == t, 'feature_map'].values)

    for k, v in featcatdict.items():
        if k != 'primary':
            print('add feature: _%snanNum' % k)
            feat['_%snanNum' % (k)] = feat[v].T.isnull().sum()

    Area_cols = [i for i in feat.columns if ((i[0] != '_') & ('Area' in i))]
    print('add feature: _areananNum')
    feat['_areananNum'] = feat[Area_cols].T.isnull().sum()

    Num_cols = [i for i in feat.columns if (i[0] != '_') & ('Num' in i)]
    print('add feature: _numnanNum')
    feat['_numnanNum'] = feat[Num_cols].T.isnull().sum()

    print('convert binary features to 0-1 values ,0 means null value')
    feat[featdtypedict['binary']] = feat[featdtypedict['binary']].fillna(0.)
    for c in featdtypedict['binary']:
        print('feature %s, unique values: %s' % (c, str(feat[c].unique())))
        feat.loc[feat[c] != 0., c] = 1.

    print('filling text features with "None"')
    # text data processing
    feat[featdtypedict['text']] = feat[featdtypedict['text']].fillna('None')

    # 所有特征只有一个值的变量，权重转化成0-1
    print('convert nunique == 1 features to 0-1, 0 means null')
    for c in feat.columns:
        if feat[c].nunique() <= 1:
            print('....convert %s' % (c))
            feat[c] = feat[c].fillna(0).apply(lambda x: 1 if x != 0 else x)

    # 相关系数等于1的特征，若空值最少的覆盖另外一个，则添加一个特征标注有空，删除该特征
    print('add feature _baseAreanan, delete feature baseArea')
    feat['_baseAreanan'] = feat.baseArea.fillna('None').apply(lambda x: 0 if x == 'None' else 1)
    del feat['baseArea']

    print('add feature _finishedLivingAreanan, delete feature finishedLivingArea')
    feat['_finishedLivingAreanan'] = feat.finishedLivingArea.fillna('None').apply(lambda x: 0 if x == 'None' else 1)
    del feat['finishedLivingArea']

    print('add feature _perimeterAreanan, delete feature perimeterArea')
    feat['_perimeterAreanan'] = feat.perimeterArea.fillna('None').apply(lambda x: 0 if x == 'None' else 1)
    del feat['perimeterArea']

    print('add feature _totalAreanan, delete feature totalArea')
    feat['_totalAreanan'] = feat.totalArea.fillna('None').apply(lambda x: 0 if x == 'None' else 1)
    del feat['totalArea']

    print('add feature _bathroomcalcNumnan, delete feature bathroomcalcNum')
    feat['_bathroomcalcNumnan'] = feat.bathroomcalcNum.isnull() * 1
    del feat['bathroomcalcNum']

    # 相关系数接近1的特征处理，分别尝试了 做差、做除、标注不相等、标注小特征空、标注小特征空大特征非空，取效果最好的一个添加，删除特征
    print('add feature _firstfloorlivingunknownAreaProp, delete feature firstfloorlivingunknownArea')
    feat['_firstfloorlivingunknownAreaProp'] = feat['firstfloorlivingunknownArea'] / feat['firstfloorlivingArea']
    # feat['_firstfloorlivingunknownAreaProp'] = feat['_firstfloorlivingunknownAreaProp'].fillna(-1)
    del feat['firstfloorlivingunknownArea']

    print('add feature _bathNumnan,_bathNumMinus, delete feature bathNum')
    feat['_bathNumnan'] = feat.bathNum.isnull() * 1
    feat['_bathNumMinus'] = feat.bathNum - feat.bathroomNum
    # feat['_bathNumMinus'] = feat['_bathNumMinus'].fillna(-1)
    del feat['bathNum']

    # 税收中相关系数在0.8-0.95的先不处理发现有后续特征提取，比如rank排序／比例等

    # region类特征中 fips与county一致，删除
    print('delete feature fips')
    del feat['fips']

    # city\zip填充利用knn填充缺省值，添加特征标注缺省样本
    print('add feature _citynan, fill feature city with knn ...')

    feat['_citynan'] = 0
    feat.loc[(feat.city.isnull()) & (-feat.latitude.isnull()), '_citynan'] = 1

    from sklearn.neighbors import KNeighborsClassifier
    knn_city = KNeighborsClassifier()
    tmp = feat[['city', 'latitude', 'longitude']].dropna().copy()
    knn_city.fit(tmp[['latitude', 'longitude']].values, tmp.city.values)

    fill_city = knn_city.predict(
        feat.loc[(-feat.latitude.isnull()) & (feat.city.isnull()), ['latitude', 'longitude']].values)
    feat.loc[(-feat.latitude.isnull()) & (feat.city.isnull()), 'city'] = fill_city

    del tmp, knn_city

    print('add feature _zipnan, fill feature zip with knn ...')

    feat['_zipnan'] = 0
    feat.loc[(feat.zip.isnull()) & (feat.latitude.notnull()), '_zipnan'] = 1

    knn_zip = KNeighborsClassifier()
    tmp = feat[['zip', 'latitude', 'longitude']].dropna().copy()
    knn_zip.fit(tmp[['latitude', 'longitude']].values, tmp.zip.values)

    fill_zip = knn_zip.predict(
        feat.loc[(-feat.latitude.isnull()) & (feat.zip.isnull()), ['latitude', 'longitude']].values)
    feat.loc[(-feat.latitude.isnull()) & (feat.zip.isnull()), 'zip'] = fill_zip

    del tmp, knn_zip

    # print('merge data')
    # df = pd.merge(train, feat, on='parcelid', how='left')

    # 对特征数据做统计，后续工作
    print('do feature statistic...')

    df = pd.merge(train, feat, on='parcelid', how='left').drop(['logerror', 'transactiondate'], axis=1)
    featdtype = feat.dtypes
    featnunique = feat.nunique()
    featnanPer = feat.isnull().sum() / feat.shape[0]
    dfnunique = df.nunique()
    dfnanPer = df.isnull().sum() / df.shape[0]
    featdesc = pd.DataFrame([featdtype, featnunique, dfnunique, featnanPer, dfnanPer]).T.rename(
        columns={0: 'dtype', 1: 'nunique', 2: 'dfnunique', 3: 'nanPer', 4: 'dfnanPer'}).reset_index().rename(
        columns={'index': 'feature'})

    # 对在feat中有多值，在训练集中只有单值的特征，统一处理成 0 - 1
    print('convert features which having single value in df and muti-values in feat to 0-1, 0 means nan')
    for i in range(featdesc.shape[0]):
        if (featdesc.loc[i, 'dfnunique'] == 1) & (featdesc.loc[i, 'nunique'] > 1):
            print('...convert %s' % (featdesc.loc[i, 'feature']))
            feat[featdesc.loc[i, 'feature']] = feat[featdesc.loc[i, 'feature']].fillna('None').apply(
                lambda x: 0 if x == 'None' else 1)
            featdesc.loc[i, 'nunique'] = 2
            featdesc.loc[i, 'dfnunique'] = 2
            featdesc.loc[i, 'nanPer'] = 0.
            featdesc.loc[i, 'dfnanPer'] = 0.

    print('cost time: %.2f  seconds' % (time.time() - t1))

    return feat, featdesc