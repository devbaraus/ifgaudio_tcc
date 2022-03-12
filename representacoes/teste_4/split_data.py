# %%
from sklearn.model_selection import cross_val_score
import scipy.io as sio
import numpy as np
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split

# %%
data = np.asmatrix(data)
labels = np.asarray(labels)

# %%
X_train, X_test, y_train, y_test = train_test_split(
    data,
    labels,
    stratify=labels,
    test_size=0.2,
    random_state=42
)

# %%
return_data = {
    'X_train': X_train,
    'X_test': X_test,
    'y_train': y_train,
    'y_test': y_test,
}
