#! /usr/bin/env bash

echo "$(date -u) begin ${BASH_SOURCE[1]}"

set -xa
if [[ ${STRICT:-NO} == "YES" ]]; then
	# Turn on strict bash error checking
	set -eu
fi

export RERUN=${RERUN:-RESTART}

export HOMEgfs=${HOMEgfs:-$HOMEgefs}
export FIXgfs=${FIXgfs:-$HOMEgfs/fix/fix_am}
export PARMgfs=${PARMgfs:-$HOMEgfs/parm}


####################################
# Specify Timeout Behavior of Post
#
# SLEEP_TIME - Amount of time to wait for
#              a restart file before exiting
# SLEEP_INT  - Amount of time to wait between
#              checking for restart files
####################################
export SLEEP_TIME=1800
export SLEEP_INT=5

export PRDGEN_STREAMS="res_2p50 res_0p50 res_0p25_s1 res_0p25_s2"
echo "PRDGEN_STREAMS = $PRDGEN_STREAMS"

# 20150622 RLW change to "yes" to remake prdgen when post is remade
export overwrite=yes

case ${FORECAST_SEGMENT:-none} in
	hr)
		start_hour=0
		end_hour=${fhmax} #${fhmaxh}
		;;
	lr)
		start_hour=$((${fhmaxh}+1))
		end_hour=${fhmax}
		PRDGEN_STREAMS=$PRDGEN_STREAMS_LR
		;;
	*)
		start_hour=0
		end_hour=${fhmaxh}
		;;
esac # $FORECAST_SEGMENT in

#for stream in ${PRDGEN_STREAMS}; do
#	# Filter out hours based on forecast segment
#	typeset -a hours=($(echo ${PRDGEN_HOURS[$stream]}))
#	echo "hours = $hours"
#	for i in "${!hours[@]}"; do
#		hour=${hours[i]}
#		echo "i = $i  hour = $hour"
#		if [[ $hour -lt $start_hour || $hour -gt $end_hour ]]; then
#			unset 'hours[i]'
#		fi
#	done
#	PRDGEN_HOURS[$stream]="${hours[@]}"
#	unset hours
#
#	# Ensure required variables are defined
#	for var in PRDGEN_GRID PRDGEN_GRID_SPEC PRDGEN_HOURS PRDGEN_SUBMC PRDGEN_A_DIR PRDGEN_A_PREFIX PRDGEN_A_LIST_F00 PRDGEN_A_LIST_FHH; do
#		pointer="$var[$stream]"
#		if [[ -z ${!pointer} ]]; then
#			echo "FATAL ERROR in ${BASH_SOURCE[1]}: $var not defined for $stream"
#			exit -1
#		fi
#	done
#
#	# Print out settings for this stream
#	cat <<-EOF
#		Settings for prgden stream $stream:
#			Grid: ${PRDGEN_GRID[$stream]}
#			Grid Spec: ${PRDGEN_GRID_SPEC[$stream]}
#			Hours: (${PRDGEN_HOURS[$stream]})
#			submc: ${PRDGEN_SUBMC[$stream]}
#			A Dir: ${PRDGEN_A_DIR[$stream]}
#			A Prefix: ${PRDGEN_A_PREFIX[$stream]}
#			A Parmlist f00: ${PRDGEN_A_LIST_F00[$stream]}
#			A Parmlist fhh: ${PRDGEN_A_LIST_FHH[$stream]}
#			B Dir: ${PRDGEN_B_DIR[$stream]:-""}
#			B Prefix: ${PRDGEN_B_PREFIX[$stream]:-""}
#			B Parmlist f00: ${PRDGEN_B_LIST_F00[$stream]:-""}
#			B Parmlist fhh: ${PRDGEN_B_LIST_FHH[$stream]:-""}
#			Do Anaylsis: ${PRDGEN_DO_ANALYSIS[$stream]:-"NO (default)"}
#
#	EOF
#done

export NTHREADS=1

####################################
# Specify Process ID
####################################
export IGEN_ANL=107
export IGEN_FCST=107

export DO_HD_PGRB=NO
export HDMAX=00

#################################
# Run Post if Needed
#################################
rm -f prdgen.cmdfile
for stream in ${PRDGEN_STREAMS}; do

    case $stream in
        res_2p50)
            PRDGEN_GRID="2p5"
            PRDGEN_GRID_SPEC="latlon 0:144:2.5 90:73:-2.5"
#            PRDGEN_HOURS="{0..${FHMAXHF}..${FHOUTLF}} {$(( $FHMAXHF + ${FHOUTLF}))..${fhmax}..${FHOUTLF}}"}
            PRDGEN_SUBMC="prd2p5"
            PRDGEN_A_DIR="pgrb22p5"
            PRDGEN_A_PREFIX="pgrb2.2p50."
            PRDGEN_A_LIST_F00="gefs_pgrb2a_f00.parm_2p5"
            PRDGEN_A_LIST_FHH="gefs_pgrb2a_fhh.parm_2p5"
            PRDGEN_B_DIR=""
            PRDGEN_B_PREFIX=""
            PRDGEN_B_LIST_F00="gefs_pgrb2ab_f00.parm"
            PRDGEN_B_LIST_FHH="gefs_pgrb2ab_fhh.parm"
            ;;
        res_0p50)
            PRDGEN_GRID="0p5"
            PRDGEN_GRID_SPEC="latlon 0:720:0.5 90:361:-0.5"
