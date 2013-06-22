echo "\nPrep/Setup"
echo "~~~~~~~~~~"

echo "pyclaw_prep               - set up build environment"
pyclaw_prep() {
  projdir=/home/amal/tools/test_build64

  sandbox=${projdir}/sandbox
  echo "sandbox=${sandbox}"
  builddir=${projdir}/opt/share
  echo "builddir=${builddir}"
  logdir=${builddir}/logs
  echo "logdir=${logdir}"
  srcdir=${builddir}/sources
  echo "srcdir=${srcdir}"

  mkdir -p ${sandbox} ${builddir} ${logdir} ${srcdir}

  #disable_threads="yes"

  #if [ disable_threads == "yes" ] ; then
  #threads_flag="--without-threads"
  #  echo "Python and extension modules will be built without thread support"
  #else
  threads_flag="--with-threads"
  #  echo "Python and extension modules will be built with thread support"
  #fi
  module load IBM
  
  pic_flag="-fpic"
}

echo "pyclaw_build_ppc64_python              - install python 2.7.2"
pyclaw_build_ppc64_python() {
  echo "pyclaw_prep"
  pyclaw_prep
  cd ${sandbox}
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/Python-2.7.2.tgz ]; then 
      wget -P ${srcdir} http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz
  fi
  if [ ! -f $srcdir/Python-2.7.2_ppc64.patch ]; then 
      wget -P ${srcdir} http://dl.dropbox.com/u/65439/Python-2.7.2_ppc64.patch
  fi

  tar -zxvf ${srcdir}/Python-2.7.2.tgz
  cd Python-2.7.2

  echo "source patches"
  patch -p1 < ${srcdir}/Python-2.7.2_ppc64.patch

  ./configure --prefix=${builddir}/python/2.7.2/ppc64 --enable-shared \
      --disable-ipv6 --enable-unicode=ucs2 $threads_flag \
      2>&1 | tee ${logdir}/Python-2.7.2_ppc64_configure.log

  make 2>&1 | tee ${logdir}/Python-2.7.2_ppc64_make.log  
  make install 2>&1 | tee ${logdir}/Python-2.7.2_ppc64_make_install.log
}

echo "pyclaw_build_numpy_ppc64              - install numpy 1.6.2"
pyclaw_build_numpy_ppc64() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/numpy-1.6.2.tar.gz ]; then 
      wget -P ${srcdir} http://sourceforge.net/projects/numpy/files/NumPy/1.6.2/numpy-1.6.2.tar.gz
  fi
  if [ ! -f $srcdir/numpy-1.6.2_bgp.patch ]; then 
      wget -P ${srcdir} http://dl.dropbox.com/u/65439/numpy-1.6.2_bgp.patch
  fi

  tar -zxvf ${srcdir}/numpy-1.6.2.tar.gz
  cd numpy-1.6.2
  echo "source patches"
  patch -p1 < ${srcdir}/numpy-1.6.2_bgp.patch

  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python
  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v build --compiler=unix --fcompiler=gfortran        \
      2>&1 | tee ${logdir}/numpy-1.6.2_build.log  

  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v install --home=${builddir}/numpy/1.6.2/ppc64       \
      2>&1 | tee ${logdir}/numpy-1.6.2_install.log  
}

echo "\nTarget environment (BG/P) scripts"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "pyclaw_build_zlib              - install zlib 1.2.6"
pyclaw_build_zlib() {
  echo "pyclaw_prep"
  pyclaw_prep
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/zlib-1.2.6.tgz ]; then 
      wget -P $srcdir http://prdownloads.sourceforge.net/libpng/zlib-1.2.6.tar.gz
  fi

  cd $sandbox

  tar -zxvf $srcdir/zlib-1.2.6.tar.gz
  cd zlib-1.2.6
  CC=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-gcc \
      CFLAGS=" $pic_flag " \
      ./configure --prefix=${builddir}/zlib/1.2.6/bgp \
      2>&1 | tee ${logdir}/zlib-1.2.6_bgp_configure.log
  make 2>&1 | tee ${logdir}/zlib-1.2.6_bgp_make.log  
  make install 2>&1 | tee ${logdir}/zlib-1.2.6_bgp_make_install.log
}

echo "pyclaw_build_bzip2              - install bzip2 1.0.6"
pyclaw_build_bzip2() {
  echo "pyclaw_prep"
  pyclaw_prep
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/bzip2-1.0.6.tgz ]; then 
      wget -P $srcdir http://bzip.org/1.0.6/bzip2-1.0.6.tar.gz
  fi

  cd $sandbox

  tar -zxvf $srcdir/bzip2-1.0.6.tar.gz
  cd bzip2-1.0.6

  make install PREFIX=${builddir}/bzip2/1.0.6/bgp \
      CC=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-gcc \
      CFLAGS="-Wall -Winline -O2 -g $pic_flag -D_FILE_OFFSET_BITS=64" \
      2>&1 | tee ${logdir}/bzip2-1.0.6_bgp_make_install.log
}

