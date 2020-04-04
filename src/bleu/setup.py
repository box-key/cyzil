from distutils.core import setup
from Cython.Build import cythonize
from setuptools import Extension
import numpy as np

app = Extension(
        name='bleu',
        language='c++',
        sources=['bleu.pyx'],
)

setup(
    ext_modules = cythonize(app),
    include_dirs = [np.get_include()]
)
