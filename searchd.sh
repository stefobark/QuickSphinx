#!/bin/bash

searchd -c /etc/sphinxsearch/gosphinx.conf --nodetach "$@"
