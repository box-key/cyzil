from distutils.core import setup
from setuptools import Extension
from Cython.Build import cythonize

import numpy as np

app = Extension(
        'cyzil',
        sources = [
            'src/bleu.pyx',
            'src/edit_distance.pyx'
        ],
        libraries=[
            'bleu',
            'edit_distance'
        ],
        language='c++',
        extra_compile_args=['-std=c++17'],
        include_dirs = [np.get_include()],
)

with open("README.md", "r") as f:
    long_description = f.read()

__version__ = '0.1.1'

setup(
    name = 'cyzil',
    version = __version__,
    author = 'Kei Nemoto and Kyle Gorman',
    author_email = 'kei.nemoto28@gmail.com',
    description = 'Computation of metrics for machine translation',
    long_description = long_description,
    long_description_content_type = 'text/markdown',
    url='https://github.com/box-key/Cyzil',
    keywords=[
        'machine translation',
        'natural language processing',
        'error analysis',
        'bleu',
        'edit distance'
    ],
    install_requires=[
        'Cython>=0.29',
        'numpy>=1.18',
    ],
    python_requires='>=3.7',
    packages=find_packages(where=['src']),
    ext_modules = cythonize(app),
    zip_safe=False,
)
