#!/usr/bin/env python
# -*- coding: utf-8 -*-

import setuptools 

with open('README.md') as readme_file:
    readme = readme_file.read()

setuptools.setup(
    name='PRISMA_automation',
    version='0.1.0',
    description="",
    long_description=readme + '\n\n',
    author="Matteo Di Carlo",
    author_email='matteo.dicarlo@inaf.it',
    url='https://github.com/Matteo04052017/PRISMA_automation',
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    include_package_data=True,
    license="BSD license",
    zip_safe=False,
    keywords='PRISMA automation',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],
    test_suite='tests',
    install_requires=[
        "paramiko",
    ],
    platforms=["OS Independent"],
    extras_require={
        'dev':  ['prospector[with_pyroma]', 'yapf', 'isort']
    }
)