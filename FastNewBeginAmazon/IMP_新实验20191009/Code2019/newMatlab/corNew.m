%D:\TEST\POSITIVE\corNew\fiveCor.txt;threeCor.txt;
path5 = 'D:\TEST\POSITIVE\corNew\fiveCor.txt';
res5 = importdata(path5);
[m,n] = size(res5); %[124,32]

path3 = 'D:\TEST\POSITIVE\corNew\threeCor.txt';
res3 = importdata(path3);

figure
subplot(1,2,1)
title('Stress-buffering effect on five dimensions of stress')
ylabel('Correlation value')
boxplot(res5,'Labels',{'School','Romantic','Peer','Self-cognition','Family'})
subplot(1,2,2)
title('Stress-buffering effect of three measures')
ylabel('Correlation value')
boxplot(res3,'Labels',{'Posting behavior','Stress changes','Linguistic expressions'});
%'\n'+'Today is Monday'
%rotation=10