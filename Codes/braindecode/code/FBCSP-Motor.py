
# coding: utf-8

# In[1]:


import logging
# import importlib
# importlib.reload(logging) # see https://stackoverflow.com/a/21475297/1469195
log = logging.getLogger()
log.setLevel('DEBUG')
import sys
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)

import os
os.sys.path.append('../fbcsp/')
os.sys.path.append('../braindecode/')

# get_ipython().magic(u'load_ext autoreload')
# get_ipython().magic(u'autoreload 2')
# get_ipython().magic(u'cd /home/schirrmr/')

import matplotlib
# get_ipython().magic(u'matplotlib inline')
# get_ipython().magic(u"config InlineBackend.figure_format = 'svg'")
matplotlib.rcParams['figure.figsize'] = (12.0, 1.0)
matplotlib.rcParams['font.size'] = 7

import logging
log = logging.getLogger()
log.setLevel('DEBUG')


# In[18]:


# from braindecode.datasets.bbci import BBCIDataset
# set_loader = BBCIDataset('data/BBCI-only-last-runs/BhNoMoSc1S001R13_ds10_1-2BBCI.mat',
#                         load_sensor_names=['C3', 'C4', 'C1', 'C2', 'CPz', 'F3', 'F4', 'Fz'])
# cnt = set_loader.load()
# cnt = cnt.drop_channels(['STI 014'])
# eog_cnt = BBCIDataset('data/BBCI-only-last-runs/BhNoMoSc1S001R13_ds10_1-2BBCI.mat',
#                         load_sensor_names=['EOGh', 'EOGv']).load()
# eog_cnt = eog_cnt.drop_channels(['STI 014'])

from braindecode.datasets.bcic_iv_2a import BCICompetition4Set2A
data_folder = 'D:\Myfiles\EEGProject\BCICompetitionIV\BCICIV_2a_gdf'
subject_id = 3 # 1-9
train_filename = 'A{:02d}T.gdf'.format(subject_id)
test_filename = 'A{:02d}E.gdf'.format(subject_id)
train_filepath = os.path.join(data_folder, train_filename)
test_filepath = os.path.join(data_folder, test_filename)
train_label_filepath = train_filepath.replace('.gdf', '.mat')
test_label_filepath = test_filepath.replace('.gdf', '.mat')
train_loader = BCICompetition4Set2A(train_filepath, labels_filename=train_label_filepath)
test_loader = BCICompetition4Set2A(test_filepath, labels_filename=test_label_filepath)
train_cnt = train_loader.load()
test_cnt = test_loader.load()

train_cnt = train_cnt.drop_channels(['STI 014', 'EOG-left', 'EOG-central', 'EOG-right'])
assert len(train_cnt.ch_names) == 22
cnt = train_cnt
# In[19]:


from braindecode.mne_ext.signalproc import mne_apply
from braindecode.datautil.signalproc import bandpass_cnt

import numpy as np
def car_cnt(cnt):
    return mne_apply(lambda x: x - np.mean(x,axis=0, keepdims=True), cnt)

cnt = car_cnt(cnt)
cnt = mne_apply(lambda x: bandpass_cnt(x, 4, 40.0, cnt.info['sfreq']), cnt)



# In[20]:


from fbcsp.experiment import CSPExperiment
from collections import OrderedDict
# name_to_start_codes = OrderedDict([('left', 1), ('right', 2), ('foot', 3), ('tongue', 4)])
name_to_start_codes = OrderedDict([('left', 1), ('right', 2), ('foot', 3)])
epoch_ival_ms = [0, 4000]


# In[21]:


from fbcsp.clean import EOGMaxMinCleaner, VarCleaner, apply_multiple_cleaners


# cleaners = [EOGMaxMinCleaner(eog_cnt, epoch_ival_ms, name_to_start_codes, threshold=600),
#            VarCleaner(whisker_percent=10, whisker_length=3)]
# cleaned_cnt = apply_multiple_cleaners(cnt, epoch_ival_ms, name_to_start_codes, cleaners)


# In[28]:

cleaned_cnt = cnt
exp = CSPExperiment(cleaned_cnt, name_to_start_codes, epoch_ival_ms,
                    min_freq=4,
                    max_freq=40, last_low_freq=40,
                    low_width=6,
                    high_width=4,
                    low_overlap=0,
                    high_overlap=0,
                    filt_order=3,
                    n_folds=3,
                    n_top_bottom_csp_filters=3,
                    n_selected_filterbands=None,
                    n_selected_features=10,
                    forward_steps=2,
                    backward_steps=1,)


# In[29]:


from braindecode.datautil.trial_segment import create_signal_target, create_signal_target_from_raw_mne

from braindecode.datautil.signalproc import bandpass_cnt

from braindecode.datautil.iterators import get_balanced_batches


# In[30]:


exp.run()

