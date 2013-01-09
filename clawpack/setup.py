import os
from os.path import join as pjoin, dirname

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

def configuration(parent_package='',top_path=None):
    from numpy.distutils.misc_util import Configuration
    config = Configuration('clawpack',parent_package,top_path)
    config.add_subpackage('clawutil')
    config.add_subpackage('riemann')
    config.add_subpackage('visclaw')
    config.add_subpackage('pyclaw')
    config.add_subpackage('petclaw')

    if check_for_cuda():
        config.add_subpackage('cudaclaw')
    return config

if __name__ == '__main__':
    from numpy.distutils.core import setup
    setup(**configuration(top_path='').todict())
