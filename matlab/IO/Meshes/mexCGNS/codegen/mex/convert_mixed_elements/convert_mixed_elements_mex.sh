MATLAB="/Applications/MATLAB_R2012a.app"
Arch=maci64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/Users/vladimir/.matlab/R2012a"
OPTSFILE_NAME="./mexopts.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for convert_mixed_elements" > convert_mixed_elements_mex.mki
echo "CC=$CC" >> convert_mixed_elements_mex.mki
echo "CFLAGS=$CFLAGS" >> convert_mixed_elements_mex.mki
echo "CLIBS=$CLIBS" >> convert_mixed_elements_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> convert_mixed_elements_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> convert_mixed_elements_mex.mki
echo "CXX=$CXX" >> convert_mixed_elements_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> convert_mixed_elements_mex.mki
echo "CXXLIBS=$CXXLIBS" >> convert_mixed_elements_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> convert_mixed_elements_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> convert_mixed_elements_mex.mki
echo "LD=$LD" >> convert_mixed_elements_mex.mki
echo "LDFLAGS=$LDFLAGS" >> convert_mixed_elements_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> convert_mixed_elements_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> convert_mixed_elements_mex.mki
echo "Arch=$Arch" >> convert_mixed_elements_mex.mki
echo OMPFLAGS= >> convert_mixed_elements_mex.mki
echo OMPLINKFLAGS= >> convert_mixed_elements_mex.mki
echo "EMC_COMPILER=" >> convert_mixed_elements_mex.mki
echo "EMC_CONFIG=optim" >> convert_mixed_elements_mex.mki
"/Applications/MATLAB_R2012a.app/bin/maci64/gmake" -B -f convert_mixed_elements_mex.mk
