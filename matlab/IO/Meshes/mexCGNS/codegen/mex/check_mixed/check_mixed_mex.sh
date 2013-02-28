MATLAB="/Applications/MATLAB_R2012a.app"
Arch=maci64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/Users/vladimir/.matlab/R2012a"
OPTSFILE_NAME="./mexopts.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for check_mixed" > check_mixed_mex.mki
echo "CC=$CC" >> check_mixed_mex.mki
echo "CFLAGS=$CFLAGS" >> check_mixed_mex.mki
echo "CLIBS=$CLIBS" >> check_mixed_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> check_mixed_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> check_mixed_mex.mki
echo "CXX=$CXX" >> check_mixed_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> check_mixed_mex.mki
echo "CXXLIBS=$CXXLIBS" >> check_mixed_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> check_mixed_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> check_mixed_mex.mki
echo "LD=$LD" >> check_mixed_mex.mki
echo "LDFLAGS=$LDFLAGS" >> check_mixed_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> check_mixed_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> check_mixed_mex.mki
echo "Arch=$Arch" >> check_mixed_mex.mki
echo OMPFLAGS= >> check_mixed_mex.mki
echo OMPLINKFLAGS= >> check_mixed_mex.mki
echo "EMC_COMPILER=" >> check_mixed_mex.mki
echo "EMC_CONFIG=optim" >> check_mixed_mex.mki
"/Applications/MATLAB_R2012a.app/bin/maci64/gmake" -B -f check_mixed_mex.mk
