#!/bin/bash

cp /etc/opensearch/opensearch.yml /etc/opensearch/opensearch.yml.tmp && \

    if [ -n  "`grep -r "network.host" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -ri 's/^#+(network.host)\s*\S+.*/\1: 0.0.0.0/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "network.host: 0.0.0.0" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi &&\

    if [- n "`grep -r "discovery.type" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -ri 's/^#+(discovery.type)\s*\S+.*/\1: single-node/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "discovery.type: single-node" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi  &&\

    if [- n "`grep -r "plugins.security.disabled" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -r 's/^#+(plugins.security.disabled)\s*\S+.*/\1: false/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "plugins.security.disabled: false" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi &&\

    cp -f /etc/opensearch/opensearch.yml.tmp /etc/opensearch/opensearch.yml && \

    systemctl enable opensearch && \
    systemctl restart opensearch
