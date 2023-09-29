#!/bin/bash

# Exit on the first error
set -e

# Create a virtual environment
virtualenv --python=/usr/bin/python3.11 python
source python/bin/activate

# Install packages from requirements.txt
pip install -r requirements.txt -t python/lib/python3.11/site-packages

# Install spaCy
python -m spacy download en_core_web_sm -t python/lib/python3.11/site-packages

# Create a ZIP file
zip -r9 python.zip python
