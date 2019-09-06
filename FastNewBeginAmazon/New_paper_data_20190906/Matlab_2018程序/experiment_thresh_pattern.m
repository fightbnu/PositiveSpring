%画各topic在各pattern、各adjust下的预测指标
B0 = zeros(101,4);
B1 = zeros(101,4);
B2 = zeros(101,4);
B3 = zeros(101,4);
B4 = zeros(101,4);
B5 = zeros(101,4);
B6 = zeros(101,4);
B7 = zeros(101,4);

for t=0:1:4
    all_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\metricT',num2str(t),'.txt'];
    allRes = importdata(all_path);
    [m,n] = size(allRes);%808 = 101*8
    len = floor(m/8);
    C0 = allRes(1:len,3:6);
    C1 = allRes(len+1:len*2,3:6);
    C2 = allRes(len*2+1:len*3,3:6);
    C3 = allRes(len*3+1:len*4,3:6);
    C4 = allRes(len*4+1:len*5,3:6);
    C5 = allRes(len*5+1:len*6,3:6);
    C6 = allRes(len*6+1:len*7,3:6);
    C7 = allRes(len*7+1:len*8,3:6);
    
%     C0 = C0 + 0.01;
%     C1 = C1 + 0.09;
%     C2 = C2 + 0.15;
%     C3 = C3 + 0.06;
  
    B0 = B0+C0;
    B1 = B1+C1;
    B2 = B2+C2;
    B3 = B3+C3;
    B4 = B4+C4;
    B5 = B5+C5;
    B6 = B6+C6;
    B7 = B7+C7;
end

%所有topic在各thresh处的均值
B0 = B0*0.2;
B1 = B1*0.2;
B2 = B2*0.2;
B3 = B3*0.2;
B4 = B4*0.2;
B5 = B5*0.2;
B6 = B6*0.2;
B7 = B7*0.2;

[s1,s2] = size(B0);
N0 = zeros(11,4);
N1 = N0;
N2 = N0;
N3 = N0;
N4 = N0;
N5 = N0;
N6 = N0;
N7 = N0;

%N0=B0中间隔10行取值;
line = 1;
for pos=1:10:s1
    N0(line,:) = B0(pos,:);
    line = line+1;
end
%B1;
line = 1;
for pos=1:10:s1
    N1(line,:) = B1(pos,:);
    line = line+1;
end
%B2
line = 1;
for pos=1:10:s1
    N2(line,:) = B2(pos,:);
    line = line+1;
end
%B3
line = 1;
for pos=1:10:s1
    N3(line,:) = B3(pos,:);
    line = line+1;
end
%B4
line = 1;
for pos=1:10:s1
    N4(line,:) = B4(pos,:);
    line = line+1;
end
%B5
line = 1;
for pos=1:10:s1
    N5(line,:) = B5(pos,:);
    line = line+1;
end
%B6
line = 1;
for pos=1:10:s1
    N6(line,:) = B6(pos,:);
    line = line+1;
end
%B7
line = 1;
for pos=1:10:s1
    N7(line,:) = B7(pos,:);
    line = line+1;
end
%---

figure
x2=0:0.1:1;
bar(x2,N7)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
ylabel('Performance')
series = {'MSE','RMSE','MAPE','MAD'};
legend(series, 'Location', 'EastOutside')

figure
x=0:0.1:1;
subplot(3,3,1)
plot(x,N0)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('None')
series = {'MSE','RMSE','MAPE','MAD'};
legend(series, 'Location', 'NorthEast')

subplot(3,3,2)
plot(x,N1)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('LC')
series = {'MSE','RMSE','MAPE','MAD'};

subplot(3,3,3)
plot(x,N2)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('SC')
series = {'MSE','RMSE','MAPE','MAD'};

subplot(3,3,4)
plot(x,N3)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('PC')
series = {'MSE','RMSE','MAPE','MAD'};

subplot(3,3,5)
plot(x,N4)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('LC&SC')
series = {'MSE','RMSE','MAPE','MAD'};
%-
subplot(3,3,6)
plot(x,N5)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('LC&PC')
series = {'MSE','RMSE','MAPE','MAD'};
%-
subplot(3,3,7)
plot(x,N6)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('SC&PC')
series = {'MSE','RMSE','MAPE','MAD'};
%
subplot(3,3,8)
plot(x,N7)
axis([0, 1, 0, 0.5])
xlabel('Thresh')
title('LC&SC&PC')
series = {'MSE','RMSE','MAPE','MAD'};

hold on;
