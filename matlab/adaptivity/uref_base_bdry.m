function [xs, nverts, tris, ntris, parent_id, parent_coeff, inner_nodes]=uref_base_bdry(xs, nverts, nv_orig, tris, ntris, curr_tri, bdry_hi, deg, parent_id, parent_coeff)
if deg==1
    inner_nodes=bdry_hi(3,1);
    return
end
assert(size(bdry_hi,1)==3&&size(bdry_hi,2)==1+deg);
%xs =[xs;zeros((deg-2)*(deg-1)/2, 3)];
istrt_id =nverts-nv_orig;
%parent_id =[parent_id; zeros((deg-2)*(deg-1)/2, 3)];
%parent_coeff =[parent_coeff; zeros((deg-2)*(deg-1)/2, 3)];
inner_nodes =zeros((deg)*(deg+1)/2, 1);
istrt=1;
tris =[tris; zeros(deg*deg, 3)];
down=bdry_hi(1,:);
for level=2:deg
    v1 =bdry_hi(3,end-level+1);
    v2 =bdry_hi(2,level);
    step =(xs(v2,:)-xs(v1,:))/(deg-level+1);
    top =zeros(deg+2-level,1);
    top(1) =v1; top(end) =v2;
    for i=1:size(top,1)-2
        nverts =nverts+1;
        xs(nverts,:) =xs(v1,:)+i*step;
        istrt_id =istrt_id+1;
        parent_id(istrt_id)=curr_tri;
        for kk=1:3
            if bdry_hi(1,1)==tris(parent_id(v1-nv_orig),kk)
                parent_coeff(istrt_id,1) =parent_coeff(istrt_id,1)+(1-i/(deg-level+1))*parent_coeff(v1-nv_orig,kk);
            else
                if bdry_hi(3,1)==tris(parent_id(v1-nv_orig),kk)
                    parent_coeff(istrt_id,3) =parent_coeff(istrt_id,3)+(1-i/(deg-level+1))*parent_coeff(v1-nv_orig,kk);
                end
            end
            if bdry_hi(2,1)==tris(parent_id(v2-nv_orig),kk)
                parent_coeff(istrt_id,2) =parent_coeff(istrt_id,2)+(i/(deg-level+1))*parent_coeff(v2-nv_orig,kk);
            else
                if bdry_hi(3,1)==tris(parent_id(v2-nv_orig),kk)
                    parent_coeff(istrt_id,3) =parent_coeff(istrt_id,3)+(i/(deg-level+1))*parent_coeff(v2-nv_orig,kk);
                end
            end
        end
        top(i+1) =nverts;
    end
    inner_nodes(istrt:istrt+numel(top)-1) =top(1:end);
    istrt =istrt+numel(top);
    ntris =ntris+1;
    tris(ntris,:) =[top(1), down(1), down(2)];
    for i=2:numel(top)
        ntris =ntris+1;
        tris(ntris,:) =[top(i-1), down(i), top(i)];
        ntris =ntris+1;
        tris(ntris,:) =[top(i), down(i), down(i+1)];
    end
    down=top;
end
ntris =ntris+1;
tris(ntris,:) =[bdry_hi(3,1), bdry_hi(3,2), bdry_hi(2,end-1)];
inner_nodes(end)=bdry_hi(3,1);