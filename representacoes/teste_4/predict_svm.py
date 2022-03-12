# %%
import numpy as np
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, f1_score
from sklearn.model_selection import cross_val_score, cross_val_predict, cross_validate

# %%
estimator = np.asarray(estimator)[0]
X_test = np.asarray(X_test)
y_test = np.asarray(y_test)

# %%
y_hat = estimator.predict(X_test)
fmacro = f1_score(y_test, y_hat, average='macro')
fmicro = f1_score(y_test, y_hat, average='micro')

# %%
return_data = {
    'predicted': y_hat,
    'f1_macro': fmacro,
    'f1_micro': fmicro,
}
