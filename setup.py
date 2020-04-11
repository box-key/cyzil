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


__version__ = "0.1.1"


setup(
    name="cyzil",
    version=__version__,
    author="Kei Nemoto, Kyle Gorman",
    author_email="kei.nemoto28@gmail.com",
    description="Computate metrics for machine translation",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/box-key/Cyzil",
    keywords=[
        "machine translation",
        "natural language processing",
        "deep learning",
    ],
    install_requires=["Cython>=0.29"],
    python_requires=">=3.7",
    ext_modules=cythonize([bleu, edit_distance]),
    zip_safe=False,
)
