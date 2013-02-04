function hvid = elvids2hvid(eid, lvid) %#codegen 
% Encode <eid,lvid> pair into a hvid.
% HVID = ELVIDS2HVID(EID, LVID)
% See also HVID2EID, HVID2LVID

hvid = eid*2+lvid-1;
