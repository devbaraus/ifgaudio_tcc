return_data = pyrunfile("split_data.py", "return_data", ...
    data=data_representation, ...
    labels=ifgaudioData.Labels(:,1)');

return_data = pyrunfile("encode_split.py", "return_data", ...
    X_train=return_data{'X_train'}, ...
    X_test=return_data{'X_test'}, ...
    y_train=return_data{'y_train'}, ...
    y_test=return_data{'y_test'});

X_train=return_data{'X_train'};
X_test=return_data{'X_test'};
y_train=return_data{'y_train'};
y_test=return_data{'y_test'};

return_data = pyrunfile("train_svm.py", "return_data", ...
    X_train=X_train,...
    y_train=y_train);

scores = struct(return_data{'scores'});
folds_macro = scores.test_f1_macro.mean();
folds_micro = scores.test_f1_micro.mean();
[el, idx] = max(double(scores.test_f1_micro));

return_data = pyrunfile("predict_svm.py", "return_data", ...
    X_test=X_test,...
    y_test=y_test,...
    estimator=scores.estimator(idx));

predict_return = struct(return_data);
predict_macro = predict_return.f1_macro;
predict_micro = predict_return.f1_micro;
