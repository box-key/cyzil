from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize


COMPILE_ARGS = ["-std=c++17"]


bleu = Extension(
    "bleu",
    language="c++",
    extra_compile_args=COMPILE_ARGS,
    sources=["src/bleu.pyx"],
    include_dirs=['src']
)


edit_distance = Extension(
    "edit_distance",
    language="c++",
    extra_compile_args=COMPILE_ARGS,
    sources=["src/edit_distance.pyx"],
    include_dirs=['src']
)


with open("README.md", "r") as f:
    long_description = f.read()


__version__ = "0.3.0"


setup(
    name="cyzil",
    version=__version__,
    author="Kei Nemoto, Kyle Gorman",
    author_email="kei.nemoto28@gmail.com",
    description="Computate metrics for machine translation",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/box-key/cyzil",
    keywords=[
        "machine translation",
        "natural language processing",
        "seq2seq models",
        "encoder-decoder models"
    ],
    install_requires=["Cython>=0.29"],
    entry_points={
        'console_scripts': [
            'cyzil-bleu-corpus = cyzil.bleu_cli:bleu_corpus',
            'cyzil-bleu-points = cyzil.bleu_cli:bleu_points',
            'cyzil-edit-distance-corpus = cyzil.edit_distance_cli:edit_distance_corpus',
            'cyzil-edit-distance-points = cyzil.edit_distance_cli:edit_distance_points',
        ]
    },
    license="Apache 2.0",
    classifiers=[
        "Programming Language :: Python :: 3 :: Only",
        "Programming Language :: Python :: 3.7",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: Artificial Intelligence"
    ],
    ext_modules=cythonize([bleu, edit_distance]),
    packages=find_packages(),
    package_data={"cyzil.src":[
        "edit_distance.cpp",
        "edit_distance.pyx",
        "bleu.cpp",
        "bleu.pyx"
    ]},
    zip_safe=False,
)
