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
X_train = np.asarray(X_train)
X_test = np.asarray(X_test)
y_train = np.asarray(y_train)
y_test = np.asarray(y_test)

# %%
X_train = se.fit_transform(
    X_train.reshape(-1, X_train.shape[-1])).reshape(X_train.shape)
X_test = se.transform(
    X_test.reshape(-1, X_test.shape[-1])).reshape(X_test.shape)

# %%
y_train = le.fit_transform(y_train)
y_test = le.transform(y_test)

# %%
return_data = {
    'X_train': X_train,
    'X_test': X_test,
    'y_train': y_train,
    'y_test': y_test,
}