echo "pyclaw_build_bgp_python              - install python 2.7.2"
pyclaw_build_bgp_python() {
  echo "pyclaw_prep"
  pyclaw_prep
  cd ${sandbox}
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/Python-2.7.2.tgz ]; then 
      wget -P ${srcdir} http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz
  fi
  if [ ! -f $srcdir/Python-2.7.2_bgp.patch ]; then 
      wget -P ${srcdir} http://dl.dropbox.com/u/65439/Python-2.7.2_bgp.patch
  fi

  tar -zxvf ${srcdir}/Python-2.7.2.tgz
  cd Python-2.7.2
  echo "build host Python"
  ./configure 2>&1 | tee ${logdir}/Python-2.7.2_host_configure.log
  make python Parser/pgen 2>&1 | tee ${logdir}/Python-2.7.2_host_make.log
  mv python hostpython
  mv Parser/pgen Parser/hostpgen
  make distclean

  echo "source patches"
  patch -p1 < ${srcdir}/Python-2.7.2_bgp.patch

  CFLAGS="-dynamic" \
      CXXFLAGS="-dynamic" \
      CPPFLAGS="-I${builddir}/zlib/1.2.6/bgp/include \
      -I${builddir}/bzip2/1.0.6/bgp/include" \
      LDFLAGS="-L${builddir}/zlib/1.2.6/bgp/lib -L${builddir}/bzip2/1.0.6/bgp/lib " \
      CC=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-gcc  \
      CXX=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-g++ \
      AR=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-ar \
      RANLIB=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-ranlib \
      ./configure --host=ppc-linux --build=ppc-linux-gnu --prefix=${builddir}/python/2.7.2/bgp \
      --enable-shared --disable-ipv6 --enable-unicode=ucs2 $threads_flag \
      2>&1 | tee ${logdir}/Python-2.7.2_bgp_configure.log

  make HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen \
      BLDSHARED="/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-gcc -shared" \
      CROSS_COMPILE=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux- \
      CROSS_COMPILE_TARGET=yes HOSTARCH=ppc-linux BUILDARCH=ppc-linux-gnu \
      2>&1 | tee ${logdir}/Python-2.7.2_bgp_make.log

  make install HOSTPYTHON=./hostpython \
      BLDSHARED="/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux-gcc -shared" \
      CROSS_COMPILE=/bgsys/drivers/V1R4M2_200_2010-100508P/ppc/gnu-linux/bin/powerpc-bgp-linux- \
      CROSS_COMPILE_TARGET=yes prefix=${builddir}/python/2.7.2/bgp \
      2>&1 | tee ${logdir}/Python-2.7.2_bgp_make_install.log
}

echo "pyclaw_build_numpy              - install numpy 1.6.2"
pyclaw_build_numpy() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}

  if [ -d $sandbox/numpy-1.6.2 ]; then
      rm -rf numpy-1.6.2
  fi

  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/numpy-1.6.2.tar.gz ]; then 
      wget -P ${srcdir} http://sourceforge.net/projects/numpy/files/NumPy/1.6.2/numpy-1.6.2.tar.gz
  fi
  if [ ! -f $srcdir/numpy-1.6.2_bgp.patch ]; then 
      wget -P ${srcdir} http://dl.dropbox.com/u/65439/numpy-1.6.2_bgp.patch
  fi

  tar -zxvf ${srcdir}/numpy-1.6.2.tar.gz
  cd numpy-1.6.2
  echo "source patches"
  patch -p1 < ${srcdir}/numpy-1.6.2_bgp.patch

  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python
  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v build --compiler=mpixlc --fcompiler=bgp           \
      2>&1 | tee ${logdir}/numpy-1.6.2_build.log  

  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v install --home=${builddir}/numpy/1.6.2/bgp        \
      2>&1 | tee ${logdir}/numpy-1.6.2_install.log  
  
}


pyclaw_build_scipy() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}

  if [ -d $sandbox/numpy-1.6.2 ]; then
      rm -rf numpy-1.6.2
  fi

  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/numpy-1.6.2.tar.gz ]; then
      wget -P ${srcdir} http://sourceforge.net/projects/numpy/files/NumPy/1.6.2/numpy-1.6.2.tar.gz
  fi
  if [ ! -f $srcdir/numpy-1.6.2_bgp.patch ]; then
      wget -P ${srcdir} http://dl.dropbox.com/u/65439/numpy-1.6.2_bgp.patch
  fi

  tar -zxvf ${srcdir}/numpy-1.6.2.tar.gz
  cd numpy-1.6.2
  echo "source patches"
  patch -p1 < ${srcdir}/numpy-1.6.2_bgp.patch

  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python
  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v build --compiler=mpixlc --fcompiler=bgp           \
      2>&1 | tee ${logdir}/numpy-1.6.2_build.log

  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v install --home=${builddir}/numpy/1.6.2/bgp        \
      2>&1 | tee ${logdir}/numpy-1.6.2_install.log

}





