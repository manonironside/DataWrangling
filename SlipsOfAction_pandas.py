#This script parses json data and converts it to csvs.
#The structure of these csvs is based on variables defined in a jsPsych script.
#
#This script will pull the most recent file from the mongodb_downloads folder,
#which contains raw data from the mongodb cloud database.
#The csv output files will be used for subsequent analyses and data visualization in R.

#Note: Use Python 3. Python 2 will encode data as UTF-8 instead of string, and this will cause headaches with later character parsing.

import sys
sys.path.append('/Users/Manon/anaconda3/lib/python3.5/site-packages')
import json
import pandas as pd
import math
import glob
import os

list_of_files = glob.glob('/Users/Manon/Scripts/JavaScript/NewSlipsOfAction/mongodb_downloads/*') # * means all if need specific format then *.csv
latest_file = max(list_of_files, key=os.path.getctime)
print(latest_file) #Make sure this is the file you think it is!

json_dicts = []
with open(latest_file, 'r') as f:
    lines = f.read().strip().split('\n')
    for l in lines:
        json_dicts.append(json.loads(l)['data'])

dfs = []
for d in json_dicts:
    dfs.append(pd.DataFrame(d))

bigDF = pd.concat(dfs, axis=0, ignore_index=True)
bigDF = bigDF.dropna(subset=['mTurk_code']) #This removes the 'event' trials which are ID-less (blur, focus)
#We may want to look at these later for evidence of switching between browsers, or long breaks, during the task

bigDF['mTurk_code'] = bigDF['mTurk_code'].astype(int)
print(type(bigDF['action_order'][1][0]))

bigDF = bigDF[bigDF.mTurk_code > 7810000000] #This removes people who did not pass the learning phase.
#To examine data from participants who did not pass learning, take out this line of code, or specify ID in the 5010000000 range.

frames = {name: df.dropna(axis=1).drop('Phase', axis=1)
          for name, df in bigDF.groupby('Phase')}

frames2 = {name: df.dropna(axis=1).drop('trial_type', axis=1)
          for name, df in bigDF.groupby('trial_type')}

frames3 = {name: df.dropna(axis=1).drop('Screentype', axis=1)
          for name, df in bigDF.groupby('Screentype')}

target_dir = 'data'
for name, frame in frames.items():
    csv = '{}/{}.csv'.format(target_dir, name)
    frame.to_csv(csv, index=False)
    print('Wrote {}'.format(csv))
for name, frame in frames2.items():
    csv = '{}/{}.csv'.format(target_dir, name)
    frame.to_csv(csv, index=False)
    print('Wrote {}'.format(csv))
for name, frame in frames3.items():
    csv = '{}/{}.csv'.format(target_dir, name)
    frame.to_csv(csv, index=False)
    print('Wrote {}'.format(csv))
