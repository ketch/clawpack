"""Clawpack: Python-based Clawpack installer
"""

# much of the functionality of this file was taken from the scipy setup.py script.

DOCLINES = __doc__.split("\n")

import os
import sys
import warnings
import subprocess
import shutil
import re
from Cython.Distutils import build_ext
from os.path import join as pjoin, dirname

if sys.version_info[0] < 3:
    import __builtin__ as builtins
else:
    import builtins

CLASSIFIERS = """\
Development Status :: 4 - Beta
Intended Audience :: Science/Research
Intended Audience :: Developers
License :: OSI Approved
Programming Language :: C
Programming Language :: Python
Topic :: Software Development
Topic :: Scientific/Engineering
Operating System :: POSIX
Operating System :: Unix
Operating System :: MacOS

"""

MAJOR               = 0
MINOR               = 1
MICRO               = 0
ISRELEASED          = False
VERSION             = '%d.%d.%d' % (MAJOR, MINOR, MICRO)

package_path       = os.path.join(os.path.dirname(__file__),'clawpack')

version_file_path  = os.path.join(package_path,'version.py')

# Return the git revision as a string
def git_version():
    def _minimal_ext_cmd(cmd):
        # construct minimal environment
        env = {}
        for k in ['SYSTEMROOT', 'PATH']:
            v = os.environ.get(k)
            if v is not None:
                env[k] = v
        # LANGUAGE is used on win32
        env['LANGUAGE'] = 'C'
        env['LANG'] = 'C'
        env['LC_ALL'] = 'C'
        out = subprocess.Popen(cmd, stdout = subprocess.PIPE, env=env).communicate()[0]
        return out

    try:
        out = _minimal_ext_cmd(['git', 'rev-parse', 'HEAD'])
        GIT_REVISION = out.strip().decode('ascii')
    except OSError:
        GIT_REVISION = "Unknown"

    return GIT_REVISION


# BEFORE importing distutils, remove MANIFEST. distutils doesn't properly
# update it when the contents of directories change.
if os.path.exists('MANIFEST'):
    os.remove('MANIFEST')

def write_version_py(filename=version_file_path):
    cnt = """
# THIS FILE IS GENERATED FROM CLAWPACK SETUP.PY
short_version = '%(version)s'
version = '%(version)s'
full_version = '%(full_version)s'
git_revision = '%(git_revision)s'
release = %(isrelease)s

if not release:
    version = full_version
"""
    # Adding the git rev number needs to be done inside
    # write_version_py(), otherwise the import of scipy.version messes
    # up the build under Python 3.
    FULLVERSION = VERSION
    if os.path.exists('.git'):
        GIT_REVISION = git_version()
    elif os.path.exists(version_file_path):
        # must be a source distribution, use existing version file
        from clawpack.version import git_revision as GIT_REVISION
    else:
        GIT_REVISION = "Unknown"

    if not ISRELEASED:
        FULLVERSION += '.dev-' + GIT_REVISION[:7]

    a = open(filename, 'w')
    try:
        a.write(cnt % {'version': VERSION,
                       'full_version' : FULLVERSION,
                       'git_revision' : GIT_REVISION,
                       'isrelease': str(ISRELEASED)})
    finally:
        a.close()    

def configuration(parent_package='',top_path=None):
    from numpy.distutils.misc_util import Configuration

    config = Configuration(None, parent_package, top_path)

    config.set_options(ignore_setup_xxx_py=True,
                       assume_default_configuration=True,
                       delegate_options_to_subpackages=True)

    config.add_subpackage('clawpack')
    config.get_version(os.path.join('clawpack','version.py'))
    return config


