from setuptools import Extension, setup
from Cython.Build import cythonize


COMPILE_ARGS = ["-std=c++17"]


bleu = Extension(
    "bleu",
    sources=["src/bleu.pyx"],
    language="c++",
    extra_compile_args=COMPILE_ARGS,
)


edit_distance = Extension(
    "edit_distance",
    sources=["src/edit_distance.pyx"],
    language="c++",
    extra_compile_args=COMPILE_ARGS,
)


with open("README.md", "r") as f:
    long_description = f.read()


__version__ = "0.2.1"


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
            'cyzil-bleu-corpus = cyzil.cli.bleu_cli:bleu_corpus',
            'cyzil-bleu-points = cyzil.cli.bleu_cli:bleu_points',
            'cyzil-edit-distance-corpus = cyzil.cli.edit_distance_cli:edit_distance_corpus',
            'cyzil-edit-distance-points = cyzil.cli.edit_distance_cli:edit_distance_points',
        ]
    },
    license="Apache 2.0",
    packages=["cyzil", "cyzil.cli"],
    classifiers=[
        "Programming Language :: Python :: 3 :: Only",
        "Programming Language :: Python :: 3.7",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
    ],
    ext_modules=cythonize([bleu, edit_distance]),
    zip_safe=False,
)
