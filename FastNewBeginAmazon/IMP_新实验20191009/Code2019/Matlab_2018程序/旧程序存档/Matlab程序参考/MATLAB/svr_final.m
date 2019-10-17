% [heart_scale_label,heart_scale_inst]=libsvmread('heart_scale');
% model = svmtrain(heart_scale_label,heart_scale_inst, '-c 1 -g 0.07');
% [predict_label, accuracy, dec_values] =svmpredict(heart_scale_label, heart_scale_inst, model); % test the trainingdata
%         
datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
A=[];
for pos=1:length(datalist_stress)
    finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    data = importdata(finPath);
    [s1,s2]=size(data);
    B=A;
    A=[B;data(1:s1-1,:)];
end

M1=A(:,2:27);
M2=A(:,30);

[size1,size2]=size(A);

for i=1:1:size1-1
    M2(i,:)=M2(i+1,:);
end

M1_new=M1(1:size1-1,:);
M2_new=M2(1:size1-1,:);    

trainSize = floor(size1*0.8);
train_label=M2(1:trainSize,:); 
train_data=M1(1:trainSize,:); 

test_label=M2(trainSize+1:size1-1,:); 
test_data=M1(trainSize+1:size1-1,:); 

model=svmtrain(train_label,train_data,'-s 3');  % -t 2 -c 2.2 -g 2.8 -p 0.01
[predict_label,mse,dec_value]=svmpredict(test_label,test_data,model); 

MSE=0;
MAPE=0;
num3=1;
for i=1:1:(size1-1-trainSize)
    MSE = MSE+(predict_label(i)-test_label(i))^2;
    if(test_label(i)>0)
        MAPE = MAPE+abs(test_label(i)-predict_label(i))/test_label(i); 
        num3=num3+1;
    end
end
MSE=MSE/(size1-1-trainSize);
MAPE = MAPE/num3;

% figure;%
% subplot(2,1,1); 
% plot(test_label,'-o'); 
% hold on; 
% plot(predict_label,'r-s'); 
% grid on; 
% legend('original','predict'); 
% title('Train Set Regression Predict by SVM');
