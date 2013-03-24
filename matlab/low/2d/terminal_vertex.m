function v = terminal_vertex( elems, heid) %#codegen 
% TERMINAL_VERTEX  Obtains the ID of the terminal vertex from a half-edge ID.
next=int32([2,3,1]);
v = elems( heid2fid(heid), next(heid2leid(heid)));
