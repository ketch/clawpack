import os
from os.path import join as pjoin, dirname
import sys

if sys.version_info[0] < 3:
    import __builtin__ as builtins
else:
    import builtins

def configuration(parent_package='',top_path=None):
    from numpy.distutils.misc_util import Configuration
    config = Configuration('clawpack',parent_package,top_path)
    config.add_subpackage('clawutil')
    config.add_subpackage('riemann')
    config.add_subpackage('visclaw')
    config.add_subpackage('pyclaw')
    config.add_subpackage('petclaw')

    if builtins.__USE_CUDACLAW__ and builtins.__CYTHON_BUILD__:
        config.add_subpackage('cudaclaw')
    return config

if __name__ == '__main__':
    from numpy.distutils.core import setup
    setup(**configuration(top_path='').todict())
