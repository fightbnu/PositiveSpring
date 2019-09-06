%Impact: I1,I2,I3,I4,without
%thresh (avgHis)
%Topic: 0,1,2,3,4
%Interval: 1,2,3,4,5,6,7,8,9,10; lenHis

%M1: Correlation distribution
%5 Topic
C0 = [];
C1 = [];
C2 = [];
C3 = [];
C4 = [];
for T=0:1:4
    path_cor1 = ['E:\TEST\POSITIVE\Pair\correlation\','corStress',num2str(T),'.txt'];
    path_cor2 = ['E:\TEST\POSITIVE\Pair\correlation\','corStressor',num2str(T),'.txt'];
    path_cor3 = ['E:\TEST\POSITIVE\Pair\correlation\','corPost',num2str(T),'.txt'];
    cor1 = importdata(path_cor1);
    cor2 = importdata(path_cor2);
    cor3 = importdata(path_cor3);
    if T==0
        C0 = [C0,cor1];
        C0 = [C0,cor2];
        C0 = [C0,cor3];
    end
    if T==1
        C1 = [C1,cor1];
        C1 = [C1,cor2];
        C1 = [C1,cor3];
    end
    if T==2
        C2 = [C2,cor1];
        C2 = [C2,cor2];
        C2 = [C2,cor3];
    end
    if T==3
        C3 = [C3,cor1];
        C3 = [C3,cor2];
        C3 = [C3,cor3];
    end
    if T==4
        C4 = [C4,cor1];
        C4 = [C4,cor2];
        C4 = [C4,cor3];
    end
end

corMeans = [mean(C0);mean(C1);mean(C2);mean(C3);mean(C4)];
corSTDs = [std(C0);std(C1);std(C2);std(C3);std(C4)];

figure
errorbar(corMeans,corSTDs,'s')
%title('Correlation towards each types of stressor events')
xlabel('Event dimension')
ylabel('Value of correlation')
box on

xaxis={'School life','Romantic','Peer','Self-cognition','Family life'};
set(gca,'XTick',1:5,'XTickLabel',xaxis);

legendMeas={'Stress correlation','Linguistic correlation','Post correlation'};
legend(legendMeas,'Location','NorthWest');