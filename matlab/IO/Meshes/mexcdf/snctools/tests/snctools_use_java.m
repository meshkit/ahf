function tf = snctools_use_java()


import ucar.nc2.dods.*     % import opendap reader classes
import ucar.nc2.*          
                           
tf = false;
if exist('NetcdfFile') == 8
	tf = true;
end


