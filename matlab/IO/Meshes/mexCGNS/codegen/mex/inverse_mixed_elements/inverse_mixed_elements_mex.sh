MATLAB="/Applications/MATLAB_R2012a.app"
Arch=maci64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/Users/vladimir/.matlab/R2012a"
OPTSFILE_NAME="./mexopts.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for inverse_mixed_elements" > inverse_mixed_elements_mex.mki
echo "CC=$CC" >> inverse_mixed_elements_mex.mki
echo "CFLAGS=$CFLAGS" >> inverse_mixed_elements_mex.mki
echo "CLIBS=$CLIBS" >> inverse_mixed_elements_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> inverse_mixed_elements_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> inverse_mixed_elements_mex.mki
echo "CXX=$CXX" >> inverse_mixed_elements_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> inverse_mixed_elements_mex.mki
echo "CXXLIBS=$CXXLIBS" >> inverse_mixed_elements_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> inverse_mixed_elements_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> inverse_mixed_elements_mex.mki
echo "LD=$LD" >> inverse_mixed_elements_mex.mki
echo "LDFLAGS=$LDFLAGS" >> inverse_mixed_elements_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> inverse_mixed_elements_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> inverse_mixed_elements_mex.mki
echo "Arch=$Arch" >> inverse_mixed_elements_mex.mki
echo OMPFLAGS= >> inverse_mixed_elements_mex.mki
echo OMPLINKFLAGS= >> inverse_mixed_elements_mex.mki
echo "EMC_COMPILER=" >> inverse_mixed_elements_mex.mki
echo "EMC_CONFIG=optim" >> inverse_mixed_elements_mex.mki
"/Applications/MATLAB_R2012a.app/bin/maci64/gmake" -B -f inverse_mixed_elements_mex.mk
