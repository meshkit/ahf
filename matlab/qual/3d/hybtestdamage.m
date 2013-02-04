function [iflag,damage]=hybtestdamage(i1,i2,i3,i4,toldamage,xs)  %#codegen
% ######################################################################
%
%     PURPOSE -
%
%        This routine determines whether or not replacing the
%        connection i1-i3 with the connection i2-i4 (or vice versa)
%        would case linear deformation ('damage') exceeding TOLDAMAGE.
%
%     INPUT ARGUMENTS -
%
%        i1-i4    - the points involved, in cyclic order.
%
%     OUTPUT ARGUMENTS -
%
%        iflag    - 0 => flip causes more than acceptable damage
%                   1 => flip causes acceptable damage
%
% ######################################################################
%
%
%Check that the 'damage' of performing a flip is less than
%TOLDAMAGE.  The damage will be nonzero if the points i1, i2,
%i3, i4 do not all lie in the same plane.  The damage is defined
%in a similar fashion as in the subroutine AGD3D.

iflag=1;

%Form aggregate normal:  Area-weighted normal formed from the
%two boundary triangles [triangle (i1,i3,i4) and triangle (i3,i1,i2)].

a134x=crosx1(i1,i3,i4,xs);
a134y=crosy1(i1,i3,i4,xs);
a134z=crosz1(i1,i3,i4,xs);
a312x=crosx1(i3,i1,i2,xs);
a312y=crosy1(i3,i1,i2,xs);
a312z=crosz1(i3,i1,i2,xs);
atotx=a134x+a312x;
atoty=a134y+a312y;
atotz=a134z+a312z;
atot=sqrt(atotx^2+atoty^2+atotz^2);
atotx=atotx/atot;
atoty=atoty/atot;
atotz=atotz/atot;

%Calculate midpoint of edge (i1,i3)

xmid=0.5*(xs(i1,1)+xs(i3,1));
ymid=0.5*(xs(i1,2)+xs(i3,2));
zmid=0.5*(xs(i1,3)+xs(i3,3));

%If both boundary triangle normals are in the same direction as
%aggregate normal, damage is defined to be separation between two
%planes (normal to agg. normal) that sandwich the points i1, i2,
%i3, i4.  If one of the boundary triangle normals points contrary
%to the agg. normal, damage is defined as minimum of 'merge
%distances' from the midpoint of edge (i1,i3) to the points i2, i4.

dot134=a134x*atotx+a134y*atoty+a134z*atotz;
dot312=a312x*atotx+a312y*atoty+a312z*atotz;

if(dot134>0 && dot312>0) ;

  dot1=(xs(i1,1)-xmid)*atotx+(xs(i1,2)-ymid)*atoty+(xs(i1,3)-zmid)*atotz;
  dot2=(xs(i2,1)-xmid)*atotx+(xs(i2,2)-ymid)*atoty+(xs(i2,3)-zmid)*atotz;
  dot3=(xs(i3,1)-xmid)*atotx+(xs(i3,2)-ymid)*atoty+(xs(i3,3)-zmid)*atotz;
  dot4=(xs(i4,1)-xmid)*atotx+(xs(i4,2)-ymid)*atoty+(xs(i4,3)-zmid)*atotz;
  dotmin=min([dot1,dot2,dot3,dot4]);
  dotmax=max([dot1,dot2,dot3,dot4]);
  damage=dotmax-dotmin;
  if(damage>toldamage)
    iflag=int32(0); 
  end;

  else

  dist2=sqrt((xs(i2,1)-xmid)^2+(xs(i2,2)-ymid)^2+(xs(i2,3)-zmid)^2);
  dist4=sqrt((xs(i4,1)-xmid)^2+(xs(i4,2)-ymid)^2+(xs(i4,3)-zmid)^2);
  damage=min([dist2,dist4]);
  if(damage>toldamage)
    iflag=int32(0); 
  end;

end;
if(iflag==1);
  %We now add a test that requires that the new triangle normals
  %make a positive dot product with synthetic normal of the old
  %edge i1-i3.
  n134=sqrt(a134x^2+a134y^2+a134z^2);
  n134x=a134x/n134;
  n134y=a134y/n134;
  n134z=a134z/n134;
  n312=sqrt(a312x^2+a312y^2+a312z^2);
  n312x=a312x/n312;
  n312y=a312y/n312;
  n312z=a312z/n312;
  a124x=crosx1(i1,i2,i4,xs);
  a124y=crosy1(i1,i2,i4,xs);
  a124z=crosz1(i1,i2,i4,xs);
  a234x=crosx1(i2,i3,i4,xs);
  a234y=crosy1(i2,i3,i4,xs);
  a234z=crosz1(i2,i3,i4,xs);
  dot1=a124x*(n134x+n312x)+a124y*(n134y+n312y)+a124z*(n134z+n312z);
  dot2=a234x*(n134x+n312x)+a234y*(n134y+n312y)+a234z*(n134z+n312z);
  if((dot1<=0.0e0)||(dot2<=0.0e0))
  iflag=0; 
  end;
end;
return;
end



function result=crosx1(i1,i2,i3,xs)
result=(xs(i2,2)-xs(i1,2))*(xs(i3,3)-xs(i1,3))-...
      (xs(i3,2)-xs(i1,2))*(xs(i2,3)-xs(i1,3));
return;
end
 %
function result=crosy1(i1,i2,i3,xs)
result=(xs(i3,1)-xs(i1,1))*(xs(i2,3)-xs(i1,3))-...
      (xs(i2,1)-xs(i1,1))*(xs(i3,3)-xs(i1,3));
return;
end
 %
function result=crosz1(i1,i2,i3,xs)
result=(xs(i2,1)-xs(i1,1))*(xs(i3,2)-xs(i1,2))-...
      (xs(i3,1)-xs(i1,1))*(xs(i2,2)-xs(i1,2));
return
end

