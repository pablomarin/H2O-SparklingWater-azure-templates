#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e

#Libraries needed on the worker roles in order to get pysparkling working
pip install -U requests
pip install -U tabulate
pip install -U future
pip install -U six

#Scikit Learn on the nodes
pip install -U scikit-learn
