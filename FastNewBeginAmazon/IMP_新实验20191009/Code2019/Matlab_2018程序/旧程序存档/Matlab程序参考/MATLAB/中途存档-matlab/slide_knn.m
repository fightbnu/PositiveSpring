x = importdata('ra2.txt');%random
y = importdata('a2.txt'); 
name = importdata('na2.txt');

%random slide
[m_r,n_r] = size(x);
id_r = ones(m_r,1);
for i=1:1:m_r
    id_r(i,1)=i;
end
X=[id_r x];

%slide
[m,n] = size(y);
id = ones(m,1);
for i=1:1:m
    id(i,1)=i;
end
Y=[id,y];

%combine slide+random slide
z=[y;x];
id_z = ones(m_r+m,1);
for i=1:1:m_r+m
    id_z(i,1)=i;
end
Z=[id_z,z];

q=y(1:3,:);
Q=Y([1,12,24,28],:);

[N,D]=knnsearch(z,q,'k',3,'distance','minkowski','p',5);
[ncb,dcb]=knnsearch(z,q,'k',3,'distance','chebychev');
gscatter(Z(:,1),Z(:,9),name);
line(Q(:,1),Q(:,9),'marker','x','color','k','markersize',10,'linewidth',2,'linestyle','none');
line(Z(N,1),Z(N,9),'color',[.5 .5 .5],'marker','o','linestyle','none','markersize',10);
line(Z(ncb,1),Z(ncb,9),'color',[.5 .5 .5],'marker','p','linestyle','none','markersize',10);
legend('event','random','query point','minkowski','chebychev','Location','best');
