function tf = snctools_use_tmw()

switch ( version('-release') )
    case { '11', '12', '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		tf = false;
	otherwise
		v = mexnc('inq_libvers');
		if (v(1) == '4')
			tf = false;
		else
			tf = true;
		end
end