#            PRDGEN_HOURS="{0..${FHMAXHF}..${FHOUTHF}} {$(( $FHMAXHF + ${FHOUTLF} ))..${fhmax}..${FHOUTLF}}"}
            PRDGEN_SUBMC="prd0p5"
            PRDGEN_A_DIR="pgrb2ap5"
            PRDGEN_A_PREFIX="pgrb2a.0p50."
            PRDGEN_A_LIST_F00="gefs_pgrb2a_f00.parm"
            PRDGEN_A_LIST_FHH="gefs_pgrb2a_fhh.parm"
            PRDGEN_B_DIR="pgrb2bp5"
            PRDGEN_B_PREFIX="pgrb2b.0p50."
            PRDGEN_B_LIST_F00="gefs_pgrb2ab_f00.parm"
            PRDGEN_B_LIST_FHH="gefs_pgrb2ab_fhh.parm"
            ;;
        res_0p25_s1)
            PRDGEN_GRID="0p25"
            PRDGEN_GRID_SPEC="latlon 0:1440:0.25 90:721:-0.25"
#            PRDGEN_HOURS="{0..${FHMAXHF}..$(( ${FHOUTHF} * 2 ))}"}
            PRDGEN_SUBMC="prd0p25"
            PRDGEN_A_DIR="pgrb2sp25"
            PRDGEN_A_PREFIX="pgrb2s.0p25."
            PRDGEN_A_LIST_F00="gefs_pgrb2a_f00.parm_0p25"
            PRDGEN_A_LIST_FHH="gefs_pgrb2a_fhh.parm_0p25"
            PRDGEN_B_DIR="pgrb2p25"
            PRDGEN_B_PREFIX="pgrb2.0p25."
            PRDGEN_B_LIST_F00="gefs_pgrb2ab_f00.parm"
            PRDGEN_B_LIST_FHH="gefs_pgrb2ab_fhh.parm"
            ;;
        res_0p25_s2)
            PRDGEN_GRID="0p25"
            PRDGEN_GRID_SPEC="latlon 0:1440:0.25 90:721:-0.25"
#            PRDGEN_HOURS="{${FHOUTHF}..${FHMAXHF}..$(( ${FHOUTHF} * 2 ))}"
            PRDGEN_SUBMC="prd0p25"
            PRDGEN_A_DIR="pgrb2sp25"
            PRDGEN_A_PREFIX="pgrb2s.0p25."
            PRDGEN_A_LIST_F00="gefs_pgrb2a_f00.parm_0p25"
            PRDGEN_A_LIST_FHH="gefs_pgrb2a_fhh.parm_0p25"
            PRDGEN_B_DIR="pgrb2p25"
            PRDGEN_B_PREFIX="pgrb2.0p25."
            PRDGEN_B_LIST_F00="gefs_pgrb2ab_f00.parm"
            PRDGEN_B_LIST_FHH="gefs_pgrb2ab_fhh.parm"
            ;;
    esac
	if [[ $SENDCOM == "YES" ]]; then
		mkdir -m 775 -p $COMOUT/$COMPONENT/${PRDGEN_A_DIR[${stream}]}
		if [[ ! -z ${PRDGEN_B_DIR[$stream]} ]]; then
			mkdir -m 775 -p $COMOUT/$COMPONENT/${PRDGEN_B_DIR[${stream}]}
		fi
	fi

	subdata=${DATA}/${stream}
	if [ ! -d ${subdata} ]; then
		mkdir -p ${subdata};
	fi
	infile=${subdata}/${stream}.in
	outfile=${subdata}/${stream}.out

	cat > ${infile} <<-EOF
		jobgrid="${PRDGEN_GRID}"
		grid_spec="${PRDGEN_GRID_SPEC}"
		hours="${PRDGEN_HOURS}"
		submc="${PRDGEN_SUBMC}"
		pgad="${PRDGEN_A_DIR}"
		pgapre="${PRDGEN_A_PREFIX}"
		parmlist_a00=$PARMgefs/gefs/${PRDGEN_A_LIST_F00}
		parmlist_ahh=$PARMgefs/gefs/${PRDGEN_A_LIST_FHH}
		pgbd="${PRDGEN_B_DIR}"
		pgbpre="${PRDGEN_B_PREFIX}"
		parmlist_b00=$PARMgefs/gefs/${PRDGEN_B_LIST_F00}
		parmlist_bhh=$PARMgefs/gefs/${PRDGEN_B_LIST_FHH}
		do_analysis="${PRDGEN_DO_ANALYSIS:-NO}"
	EOF

	echo "$HOMEgefs/ush/gefs_prdgen_driver.sh $stream $subdata \"$infile\" 2>&1 >${outfile}" >> prdgen.cmdfile

done

cat prdgen.cmdfile
chmod 775 prdgen.cmdfile
export MP_CMDFILE=${DATA}/prdgen.cmdfile
export SCR_CMDFILE=$MP_CMDFILE  # Used by mpiserial on Theia
export MP_PGMMODEL=mpmd
rm -f mpmd_cmdfile
ln -s $MP_CMDFILE mpmd_cmdfile

#############################################################
# Execute the script
$APRUN_MPMD
export err=$?

if [[ $err != 0 ]]; then
	echo "FATAL ERROR in ${BASH_SOURCE[1]}: One or more prdgen streams in $MP_CMDFILE failed!"
	exit $err
fi
#############################################################

echo "$(date -u) end ${BASH_SOURCE[1]}"

#exit $err