def setup_package():
    import sys
    # Rewrite the version file everytime

    old_path = os.getcwd()
    local_path = os.path.dirname(os.path.abspath(sys.argv[0]))
    src_path = local_path

    os.chdir(local_path)
    sys.path.insert(0, local_path)
    sys.path.insert(0, os.path.join(local_path, 'clawpack'))  # to retrieve version

    old_path = os.getcwd()
    os.chdir(src_path)
    sys.path.insert(0, src_path)

    write_version_py()

    if found_cuda:  
        setup_build_ext = cuda_build_ext
    else:
        setup_build_ext = build_ext

    setup_dict = dict(
        name = 'clawpack',
        maintainer = "Clawpack Developers",
        maintainer_email = "claw-dev@googlegroups.com",
        description = DOCLINES[0],
        long_description = "\n".join(DOCLINES[2:]),
        url = "http://www.clawpack.org",
        download_url = "git+git://github.com/clawpack/clawpack.git#egg=clawpack-dev", 
        license = 'BSD',
        classifiers=[_f for _f in CLASSIFIERS.split('\n') if _f],
        platforms = ["Linux", "Solaris", "Mac OS-X", "Unix"],
        cmdclass = {'build_ext': setup_build_ext}
        )

    try:
        if 'egg_info' in sys.argv:
            # only egg information for downloading requirements
            from setuptools import setup
            setuptools_dict = dict(
                install_requires = ['numpy >= 1.6',
                                    'matplotlib >= 1.0.1',
                                    ],                            
                extras_require = {'petclaw': ['petsc4py >= 1.2'],
                                  'euler'  : ['scipy >= 0.10.0']},
                )
            setup_dict.update(setuptools_dict)
            setup(**setup_dict)
            return

        if os.path.exists('.git'):
            if not os.path.exists('pyclaw/.git') or not os.path.exists('riemann/.git') \
            or not os.path.exists('visclaw/.git') or not os.path.exists('clawutil/.git'):
               from numpy.distutils.exec_command import exec_command
               exec_command(['git', 'submodule', 'init'])
               fails = 0
               while fails < 20 and exec_command(['git', 'submodule', 'update'])[1]:
                   fails = fails+1
                   import time
                   print "having difficulties updating submodules, waiting 5s and trying again [fail %d/20]" % fails
                   time.sleep(5)
            # *always* need these
            # now build symbolic links to repositories
            if not os.path.exists('clawpack/clawutil'):
                os.symlink(os.path.abspath('clawutil/src/python/clawutil'),
                           'clawpack/clawutil')
            if not os.path.exists('clawpack/riemann'):
                os.symlink(os.path.abspath('riemann/src/python/riemann'),
                           'clawpack/riemann')
                # need this one to build Fortran sources naturally
            if not os.path.exists('clawpack/riemann/src'):
                os.symlink(os.path.abspath('riemann/src'),
                           'clawpack/riemann/src')
            if not os.path.exists('clawpack/visclaw'):
                os.symlink(os.path.abspath('visclaw/src/python/visclaw'),
                           'clawpack/visclaw')
            if not os.path.exists('clawpack/pyclaw'):
                os.symlink(os.path.abspath('pyclaw/src/pyclaw'),
                           'clawpack/pyclaw')
            if not os.path.exists('clawpack/petclaw'):
                os.symlink(os.path.abspath('pyclaw/src/petclaw'),
                           'clawpack/petclaw')
            if not os.path.exists('clawpack/peanoclaw'):
                os.symlink(os.path.abspath('pyclaw/src/peanoclaw'),
                           'clawpack/peanoclaw')
            if not os.path.exists('clawpack/cudaclaw') and found_cuda:
                os.symlink(os.path.abspath('pyclaw/src/cudaclaw'),
                           'clawpack/cudaclaw')

            from numpy.distutils.core import setup
            setup(configuration=configuration,
                  **setup_dict)

    except Exception as err:
        print err
        raise err
    finally:
        if os.path.exists('clawpack/riemann/src'):
                os.unlink('clawpack/riemann/src')
        del sys.path[0]
        os.chdir(old_path)
    return

def patch_numpy_to_use_cython():
    # from https://github.com/matthew-brett/du-cy-numpy/blob/master/matthew_monkey.py
    from distutils.dep_util import newer_group
    from distutils.errors import DistutilsError

    from numpy.distutils.misc_util import appendpath
    from numpy.distutils import log

    # Note we are hard-coding to .cpp here!

    def generate_a_pyrex_source(self, base, ext_name, source, extension):
        ''' Monkey patch for numpy build_src.build_src method
    
        Uses Cython instead of Pyrex.
    
        Assumes Cython is present
        '''
        if self.inplace:
            target_dir = dirname(base)
        else:
            target_dir = appendpath(self.build_src, dirname(base))
        target_file = pjoin(target_dir, ext_name + '.cpp')
        depends = [source] + extension.depends
        if self.force or newer_group(depends, target_file, 'newer'):
            import Cython.Compiler.Main
            log.info("cythonc:> %s" % (target_file))
            self.mkpath(target_dir)
            options = Cython.Compiler.Main.CompilationOptions(
                defaults=Cython.Compiler.Main.default_options,
                include_path=extension.include_dirs,
                output_file=target_file)
            cython_result = Cython.Compiler.Main.compile(source,
                                                       options=options)
            if cython_result.num_errors != 0:
                raise DistutilsError("%d errors while compiling %r with Cython" \
                      % (cython_result.num_errors, source))
        return target_file
    
    
    from numpy.distutils.command import build_src
    build_src.build_src.generate_a_pyrex_source = generate_a_pyrex_source

