function [nds_redge,nmbn,num1,num2]=obtain_tri_nodes_around_edge(edge,sibhes,...
    tris,v2he,nds_redge) %#codegen 
ngbes1=nullcopy(zeros(128,1,'int32'));
ngbes2=nullcopy(zeros(128,1,'int32'));
[ngbvs1, num1] = obtain_1ring_surf( edge(1), tris, sibhes, v2he, ...
                    nds_redge,ngbes1);
[ngbvs2, num2] = obtain_1ring_surf( edge(2), tris, sibhes, v2he, ...
                    nds_redge,ngbes2);
nmbn=num1+num2-4;
count=int32(0);
pivot=find(ngbvs1(1:num1)==edge(2));
next=mod(pivot,num1)+1;
startnode=ngbvs1(next);
for ii=1:num1;
    if(ngbvs1(next)~=edge(2))
        count=count+1;
        nds_redge(count)=ngbvs1(next);
    end
    next=mod(next,num1)+1;
end
pivot=find(ngbvs2(1:num2)==nds_redge(count));
next=mod(pivot,num2)+1;
for ii=1:num2;
    if(ngbvs2(next)==startnode);break;end
    if(ngbvs2(next)~=edge(1))
        count=count+1;
        nds_redge(count)=ngbvs2(next);
    end
    next=mod(next,num2)+1;
end
        
return
end