echo "pyclaw_build_nose              - install nose 1.1.2"
pyclaw_build_nose() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/nose-1.1.2.tar.gz ]; then 
      wget -P ${srcdir} http://pypi.python.org/packages/source/n/nose/nose-1.1.2.tar.gz
  fi

  tar -zxvf ${srcdir}/nose-1.1.2.tar.gz
  cd nose-1.1.2

  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python
  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v build 2>&1 | tee ${logdir}/nose-1.1.2_build.log  

  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py \
      -v install --home=${builddir}/nose/1.1.2/bgp        \
      2>&1 | tee ${logdir}/nose-1.1.2_install.log  
}

echo "pyclaw_test_numpy                  - test numpy build"
pyclaw_test_numpy() {    
  echo "k01 prep"
  pyclaw_prep

  cat <<'EOF' > test_numpy.py
import numpy
numpy.test()
EOF
    
  cat <<'EOF' > test_python_submit.ll
#!/usr/bin/env bash
#
# @ job_name            = test_my_python
# @ job_type            = bluegene
# @ output              = ./$(job_name)_$(jobid).out
# @ error               = ./$(job_name)_$(jobid).err
# @ environment         = COPY_ALL; 
# @ wall_clock_limit    = 0:15:00,0:15:00
# @ notification        = always
# @ bg_size             = 64
# @ account_no          = k47

# @ queue
    
projdir=/home/amal/tools/test_build64
builddir=${projdir}/opt/share
pythondir=${builddir}/python/2.7.2/bgp
logdir=${builddir}/logs
sandbox=${projdir}/sandbox
ldpath=${pythondir}/lib
bgp_python_path=${builddir}/numpy/1.6.2/bgp/lib/python:${builddir}/nose/1.1.2/bgp/lib/python

mpirun -env LD_LIBRARY_PATH=${ldpath} -env PYTHONPATH=${bgp_python_path} \
    -mode VN -exp_env HOME -n 1 ${pythondir}/bin/python test_numpy.py | tee ${logdir}/test_numpy.log
EOF
    
  llsubmit test_python_submit.ll
}


echo "pyclaw_build_petsc              - install petsc-3.2-p7"
pyclaw_build_petsc() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}
  if [ ! -f ${srcdir}/petsc-lite-3.2-p7.tar.gz ]; then
      wget -P ${srcdir} http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-3.2-p7.tar.gz
  fi
  
  tar -zxvf ${srcdir}/petsc-lite-3.2-p7.tar.gz
  
  cd petsc-3.2-p7

  echo "configuration"
  unset PETSC_DIR
  ./configure --with-cc=mpicc --with-cxx=mpicxx --with-fc=mpif77 \
      --with-mpi-dir=/bgsys/drivers/ppcfloor/comm --known-mpi-shared-libraries=1     \
      --download-f-blas-lapack=1 --with-x=0 --with-is-color-value-type=short         \
      -CFLAGS=-g -CXXFLAGS=-g                                                        \
      -FFLAGS=-g --with-debugging=1                                                  \
      --with-batch=1 --known-memcmp-ok --known-sizeof-char=1                         \
      --with-64-bit-indices=1                                                        \
      --known-sizeof-void-p=4 --known-sizeof-short=2 --known-sizeof-int=4            \
      --known-sizeof-long=4 --known-sizeof-size_t=4 --known-sizeof-long-long=8       \
      --known-sizeof-float=4 --known-sizeof-double=8 --known-bits-per-byte=8         \
      --known-sizeof-MPI_Comm=4 --known-sizeof-MPI_Fint=4 --known-mpi-long-double=1  \
      --known-level1-dcache-assoc=0 --known-level1-dcache-linesize=32                \
      --known-level1-dcache-size=32768 --known-complex-dot-arg=0                     \
      --with-shared-libraries=1 --prefix=${builddir}/petsc/3.2-p7/bgp                \
      2>&1 | tee ${logdir}/petsc-3.2-p7_configure.log

  make PETSC_DIR=$sandbox/petsc-3.2-p7 PETSC_ARCH=arch-linux2-c-debug all \
      2>&1 | tee ${logdir}/petsc-3.2-p7_make.log

  make PETSC_DIR=$sandbox/petsc-3.2-p7 PETSC_ARCH=arch-linux2-c-debug install \
      2>&1 | tee ${logdir}/petsc-3.2-p7_make_install.log
}


