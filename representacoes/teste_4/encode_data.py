# %%
from sklearn.model_selection import cross_val_score
import scipy.io as sio
import numpy as np
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split

# %%
se = StandardScaler()
le = LabelEncoder()

# %%
data = np.asarray(data)
labels = np.asarray(labels)

# %%
data = se.fit_transform(
    data.reshape(-1, data.shape[-1])).reshape(data.shape)

labels = le.fit_transform(labels)

# %%
return_data = {
    'data': data,
    'labels': labels,
}
