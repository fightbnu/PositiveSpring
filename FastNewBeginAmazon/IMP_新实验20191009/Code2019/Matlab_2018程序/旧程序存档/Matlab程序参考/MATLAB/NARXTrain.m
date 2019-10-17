% finAllPath='E:\TEST\Predict\train124.txt';
% 
% All = importdata(finAllPath);
% XM = All(:,2:27);
% YM = All(:,28:30);

datalist_stress=dir('E:\TEST\Predict\FeaturePre\*.txt');
A=[];
for pos=1:length(datalist_stress)
    finPath=['E:\TEST\Predict\FeaturePre\',datalist_stress(pos).name];
    data = importdata(finPath);
    B=A;
    A=[B;data];
end

M1=A(:,2:27);
M2=A(:,30);

% [size1,size2]=size(M1); 
% for i=1:1:size1-1
%     M2(i,:)=M2(i+1,:);
% end
% 
% x=M1(1:size1-1,:);
% y=M2(1:size1-1,:);
        
X = M1';
Y = M2';