echo "pyclaw_build_petsc4py              - install petsc4py 1.2"
pyclaw_build_petsc4py() {
  echo "k01 prep"
  pyclaw_prep
  cd ${sandbox}
  echo "downloading and unpacking sources"
  if [ ! -f $srcdir/petsc4py-1.2.tar.gz ]; then
      wget -P ${srcdir} http://petsc4py.googlecode.com/files/petsc4py-1.2.tar.gz
  fi

  tar -zxvf ${srcdir}/petsc4py-1.2.tar.gz
  cd petsc4py-1.2
  
  export PETSC_DIR=${builddir}/petsc/3.2-p7/bgp

  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python
  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH $PYTHON setup.py -v build_ext \
      --compiler=mpixlc \
      --include-dirs=${builddir}/numpy/1.6.2/bgp/lib/python/numpy/core/include \
      install --home=${builddir}/petsc4py/1.2/bgp
}




echo "pyclaw_build_clawpack              - install clawpack 1.2"
pyclaw_build_clawpack() {
  echo "k01 prep"
  pyclaw_prep

  cd ${sandbox}
  git clone git://github.com/clawpack/clawpack.git
  cd clawpack/
  git submodule init
  git submodule update
  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python

  SAVEPATH=$PYTHONPATH
  export PYTHONPATH=${builddir}/numpy/1.6.2/ppc64/lib/python

  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH \
    $PYTHON \
    setup.py -v build_ext \
    --compiler=mpixlc --fcompiler=bgp \
    install --home=${builddir}/clawpack/dev/bgp
  export PYTHONPATH=$SAVEPATH
}

pyclaw_rebuild_clawpack() {
  echo "k01 prep"
  pyclaw_prep

  cd ${sandbox}
  cd clawpack/
  git checkout ${branch_name}
  git submodule init
  git submodule update
  PYTHON=${builddir}/python/2.7.2/ppc64/bin/python

  SAVEPATH=$PYTHONPATH
  export PYTHONPATH=${builddir}/numpy/1.6.2/ppc64/lib/python

  PYTHON_LD_LIBRARY_PATH=${builddir}/python/2.7.2/ppc64/lib
  LD_LIBRARY_PATH=$PYTHON_LD_LIBRARY_PATH \
    $PYTHON \
    setup.py -v build_ext \
    --compiler=mpixlc --fcompiler=bgp \
    install --home=${builddir}/clawpack/dev/bgp
  export PYTHONPATH=$SAVEPATH
}




echo "pyclaw_test_build                  - test pyclaw build"
pyclaw_test_build() {    
  echo "k01 prep"
  pyclaw_prep


  cat <<'EOF' > test_pyclaw_submit.ll
#!/usr/bin/env bash
#
# @ job_name            = test_pyclaw
# @ job_type            = bluegene
# @ output              = ./$(job_name)_$(jobid).out
# @ error               = ./$(job_name)_$(jobid).err
# @ environment         = COPY_ALL; 
# @ wall_clock_limit    = 0:15:00,0:15:00
# @ notification        = always
# @ bg_size             = 64
# @ account_no          = k47

# @ queue


projdir=/home/amal/tools/test_build64
builddir=${projdir}/opt/share
pythondir=${builddir}/python/2.7.2/bgp
ldpath=${pythondir}/lib
numpy_path=${builddir}/numpy/1.6.2/bgp/lib/python
nose_path=${builddir}/nose/1.1.2/bgp/lib/python
clawpack_path=${builddir}/clawpack/dev/bgp/lib/python
petsc4py_path=${builddir}/petsc4py/1.2/bgp/lib/python
bgp_python_path=${numpy_path}:${nose_path}:${clawpack_path}:${petsc4py_path}
sandbox=${projdir}/sandbox
ldpath=${pythondir}/lib
logdir=${builddir}/logs

mpirun -env LD_LIBRARY_PATH=${ldpath} -env PYTHONPATH=${bgp_python_path} \
    -mode VN -exp_env HOME -n 4 ${pythondir}/bin/python \
    ${sandbox}/clawpack/pyclaw/apps/advection_1d/advection.py \
    kernel_language=Fortran use_petsc=True \
    | tee ${logdir}/test_clawpack_advection.log
EOF

llsubmit test_pyclaw_submit.ll
}


echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
echo "pyclaw_build_all - run all install scripts"
pyclaw_build_all() {
  pyclaw_build_ppc64_python
  pyclaw_build_numpy_ppc64
  pyclaw_build_zlib
  pyclaw_build_bzip2
  pyclaw_build_bgp_python
  pyclaw_build_numpy
  pyclaw_build_nose
  pyclaw_build_petsc
  pyclaw_build_petsc4py
  pyclaw_build_clawpack
###
}

pyclaw_run_tests() {
  pyclaw_test_numpy
  pyclaw_test_build
}

