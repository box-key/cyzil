from distutils.core import setup
from Cython.Build import cythonize
from setuptools import Extension
import numpy as np

app = Extension(
        name='edit_distance',
        language='c++',
        sources=['edit_distance.pyx']
)

setup(
    ext_modules = cythonize(app),
    include_dirs = [np.get_include()]
)
