% datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
% A=[];
% for pos=1:length(datalist_stress)
    % finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    % data = importdata(finPath);
    % [s1,s2]=size(data);
    % B=A;
    % A=[B;data(1:s1-1,:)];
% end

finPath='E:\TEST\GROUP\toNorm\norTrainStudy_all.txt';
data = importdata(finPath);
[s1,s2]=size(data);
A=data;

M1=A(:,1:9);
M2=A(:,10);

[size1,size2]=size(A);

for i=1:1:size1-1
    M2(i,:)=M2(i+1,:);
end

M1_new=M1(1:size1-1,:);
M2_new=M2(1:size1-1,:);    

%--
trainSize = floor(size1*0.7);
train_data=M1(1:trainSize,:); 
train_label=M2(1:trainSize,:); 

test_data=M1(trainSize+1:size1-1,:); 
test_label=M2(trainSize+1:size1-1,:); 
%---

%train_data=M1(1:12000,:); 
%train_label=M2(1:12000,:); 

%test_data=M1(13001:15000,:); 
%test_label=M2(13001:15000,:); 

model=svmtrain(train_label,train_data,'-s 3');  % -t 2 -c 2.2 -g 2.8 -p 0.01
[predict_label,mse,dec_value]=svmpredict(test_label,test_data,model); 

MSE=0;
MAPE=0;
num3=1;
for i=1:1:(size1-1-trainSize)
%for i=1:1:2000
    MSE = MSE+(predict_label(i)-test_label(i))^2;
    if(test_label(i)>0)
        MAPE = MAPE+abs(test_label(i)-predict_label(i))/test_label(i); 
        num3=num3+1;
    end
end
MSE=MSE/(size1-1-trainSize);
RMSE = sqrt(MSE);
%MSE = MSE/2000;
MAPE = MAPE/num3;

% figure;%
% subplot(2,1,1); 
% plot(test_label,'-o'); 
% hold on; 
% plot(predict_label,'r-s'); 
% grid on; 
% legend('original','predict'); 
% title('Train Set Regression Predict by SVM');
