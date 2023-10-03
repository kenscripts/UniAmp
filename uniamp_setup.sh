#! /usr/bin/env bash

UNIAMP_PATH=$1

# make files executable
chmod u+x $UNIAMP_PATH/scripts/*
chmod u+x $UNIAMP_PATH/bin/*

# add files to path
export PATH=$UNIAMP_PATH/scripts/:$PATH
export PATH=$UNIAMP_PATH/bin/:$PATH
