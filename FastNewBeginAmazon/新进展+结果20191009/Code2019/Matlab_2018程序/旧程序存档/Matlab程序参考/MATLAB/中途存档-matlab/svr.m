finPath='E:\TEST\Predict\FeaturePre\a1.txt';
data = importdata(finPath);

train_label=data(1:50,18); 
train_data=data(1:50,2:14); 

test_label=data(51:100,18); 
test_data=data(51:100,2:14); 

model=svmtrain(train_label,train_data,'-s 3 -t 2 -c 2.2 -g 2.8 -p 0.01');  
[predict_label,mse,dec_value]=svmpredict(test_label,test_data,model); 

figure;%
subplot(2,1,1); 
plot(test_label,'-o'); 
hold on; 
plot(predict_label,'r-s'); 
grid on; 
legend('original','predict'); 
title('Train Set Regression Predict by SVM');