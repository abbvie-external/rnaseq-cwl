# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
import sys
import os
import pathlib
sys.path.insert(0, os.path.abspath('../..'))
sys.path.insert(0, pathlib.Path(__file__).parents[2].joinpath('test').resolve().as_posix())
project = 'BulkRnaSeq'
copyright = '2022, Abbvie Inc.'
author = 'Abbvie Bioinformatics Engineer'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration


extensions = ['myst_parser', # support md file
              'sphinx.ext.autodoc', # support docstring
              'sphinx.ext.todo', # support todo
              'sphinx.ext.napoleon', # support google style with phone 3 type
              'sphinxcontrib.autoyaml', # support yaml annotation
              'sphinx_rtd_size', # support the sphinx table width
              ]
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

templates_path = ['_templates']
exclude_patterns = []
sphinx_rtd_size_width = "70%"



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
