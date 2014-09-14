#!/bin/bash

indexer -c /etc/sphinxsearch/gosphinx.conf --all
./searchd.sh
