function [solution,rmse,cor1_new,cor2_new]=ransac(cor1,cor2,change_form,error_t)
%�ú�����ransac�㷨�ľ���ʵ�֣����㷨��Ҫ������ݵ���ϣ������Ŀ�������һ�����α任
%cor1�Ǵ���׼ͼ���е�����㣬��һ��M*2�ľ���ÿһ�зֱ���һ�����x��y����
%cor2�ǲο�ͼ���е������
%change_form����ϵļ��α任���ͣ�����Ŀǰ֧�֡����Ʊ任���͡�����任��
%solution�Ǽ���ļ��α任ģ�Ͳ�����rmse�Ǽ���ı任���
%cor1_new��cor1�����������ĵ�ļ���
%cor2_new��cor2�����������ĵ�ļ���
%error_t;%�����ֵ

%% ������ʼ��
[M,N]=size(cor1);
if(strcmp(change_form,'Similarity'))
    n=2;%�������Ʊ任��Ҫ����ģ�Ͳ����ĵ������2
    max_iteration=M*(M-1)/2;
elseif(strcmp(change_form,'Affine'))
    n=3;%���ڷ���任��Ҫ����ģ�Ͳ����ĸ�����3
    max_iteration=M*(M-1)*(M-2)/(2*3);
end
if(max_iteration>2000)
    iterations=2000;
else
    iterations=max_iteration;%�㷨��������
end
consensus_number=0.05*M;%һ�¼���С������ֵ��10
%consensus_number=M;%һ�¼���С������ֵ��10
consensus_number=max(consensus_number,n);
best_solution=zeros(3,3);%��ʼ����Ϊ3*3�ľ���
most_consensus_number=0;%��ʼ����ʼһ�¼�������С
rmse=10000;
cor1_new=zeros(M,N);
cor2_new=zeros(M,N);

%%
rand('seed',0);
for i=1:1:iterations
    while(1)%���������������ȵ�����
        a=floor(1+(M-1)*rand(1,n));
        cor11=cor1(a,1:2);%���ѡ���n�����
        cor22=cor2(a,1:2);
        if(n==2 && (a(1)~=a(2)) && sum(cor11(1,1:2)~=cor11(2,1:2),2) &&...
                sum(cor22(1,1:2)~=cor22(2,1:2)))
            break;
        end
        if(n==3 && (a(1)~=a(2) && a(1)~=a(3) && a(2)~=a(3)) && ...
        sum(cor11(1,1:2)~=cor11(2,1:2)) && sum(cor11(1,1:2)~=cor11(3,1:2)) && sum(cor22(2,1:2)~=cor11(3,1:2))...
        && sum(cor22(1,1:2)~=cor22(2,1:2)) && sum(cor22(1,1:2)~=cor22(3,1:2)) && sum(cor22(2,1:2)~=cor22(3,1:2)))
            break;
        end       
    end
      
    [parameters,~]=LSM(cor11,cor22,change_form);
    solution=[parameters(1),parameters(2),parameters(5);
        parameters(3),parameters(4),parameters(6);
        parameters(7),parameters(8),1];
    match1_xy=cor1(:,1:2)';
    match1_xy_1=[match1_xy;ones(1,M)];
    t_match1_xy=solution*match1_xy_1;
    match2_xy=cor2(:,1:2)';
    match2_xy_2=[match2_xy;ones(1,M)];
    diff_match2_xy=t_match1_xy-match2_xy_2;
    diff_match2_xy=sqrt(sum(diff_match2_xy.^2));
    index_in=find(diff_match2_xy < error_t);%����һ�������ĵ������
    consensus_num=size(index_in,2);%����������һ�¼��ϵ����
  
    %if(consensus_num>consensus_number)%�������һ�¼�����Ҫ��   
        if(consensus_num>most_consensus_number)
            most_consensus_number=consensus_num;
            cor1_new=cor1(index_in,:);
            cor2_new=cor2(index_in,:);
        end
    %end
end

%ɾ���ظ���Ժ��ٴμ���任�����ϵ
uni1=cor1_new(:,[1 2]);
[~,i,~]=unique(uni1,'rows','first');
cor1_new=cor1_new(sort(i)',:);cor2_new=cor2_new(sort(i)',:);
uni1=cor2_new(:,[1 2]);
[~,i,~]=unique(uni1,'rows','first');
cor1_new=cor1_new(sort(i)',:);cor2_new=cor2_new(sort(i)',:);

[parameters,rmse]=LSM(cor1_new(:,1:2),cor2_new(:,1:2),change_form);
solution=[parameters(1),parameters(2),parameters(5);
    parameters(3),parameters(4),parameters(6);
    parameters(7),parameters(8),1];

end
























