# setup.py
import sys
sys.path.append('C:\\Python27\\Lib\site-packages')
from distutils.core import setup
import py2exe

setup(console=["app.py", "ci.py", "get.py", "put.py", "release.py"])