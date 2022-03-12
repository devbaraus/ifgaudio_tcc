# %%
import numpy as np
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, f1_score
from sklearn.model_selection import cross_val_score, cross_val_predict, cross_validate

# %%
X_train = np.asarray(X_train)
y_train = np.asarray(y_train)

# %%
clf = SVC(kernel='linear', C=10)
scoring = ['precision_macro', 'recall_macro', 'f1_macro', 'f1_micro']
scores = cross_validate(clf, X_train, y_train,
                        scoring=scoring, cv=2,
                        return_estimator=True,
                        return_train_score=True)


# %%
return_data = {
    'scores': scores,
}
