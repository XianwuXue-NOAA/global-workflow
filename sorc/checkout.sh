#!/bin/sh
set -xu

# Checkout fv3gfs.fd gsi.fd ufs_utils.fd gfs_post.fd
# Arg "-F" indicate force of remove fv3gfs.fd gsi.fd ufs_utils.fd gfs_post.fd and checkout log directory 

if [ $# -lt 1 ]; then
  FORCE_REPLACE="N"
else
  FORCE_REPLACE=${1}
fi

[[ $FORCE_REPLACE == "-F" ]] && FORCE_REPLACE="Y"

topdir=$(pwd)
echo $topdir
LOG_DIR=$topdir/logs
if [ -d $LOG_DIR -a $FORCE_REPLACE == "Y" ]; then
  rm -rf $topdir/fv3gfs.fd $topdir/gsi.fd $topdir/ufs_utils.fd $topdir/gfs_post.fd $topdir/gsd_prep_chem.fd $LOG_DIR
fi
mkdir -p $LOG_DIR

ERRSCRIPT=${ERRSCRIPT:-'eval [[ $err = 0 ]]'}
err=0

echo fv3gfs checkout ...
if [[ ! -d fv3gfs.fd ]] ; then
    rm -f ${topdir}/checkout-fv3gfs.log
    git clone --recursive https://github.com/XianwuXue-NOAA/FV3-GSDCHEM-WW3.git fv3gfs.fd >> ${LOG_DIR}/checkout-fv3gfs.log 2>&1
    rc=$?
    ((err+=$rc))
    cd fv3gfs.fd
	git checkout gefs_v12.1.0
	git submodule update --init --recursive
    rc=$?
    ((err+=$rc))
    cd ${topdir}
else
    echo 'Skip.  Directory fv3gfs.fd already exists.'
fi

echo gsi checkout ...
if [[ ! -d gsi.fd ]] ; then
    rm -f ${LOG_DIR}/checkout-gsi.log
    git clone --recursive https://github.com/NOAA-EMC/GSI.git gsi.fd >> ${LOG_DIR}/checkout-gsi.fd.log 2>&1
    rc=$?
    ((err+=$rc))
    cd gsi.fd
    git checkout gfsda.v16.0.0
    git submodule update
    cd ${topdir}
else
    echo 'Skip.  Directory gsi.fd already exists.'
fi

echo ufs_utils checkout ...
if [[ ! -d ufs_utils.fd ]] ; then
    rm -f ${topdir}/checkout-ufs_utils.log
    git clone --recursive https://github.com/NOAA-EMC/UFS_UTILS.git ufs_utils.fd >> ${LOG_DIR}/checkout-ufs_utils.fd.log 2>&1
    rc=$?
    ((err+=$rc))
    cd ufs_utils.fd
    git checkout ops-gefsv12.1
    git submodule update --init --recursive
    cd ${topdir}
else
    echo 'Skip.  Directory ufs_utils.fd already exists.'
fi

echo EMC_post checkout ...
if [[ ! -d gfs_post.fd ]] ; then
    rm -f ${topdir}/checkout-gfs_post.log
    git clone --recursive https://github.com/NOAA-EMC/EMC_post.git gfs_post.fd >> ${LOG_DIR}/checkout-gfs_post.log 2>&1
    rc=$?
    ((err+=$rc))
    cd gfs_post.fd
    git checkout gefs_v12.0.1
    cd ${topdir}
else
    echo 'Skip.  Directory gfs_post.fd already exists.'
fi

echo GSD-prep-chem checkout ...
if [[ ! -d gsd_prep_chem.fd ]] ; then
    rm -f ${LOG_DIR}/checkout-gsd-prep-chem.log
    git clone gerrit:GSD-prep-chem gsd_prep_chem.fd >> ${LOG_DIR}/checkout-gsd-prep-chem.log 2>&1
    rc=$?
    ((err+=$rc))
    cd gsd_prep_chem.fd
    git checkout gefs_v12.0.1-3
    cd ${topdir}
else
    echo 'Skip.  Directory gsd_prep_chem.fd already exists.'
fi

#### Exception handling
[[ $err -ne 0 ]] && echo "FATAL CHECKOUT ERROR: Please check checkout-*.log file under checkout directory for detail, ABORT!"
$ERRSCRIPT || exit $err

exit 0
