%[1-15]stress: *acc, *avg, *RMS, length, *max, *type(5), *ratio(5) = 15
%[study,romantic,friends,self,family]
%target[1,2,3,5,6,11]

%[16-32]positive: *acc, *avg, *RMS, length, *max, *type(6), *ratio(6) = 17 
%[study,romantic,friends,self,family,enter]
%target[16,17,18,20,21,27]

                  
u1_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\Sport.txt';
stress_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\stressAllteen.txt';
u1Res = importdata(u1_path);
sRes = importdata(stress_path);

%%%%%%U-SI stress measures
[m1,n1] = size(u1Res); %[124,32]
x=1:1:124;
if(m1==124 && n1==32)
    acc = u1Res(:,1);
    pacc=polyfit(x,acc',1);
    %
    avg = u1Res(:,2);
    pavg = polyfit(x,avg',1);
    %
    rms = u1Res(1:124,3);
    prms = polyfit(x,rms',1);
    %
    max = u1Res(1:124,5);
    pmax = polyfit(x,max',1);
    %
    stu = u1Res(1:124,6);
    pstu = polyfit(x,stu',1);
    %
    stuR = u1Res(1:124,11);
    pstuR = polyfit(x,stuR',1);
else
    disp(m1+"|"+n1)
end 

%%%%%%%SI stress measures
[m2,n2] = size(sRes); %[124,32]
x=1:1:124;
if(m2==124 && n2==32)
    accs = sRes(:,1);
    paccs=polyfit(x,accs',1);
    %
    avgs = sRes(:,2);
    pavgs = polyfit(x,avgs',1);
    %
    rmss = sRes(1:124,3);
    prmss = polyfit(x,rmss',1);
    %
    maxs = sRes(1:124,5);
    pmaxs = polyfit(x,maxs',1);
    %
    stus = sRes(1:124,6);
    pstus = polyfit(x,stus',1);
    %
    stuRs = sRes(1:124,11);
    pstuRs = polyfit(x,stuRs',1);
else
    disp(m2+"|"+n2)
end 

%note:橙色为USI，红色为SI
figure
subplot(3,2,1)
plot(x,acc',x,polyval(pacc,x),x,accs',x,polyval(paccs,x))
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('acc_stress')
title('Sport')
series = {'U-SI','','SI',''};
legend(series, 'Location', 'NorthWest')

subplot(3,2,2)
plot(x,avg',x,polyval(pavg,x),x,avgs',x,polyval(pavgs,x))
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('avg_stress')
%title('Holiday')
%title('acc')
%series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')

subplot(3,2,3)
plot(x,rms',x,polyval(prms,x),x,rmss',x,polyval(prmss,x))
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('rms_stress')
%title('Holiday')
%title('acc')
%series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')

subplot(3,2,4)
plot(x,max',x,polyval(pmax,x),x,maxs',x,polyval(pmaxs,x))
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('max_stress')
%title('Holiday')
%title('acc')
%series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')


subplot(3,2,5)
plot(x,stu',x,polyval(pstu,x),x,stus',x,polyval(pstus,x))
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('academic stress')
%title('Holiday')
%title('acc')
%series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')

subplot(3,2,6)
plot(x,stuR',x,polyval(pstuR,x),x,stuRs',x,polyval(pstuRs,x))
%plot(x,stuR',x,polyval(pstuR,x),x,stuRs')
axis([1,124,-inf, inf]) 
xlabel('student ID')
ylabel('academic stress ratio')
%title('Holiday')
%title('acc')
%series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')


%add1: 每隔3个点取值
%x=1:3:124;
%acc1 = acc(x);

%add2: 添加拟合线
% x1=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2];
% y1=[-8,-236,-415,-562,-701,-860,-961,-1082,-1188,-1304,-1405,-1534];
% p = polyfit(x1,y1,1)
% plot(x1,y1,'o',x1,polyval(p,x1))

%add3: 求最大值
%[m1,n1]=max(acc);%求最大值
