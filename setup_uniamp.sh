#! /bin/bash

# link (source)
#https://ss64.com/bash/source.html

# remove forward slash in argument 
#https://stackoverflow.com/questions/9018723/what-is-the-simplest-way-to-remove-a-trailing-slash-from-each-parameter
export UNIAMP_PATH=${1%/};

# make files executable
chmod u+x $UNIAMP_PATH/scripts/*;
chmod u+x $UNIAMP_PATH/bin/*;

# install e-direct
# e-direct no longer used
# entrez query directly applied to blastn search
#printf "\n>>> downloading edirect";
#sh $UNIAMP_PATH/install/install-edirect.sh;

# download and unpack ncbi taxonomy in UniAmp lib directory:
printf "\n>>> unpacking ncbi taxonomy\n";
cd $UNIAMP_PATH/lib/ncbi_taxdump;
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz;
tar -xvf taxdump.tar.gz;

# UniAmp requires the python package BeautifulSoup4 to parse the html output from Primer-BLAST
python3 -c "import beautifulsoup4" 2>/dev/null
if [ " $?" -eq 1 ]; then
    echo -e "\n>>> installing beautifulsoup4";
    #pip install beautifulsoup4;
else
    echo -e "\n>>> beautifulsoup4 already installed";
fi

# go back to initial directory
cd $OLDPWD;
