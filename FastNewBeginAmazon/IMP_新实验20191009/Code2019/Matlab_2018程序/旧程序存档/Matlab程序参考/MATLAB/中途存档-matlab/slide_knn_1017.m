load examgrades

%INPUT-FILE
foutPath=['E:\TEST\Predict\DayStaFilter\Correlation\','correlation_124.txt'];
fout=fopen(foutPath,'w');

datalist_random=dir('E:\TEST\Predict\DayStaFilter\randomSlide\*.txt');  %random-slide
datalist_stressor=dir('E:\TEST\Predict\DayStaFilter\slide\*.txt');      %stressor-slide
datalist_name=dir('E:\TEST\Predict\DayStaFilter\name\*.txt');  %random-slide

for pos=1:length(datalist_stressor)
    finRandomPath=['E:\TEST\Predict\DayStaFilter\randomSlide\',datalist_random(pos).name];
    finStressorPath=['E:\TEST\Predict\DayStaFilter\slide\',datalist_stressor(pos).name];
    finNamePath=['E:\TEST\Predict\DayStaFilter\name\',datalist_name(pos).name];
    x = importdata(finRandomPath);
    y = importdata(finStressorPath);   
    name = importdata(finNamePath);
    
    %1)Input: random slide
    [m_r,n_r] = size(x);
    id_r = ones(m_r,1);
    for i=1:1:m_r
        id_r(i,1)=i;
    end
    X=[id_r x];

    %1)Input: slide
    [m,n] = size(y);
    id = ones(m,1);
    for i=1:1:m
        id(i,1)=i;
    end
    Y=[id,y];

    %1)Combine-input: slide+random slide
    [m_name,n_name]=size(name);
    if(~(m_r==2*m && (m_r+m)==m_name))
        disp('FILE NOT EQUAL');
        pause;
    end  
    z=[y;x];%按行合并
    id_z = ones(m_r+m,1);
    for i=1:1:m_r+m
        id_z(i,1)=i;
    end
    Z=[id_z,z];
    
    %1)Example points
    %q=y(1:3,:);
    %Q=Y([1,12,24],:);
    
    %2)TEST-KNN-method (2 methods)
    [N,D]=knnsearch(z,z,'k',3,'distance','minkowski','p',5);%!!!!!!!!!!!
    [ncb,dcb]=knnsearch(z,y,'k',3,'distance','chebychev');
    
    %3)TEST-散点图
    gscatter(Z(:,1),Z(:,9),name);
    
    %line(Q(:,1),Q(:,9),'marker','x','color','k','markersize',10,'linewidth',2,'linestyle','none'); %sample points
    % line(Z(N,1),Z(N,9),'color',[.5 .5 .5],'marker','o','linestyle','none','markersize',10);        %method1 points
    line(Z(ncb,1),Z(ncb,9),'color',[.5 .5 .5],'marker','p','linestyle','none','markersize',10);    %method2 points
    legend('event','random','query point','minkowski','chebychev','Location','best');
    
    %4) Calculate step1. 统计ratio
    [size1_N,size2_N]=size(N);
    a=0;
    for i=1:1:m_r
        for j=1:1:size2_N
            if(N(i,j)<=m_r)
                a = a+1;
            end
        end
    end

    for i=m_r+1:1:size1_N
        for j=1:1:size2_N
            
            if(N(i,j)>m_r)
                a = a+1;
            end
        end
    end

    %4) Calculate step2: if >1.96
    b=a/(size1_N*size2_N);
    lam1=m_r/size1_N;
    lam2=m/size1_N;
    u=lam1^2+lam2^2;
    div_2 = lam1*lam2 + 4*lam1^2*lam2^2;
    res = sqrt(size1_N*size2_N)*(b-u)/div_2;
    fprintf(fout,'%.4f %s\r\n',res,datalist_stressor(pos).name);
    
    disp(datalist_stressor(pos).name);
    pause;
end

fclose(fout);





%----TEST: if obey Guassian distribution
%mid =  sqrt(size1_N*size2_N)*(b-u)/sqrt(div_2);
%h_mid = ttest([mid;mid;mid;mid]);%行列都可以

%----TEST: if can use ttest for vector...(Yes, but not the comprehensive)
%test_why = ttest(y);

%----TEST ttest()
%Function: ttest
%x1 = grades(:,1);
%y1 = grades(:,2);
%[h1,p1] = ttest(x1,y1); %ttest
%[h2,p2] = ttest2(x1,y1,'Alpha',0.05); %ttest2



