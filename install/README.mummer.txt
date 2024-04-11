# problem:
# nucmer exe was not working
# nucmer: error while loading shared libraries: libumdmummer.so.0: cannot open shared object file: No such file or directory


# solution: create a statically compiled version (implemented suggestion from github below)
# https://github.com/mummer4/mummer/issues/10


# download mummer4.0.0rc1
wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz;

# unzip contents
tar -xvzf mummer-4.0.0rc1.tar.gz;

# go to mummer directory
cd mummer-4.0.0rc1/

# make a statically compiled version of executable
./configure LDFLAGS=-static

# compile
# nucmer executable can now be used in UniAmp without any library errors
make 
