virtualenv --python=/usr/bin/python3.11 python
source python/bin/activate
pip install -r requirements.txt -t python/lib/python3.11/site-packages
python -m spacy download en_core_web_sm -t python/lib/python3.11/site-packages
zip -r9 python.zip python