def customize_cython_for_nvcc(self):
    """decorates Cython build_ext class to handle .cu source files

    adapted from http://stackoverflow.com/a/13300714/122022
    by Robert McGibbon (used under StackOverflow CC-BY license)

    If you subclass UnixCCompiler, it's not trivial to get your subclass
    injected in, and still have the right customizations (i.e.
    distutils.sysconfig.customize_compiler) run on it. Instead, we take 
    advantage of Python's dynamism to over-ride the class function directly
    """

    def locate_cuda():
        """Locate the CUDA environment on the system

        This functionality should really be brought in from numpy or PyCUDA.

        Returns a dict with keys 'home', 'nvcc', 'include', and 'lib'
        and values giving the absolute path to each directory.

        Also returns 'cuflags', which allows for customizing compiler flags,
        these are currently hardcoded to 64-bit CUDA 5 flags

        Starts by looking for the CUDAHOME env variable. If not found, everything
        is based on finding 'nvcc' in the PATH.
        """

        # first check if the CUDAHOME env variable is in use
        if 'CUDAHOME' in os.environ:
            home = os.environ['CUDAHOME']
            nvcc = pjoin(home, 'bin', 'nvcc')
        else:
            # otherwise, search the PATH for NVCC
            nvcc = find_in_path('nvcc', os.environ['PATH'])
            if nvcc is None:
                raise EnvironmentError('The nvcc binary could not be '
                    'located in your $PATH. Either add it to your path, or set $CUDAHOME')
            home = os.path.dirname(os.path.dirname(nvcc))

        cudaconfig = {'home':home, 'nvcc':nvcc,
                      'include': pjoin(home, 'include'),
                      'lib': pjoin(home, 'lib')}
        for k, v in cudaconfig.iteritems():
            if not os.path.exists(v):
                raise EnvironmentError('The CUDA %s path could not be located in %s' % (k, v))

        cudaconfig['cuflags'] = '-m64 -gencode arch=compute_10,code=sm_10' + \
                                ' -gencode arch=compute_20,code=sm_20' + \
                                ' -gencode arch=compute_30,code=sm_30' + \
                                ' -gencode arch=compute_35,code=sm_35' 

        return cudaconfig

    CUDA = locate_cuda()

    # tell the compiler it can process .cu
    self.src_extensions.append('.cu')

    # save references to the default compiler_so and _compile methods
    default_compiler_so = self.compiler_so
    super_compile = self._compile

    # now redefine the _compile method. This gets executed for each
    # object but distutils doesn't have the ability to change compilers
    # based on source extension: we add it.
    def _compile(obj, src, ext, cc_args, extra_postargs, pp_opts):
        postargs = []
        if True: 
#        if os.path.splitext(src)[1] == '.cu':
            # use the cuda compiler for .cu files
            # currently hard-coded to OS X CUDA 5 options
            self.set_executable('compiler_so', 
                                CUDA['nvcc'] + ' -Xcompiler -fPIC ' + CUDA['cuflags'])
            # set postargs for either '.cu' or '.c'
            # from the extra_compile_args in the Extension class
            if '.cu' in extra_postargs:
                postargs = extra_postargs['.cu']
        else:
            if '.c' in extra_postargs:
                postargs = extra_postargs['.c']

        super_compile(obj, src, ext, cc_args, postargs, pp_opts)
        # reset the default compiler_so, which we might have changed for cuda
        self.compiler_so = default_compiler_so

    # inject our redefined _compile method into the class
    self._compile = _compile

# decorate build_ext
class cuda_build_ext(build_ext):
    def build_extensions(self):
        # this is a bit hacky
        customize_cython_for_nvcc(self.compiler)
        build_ext.build_extensions(self)

def find_in_path(name, path):
    "Find a file in a search path"
    #adapted by Robert from 
    # http://code.activestate.com/recipes/52224-find-a-file-given-a-search-path/
    for dir in path.split(os.pathsep):
        binpath = pjoin(dir, name)
        if os.path.exists(binpath):
            return os.path.abspath(binpath)
    return None

def check_for_cuda():
    """Check if CUDA compiler is on the system
    """
    # first check if the CUDAHOME env variable is in use
    if 'CUDAHOME' not in os.environ:
        nvcc = find_in_path('nvcc', os.environ['PATH'])
        if nvcc is None:
            return False
    print 'detected nvcc or CUDAHOME, installing cudaclaw'
    return True

found_cuda = check_for_cuda()

if __name__ == '__main__':
    if found_cuda:
        patch_numpy_to_use_cython()

    setup_package() 
