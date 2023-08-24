# -*- coding: utf-8 -*-
from setuptools import setup

package_dir = \
{'': 'src'}

packages = \
['fontconfig']

package_data = \
{'': ['*']}

install_requires = \
['pysen[lint]>=0.10.5,<0.11.0']

setup_kwargs = {
    'name': 'fontconfig-py',
    'version': '0.1.0',
    'description': 'Python bindings to fontconfig',
    'long_description': '# fontconfig-py\n\nPython bindings to [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/).\n',
    'author': 'Kota Yamaguchi',
    'author_email': 'yamaguchi_kota@cyberagent.co.jp',
    'maintainer': 'None',
    'maintainer_email': 'None',
    'url': 'None',
    'package_dir': package_dir,
    'packages': packages,
    'package_data': package_data,
    'install_requires': install_requires,
    'python_requires': '>=3.8,<4.0',
}
from build import *
build(setup_kwargs)

setup(**setup_kwargs)
