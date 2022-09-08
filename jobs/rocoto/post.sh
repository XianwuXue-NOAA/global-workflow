#!/bin/bash -x

###############################################################
## NCEP post driver script
## FHRGRP : forecast hour group to post-process (e.g. 0, 1, 2 ...)
## FHRLST : forecast hourlist to be post-process (e.g. anl, f000, f000_f001_f002, ...)
###############################################################

# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

export COMPONENT=${COMPONENT:-atmos}

if [[ $CDUMP == "gefs" ]]; then
    FHRGRP=gefs
fi
if [ $FHRGRP = 'anl' ]; then
    fhrlst="anl"
    restart_file=$ROTDIR/${CDUMP}.${PDY}/${cyc}/$COMPONENT/${CDUMP}.t${cyc}z.atm
elif [ $FHRGRP = 'gefs' ]; then
    export EXPDIR=${EXPDIR:-$HOMEgfs/parm/config}
    config_path=${EXPDIR:-$NWROOT/gfs.${gfs_ver}/parm/config}
    . $config_path/config.base
    . $config_path/config.fcst
    export FHMAX=$FHMAX_GFS
    export FHOUT=6 #${FHOUT:-${FHOUT_GFS}}
    export FHOUT_GFS=6
    export FHMAX_HF=$FHMAX_HF_GFS
    export FHOUT_HF=6 #$FHOUT_HF_GFS

    fhrlst=""
    echo "FHMIN:${FHMIN};FHOUT_HF=${FHOUT_HF}; FHMAX_HF=${FHMAX_HF}; FHMAX=${FHMAX};  "
    #exit 0
    FHMIN_LF=$FHMIN
    if (( FHOUT_HF > 0 && FHMAX_HF > 0 )); then
        for (( fh = FHMIN; fh < FHMAX_HF; fh = fh + FHOUT_HF )); do
            fhrlst="$fhrlst $fh"
        done
        FHMIN_LF=$FHMAX_HF
    fi
    for (( fh = FHMIN_LF; fh <= FHMAX; fh = fh + FHOUT )); do
        fhrlst="$fhrlst $fh"
    done
    echo $fhrlst
    export fhrlst
    #exit 0
    restart_file=$ROTDIR/${CDUMP}.${PDY}/${cyc}/$RUNMEM/$COMPONENT/sfcsig/${CDUMP}.t${cyc}z.atm
    $HOMEgfs/jobs/JGEFS_ATMOS_PRDGEN #JGLOBAL_ATMOS_NCEPPOST
    status=$?
    [[ $status -ne 0 ]] && exit $status 
    exit 0
else
    fhrlst=$(echo $FHRLST | sed -e 's/_/ /g; s/f/ /g; s/,/ /g')
    restart_file=$ROTDIR/${CDUMP}.${PDY}/${cyc}/$COMPONENT/${CDUMP}.t${cyc}z.logf
fi


#---------------------------------------------------------------
for fhr in $fhrlst; do

    if [ ! -f $restart_file${fhr}.nemsio -a ! -f $restart_file${fhr}.nc  -a ! -f $restart_file${fhr}.txt ]; then
        echo "Nothing to process for FHR = $fhr, cycle, wait for 5 minutes"
        sleep 300
    fi
    if [ ! -f $restart_file${fhr}.nemsio -a ! -f $restart_file${fhr}.nc  -a ! -f $restart_file${fhr}.txt ]; then
        echo "Nothing to process for FHR = $fhr, cycle, skip"
        continue
    fi

    #master=$ROTDIR/${CDUMP}.${PDY}/${cyc}/$COMPONENT/${CDUMP}.t${cyc}z.master.grb2f${fhr}
    pgb0p25=$ROTDIR/${CDUMP}.${PDY}/${cyc}/$COMPONENT/${CDUMP}.t${cyc}z.pgrb2.0p25.f${fhr}
    if [ ! -s $pgb0p25 ]; then
        export post_times=$fhr
        $HOMEgfs/jobs/JGLOBAL_ATMOS_NCEPPOST
        status=$?
        [[ $status -ne 0 ]] && exit $status
    fi

done

###############################################################
# Exit out cleanly
exit 0
