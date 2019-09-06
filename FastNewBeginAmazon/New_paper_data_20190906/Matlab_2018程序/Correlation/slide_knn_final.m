load examgrades

dim=['1','2','3','4','5'];

for DIM=1:1:5
   
    %INPUT-FILE
    foutPath=['E:\TEST\Predict\DayStaFilter\Correlation\correlation_',dim(DIM),'.txt'];
    disp(foutPath);
    fout=fopen(foutPath,'w');
    foutPath_stressor=['E:\TEST\Predict\DayStaFilter\Correlation\correlationStressor_',dim(DIM),'.txt'];
    fout_stressor=fopen(foutPath_stressor,'w');

    %stress
    datalist_random=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide\*.txt']);  %random-slide
    datalist_stress=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide\*.txt']);      %stressor-slide
    %stressor
    datalist_random_stressor=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide_stressor\*.txt']);  %random-slide
    datalist_stressor=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide_stressor\*.txt']);      %stressor-slide
    %name
    datalist_name=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\name\*.txt']);  %random-slide

    corRes=0;
    corRes_stressor=0;
    
    for pos=1:length(datalist_stress)
        %stress
        finRandomPath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide\',datalist_random(pos).name];
        finStressPath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide\',datalist_stress(pos).name];
        %stressor
        finRandomPath_stressor=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide_stressor\',datalist_random_stressor(pos).name];
        finStressPath_stressor=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide_stressor\',datalist_stressor(pos).name];
        %name
        finNamePath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\name\',datalist_name(pos).name];
        
        x = importdata(finRandomPath);
        y = importdata(finStressPath);   
        x_stressor=importdata(finRandomPath_stressor);
        y_stressor=importdata(finStressPath_stressor);
        name = importdata(finNamePath);

        %1)Input: random slide
        [m_r,n_r] = size(x);
        id_r = ones(m_r,1);
        for i=1:1:m_r
            id_r(i,1)=i;
        end
        X=[id_r,x];
        X_Stressor=[id_r,x_stressor];

        %1)Input: slide
        [m,n] = size(y);
        id = ones(m,1);
        for i=1:1:m
            id(i,1)=i;
        end
        Y=[id,y];
        Y_Stressor=[id,y_stressor];

        %1)Combine-input: slide+random slide
        [m_name,n_name]=size(name);
        if(~(m_r==2*m && (m_r+m)==m_name))
            disp('FILE NOT EQUAL');
            pause;
        end  
        z=[y;x];%按行合并
        z_stressor=[y_stressor;x_stressor];
        id_z = ones(m_r+m,1);
        for i=1:1:m_r+m
            id_z(i,1)=i;
        end
        Z=[id_z,z];
        Z_Stressor=[id_z,z_stressor];

        %1)Example points
        %q=y(1:3,:);
        %Q=Y([1,12,24],:);

        %2)TEST-KNN-method (2 methods)
        [N,D]=knnsearch(z,z,'k',3,'distance','minkowski','p',5);%!!!!!!!!!!!
        [ncb,dcb]=knnsearch(z,y,'k',3,'distance','chebychev');

        [N_stressor,D_stressor]=knnsearch(z_stressor,z_stressor,'k',3,'distance','minkowski','p',5);%!!!!!!!!!!!
        [ncb_2,dcb_2]=knnsearch(z_stressor,y_stressor,'k',3,'distance','chebychev');
        
        %3)TEST-散点图
        %gscatter(Z(:,1),Z(:,9),name);
        %line(Q(:,1),Q(:,9),'marker','x','color','k','markersize',10,'linewidth',2,'linestyle','none'); %sample points
        % line(Z(N,1),Z(N,9),'color',[.5 .5 .5],'marker','o','linestyle','none','markersize',10);        %method1 points
        %line(Z(ncb,1),Z(ncb,9),'color',[.5 .5 .5],'marker','p','linestyle','none','markersize',10);    %method2 points
        %legend('event','random','query point','minkowski','chebychev','Location','best');

        %4) Calculate step1. 统计ratio
        %[1]ratio-stress
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
        %end-stress
        
        %[2]ratio-stressor
        [size1_NS,size2_NS]=size(N_stressor);
        a_stressor=0;
        for i=1:1:m_r
            for j=1:1:size2_NS
                if(N_stressor(i,j)<=m_r)
                    a_stressor = a_stressor+1;
                end
            end
        end

        for i=m_r+1:1:size1_NS
            for j=1:1:size2_NS
                if(N_stressor(i,j)>m_r)
                    a_stressor = a_stressor+1;
                end
            end
        end
        %end-stressor       

        %4) Calculate step2: if >1.96
        %[1]stress
        b=a/(size1_N*size2_N);
        lam1=m_r/size1_N;
        lam2=m/size1_N;
        u=lam1^2+lam2^2;
        div_2 = lam1*lam2 + 4*lam1^2*lam2^2;
        if(div_2>0)
            res = sqrt(size1_N*size2_N)*(b-u)/div_2;
        else
            res=0;
        end

        fprintf(fout,'%.4f %s\r\n',res,datalist_stress(pos).name);
        corRes = corRes+res;
        disp(datalist_stress(pos).name);
        %end-stress
        
        %[2]stressor
        b_s=a_stressor/(size1_NS*size2_NS);%ratio
        if(div_2>0)
            res_stressor = sqrt(size1_N*size2_N)*(b_s-u)/div_2;
        else
            res_stressor=0;
        end

        %stress
        fprintf(fout,'%.4f %s\r\n',res,datalist_stress(pos).name);
        corRes = corRes+res;
        %stressor
        fprintf(fout_stressor,'%.4f %s\r\n',res_stressor,datalist_stress(pos).name);
        corRes_stressor = corRes_stressor+res_stressor;
        
        disp(datalist_stress(pos).name);
        %end-stressor
        
    end

    avgCor = corRes*1.0/124;
    avgCor_stressor = corRes_stressor*1.0/124;

    fprintf(fout,'%.4f avg \r\n',avgCor);
    fprintf(fout_stressor,'%.4f avg \r\n',avgCor_stressor);
    
    fclose(fout);
    fclose(fout_stressor);
end



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



