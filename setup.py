from distutils.core import setup
from Cython.Build import cythonize
from setuptools import Extension
import numpy as np

app = Extension(
        '_cyzil',
        sources = [
            'src/bleu/bleu.pyx',
            'src/edit_distance/edit_distance.pyx'
        ],
        libraries=['bleu', 'edit_distance'],
        language='c++',
        extra_compile_args=['...'],
)

with open("README.md", "r") as f:
    long_description = f.read()

__version__ = '0.1.1'

setup(
    name = 'cyzil',
    version = __version__,
    author = 'Kei Nemoto and Kyle Gorman',
    author_email = 'kei.nemoto28@gmail.com',
    description = 'Computation of NLP metrics',
    long_description = long_description,
    long_description_content_type = 'text/markdown',
    url='https://github.com/box-key/Cyzil',
    keywords=[
        'machine translation',
        'natural language processing',
    ],
    install_requires=[
        'Cython>=0.29',
        'numpy>=1.18',
    ],
    packages=['cyzil'],
    ext_modules = cythonize(app),
    zip_safe=False,
    include_dirs = [np.get_include()]
)
