#!/bin/bash

#PATH_setup=$1

#cd $PATH_setup
#PATH_setup=`pwd`
#PATH_packages=$PATH_setup/../packages
#echo $PATH_packages
#for i in `ls -l $PATH_setup | grep ^d | awk {'print $9'}`; do 
#    dpkg --build $i $PATH_packages;
#done

function _build_structure {
    mkdir -p $1/DEBIAN
    mkdir -p $1/opt/sites
}

function _clean_admin_files {
    rm -f *.zip
    for clean in .gitignore readme.md; 
    do
        for file in `find . -name $clean`;
        do
            rm -f $file
        done
    done
}

function _build_control_file {
    site=$1
    label=$2
    parts=(`echo $site | sed -e 's/-/ /g'`)
    version=${parts[1]}${parts[2]}

    cd DEBIAN
    echo "Package: dg-site-$label
Version: 130314-$version
Section: base
Priority: optional
Architecture: all
Depends: bash
Maintainer: ts@daxiangroup.com
" > control
    cd ..
}

for remote in `cat build-remotes.ini | grep -v ^\#`;
do
    parts=(`echo $remote | sed -e 's/,/ /g'`)
    site=${parts[0]}
    url=${parts[1]}
    label=${parts[2]}

    _build_structure $site $label
    cd $site
    wget $url --no-check-certificate
    unzip *.zip -d opt/sites/
    mv opt/sites/$site opt/sites/$label
    _clean_admin_files
    _build_control_file $site $label

    dpkg --build ./ ./
done

