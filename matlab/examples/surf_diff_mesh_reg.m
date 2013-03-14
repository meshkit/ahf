function ps = surf_diff_mesh_reg(ps, tris, sibhes, v2he)
%#codegen -args {coder.typeof(double(0), [inf, 3]), coder.typeof(int32(0), [inf, 3]),
%# coder.typeof(int32(0), [inf, 3]), coder.typeof(int32(0), [inf, 1])} 

% This function implements the mesh regularization scheme used in Bansch,
% et. al. (2005).

nv=int32(size(ps,1));

nxt=[2, 3, 1];
prv=[3, 1, 2];

for i=1:nv
    % Determine neighboring faces and vertices.
    [~, ~, ngbfaces, nfaces] = obtain_1ring_surf( i, tris, sibhes, v2he, zeros(10,1,'int32'), zeros(10,1, 'int32'));   
    
    [face_norms, face_areas] = compute_face_normal_surf(ps, tris(ngbfaces(1:nfaces),:));
    
    weighted_norm = (face_norms'*face_areas)/sum(face_areas);
    
    % Now compute average of barycenters of neighboring faces
    barycenters=nullcopy(zeros(nfaces, 3));
    for j=1:nfaces
        barycenters(j,1:3)=sum(ps(tris(ngbfaces(j),:),:),1)/3.0;
    end
    
    avg_bcenter=sum(barycenters,1)/double(nfaces);
    
    % Now determine volumes of tets composed of avg_barycenter and each
    % face, and sum together.
    z1_num=ps(i,1:3)-avg_bcenter;
    
    num=0;          % Numerator
    denom=0;        % Denominator
    for j=1:nfaces
        index=find(tris(ngbfaces(j),:)==i); % junk should equal i
        
        nxt_pt=tris(ngbfaces(j),nxt(index));
        prv_pt=tris(ngbfaces(j),prv(index));
        z2 = ps(nxt_pt(1),1:3)-avg_bcenter;
        z3 = ps(prv_pt(1),1:3)-avg_bcenter;
        
        cross_num = cross( z1_num, z2);
        cross_denom = cross( weighted_norm, z2);
        
        num = num + cross_num*z3';
        denom = denom + cross_denom*z3';
    end
    
    t_factor = num/denom;       % Determines distance from avg_bcenter new point will be (moved along weighted_norm direction)
    
    ps(i,:) = avg_bcenter + t_factor*weighted_norm';
end

end
