%[1-15]stress: *acc, *avg, *RMS, length, *max, *type(5), *ratio(5) = 15
%[study,romantic,friends,self,family]
%target[1,2,3,5,6,11]

%[16-32]positive: *acc, *avg, *RMS, length, *max, *type(6), *ratio(6) = 17 
%[study,romantic,friends,self,family,enter]
%target[16,17,18,20,21,27]

%%%%%%U-SI stress measures
%1-activity                  
u1_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\Activity.txt';
u1Res = importdata(u1_path);
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

act=[mean(acc),mean(avg),mean(rms),mean(max)];
actStudy=[mean(stu),mean(stuR)];

%2-holiday
u2_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\Holiday.txt';
u2Res = importdata(u2_path);
[m2,n2] = size(u2Res); %[124,32]
if(m2==124 && n2==32)
    acc2 = u2Res(:,1);
    avg2 = u2Res(:,2);
    rms2 = u2Res(1:124,3);
    max2 = u2Res(1:124,5);
    stu2 = u2Res(1:124,6);
    stuR2 = u2Res(1:124,11);
else
    disp(m2+"|"+n2)
end 
hol=[mean(acc2),mean(avg2),mean(rms2),mean(max2)];
holStudy=[mean(stu2),mean(stuR2)];

%3-party
u3_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\Party.txt';
u3Res = importdata(u3_path);
[m3,n3] = size(u3Res); %[124,32]
if(m3==124 && n3==32)
    acc3 = u3Res(:,1);
    avg3 = u3Res(:,2);
    rms3 = u3Res(1:124,3);
    max3 = u3Res(1:124,5);
    stu3 = u3Res(1:124,6);
    stuR3 = u3Res(1:124,11);
else
    disp(m3+"|"+n3)
end 
par=[mean(acc3),mean(avg3),mean(rms3),mean(max3)];
parStudy=[mean(stu3),mean(stuR3)];

%4-sport
u4_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\Sport.txt';
u4Res = importdata(u4_path);
[m4,n4] = size(u4Res); %[124,32]
if(m4==124 && n4==32)
    acc4 = u4Res(:,1);
    avg4 = u4Res(:,2);
    rms4 = u4Res(1:124,3);
    max4 = u4Res(1:124,5);
    stu4 = u4Res(1:124,6);
    stuR4 = u4Res(1:124,11);
else
    disp(m4+"|"+n4)
end 
spo=[mean(acc4),mean(avg4),mean(rms4),mean(max4)];
spoStudy=[mean(stu4),mean(stuR4)];



%%%%%%%SI stress measures
stress_path = 'D:\TEST\POSITIVE\Schedule\Result\EachEvent\stressAllteen.txt';
sRes = importdata(stress_path);
[ms,ns] = size(sRes); %[124,32]
if(ms==124 && ns==32)
    accs = sRes(:,1);
    avgs = sRes(:,2);
    rmss = sRes(1:124,3);
    maxs = sRes(1:124,5);
    stus = sRes(1:124,6);
    stuRs = sRes(1:124,11);
else
    disp(ms+"|"+ns)
end 
sall=[mean(accs),mean(avgs),mean(rmss),mean(maxs)];
sStudy=[mean(stus),mean(stuRs)];

%建立两个矩阵
stressMetrix = [act;hol;par;spo;sall];
%行:act;hol;par;spo;sall
%列:acc,avg,rms,max

studyMetrix = [actStudy;holStudy;parStudy;spoStudy;sStudy];
%行:act;hol;par;spo;sall
%列:study,study Ratio

%note:橙色为USI，红色为SI
figure
subplot(2,1,1)
c = categorical({'Practical actitivey USI','Holiday USI','Party USI','Sport USI','Exam SI'});
bar(c,stressMetrix);
%bar(stressMetrix);
%axis(['Practical actitivey USI','Holiday USI','Party USI','Sport USI','Exam SI'])
ylabel('Stress values')
title('Stress values during U-SI and SI')
series = {'Accumulated stress','Average stress','RMS of stress','Maximal stress'};
legend(series, 'Location', 'best')

subplot(2,1,2)
c2 = categorical({'Practical actitivey USI','Holiday USI','Party USI','Sport USI','Exam SI'});
bar(c2,studyMetrix);
ylabel('Academic stress')
title('Academic topic words during U-SI and SI')
series = {'Frequency of academic words','Ratio of academic stress'};
legend(series, 'Location', 'best')

