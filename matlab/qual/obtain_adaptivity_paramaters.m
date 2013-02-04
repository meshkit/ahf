function [s,S,l,L,r,R,theta_s,theta_l] = obtain_adaptivity_paramaters(ps, tris)
%#codegen -args { coder.typeof(double(0), [Inf 3]), coder.typeof(int32(0), [Inf 3])}

% Get face normals and face areas
[nrms,tris_area] = compute_face_normal_surf( ps, tris);

% Create W with weights as diagonal elements
ne = int32(size(tris,1));
% W = nullcopy(zeros(ne,ne));
% % W = spalloc(ne,ne,ne+1);
% for ii = 1:ne
%     W(ii,ii) = tris_area(ii,1);
% end

% % Create quadric metric tensor A = N'*W*N
% A = nrms'*W_vect.*nrms;

W_vect = tris_area;

% % Create quadric metric tensor A = N'*W*N
Wn = nullcopy(zeros(size(nrms)));
for ii = 1:int32(size(nrms,1));
    Wn(1,1) = W_vect(ii)*nrms(ii,1);
    Wn(1,2) = W_vect(ii)*nrms(ii,2);
    Wn(1,3) = W_vect(ii)*nrms(ii,3);
end

% Create quadric metric tensor A = N'*W*N
A = nrms'*Wn;

% Obtain Eigenvectors and Eigenvalues
[V,lambdas] = eig3_abssorted(A); 

% Obtain parameter values
[avg_edgelength] = obtain_avg_edgelength(ps,tris); % For l value
psi1 = lambdas(1,1)*(tand(4))^2;
psi2 = lambdas(1,1)*(tand(15))^2;
r = 0.1;
R = 0.5;
l = avg_edgelength*0.9;% adjustable
s = l*sqrt(psi1/psi2);
S = R*l;
L = 1.5*l;
% theta_s = 2*atand(sqrt(psi1/psi2));
theta_s = atand(sqrt(psi1/psi2));
theta_l = 160;



function [avg_edgelength] = obtain_avg_edgelength(ps,tris)
%#codegen -args { coder.typeof(double(0), [Inf 3]), coder.typeof(int32(0), [Inf 3])}

% Obtain halfedge lengths
helengths = nullcopy(zeros(size(tris,1),3));
for ii = 1:int32(size(tris,1))
    for jj = 1:3
        if jj == 3
            helengths(ii,jj) = sqrt((ps(tris(ii,jj),1)-ps(tris(ii,jj-2),1))^2 +...
                (ps(tris(ii,jj),2)- ps(tris(ii,jj-2),2))^2 +...
                (ps(tris(ii,jj),3)- ps(tris(ii,jj-2),3))^2);
        else
            helengths(ii,jj) = sqrt((ps(tris(ii,jj+1),1)-ps(tris(ii,jj),1))^2 +...
                (ps(tris(ii,jj+1),2)- ps(tris(ii,jj),2))^2 +...
                (ps(tris(ii,jj+1),3)- ps(tris(ii,jj),3))^2);
        end
    end
end

% Find average
total_edgelength = sum(sum(helengths));
n_hes = int32(size(helengths,1))*size(helengths,2);
avg_edgelength = total_edgelength/n_hes;
