#!/bin/bash
# Based on /annie/app/users/dingpf/GridSub_test.sh
# Based on V. Fischer's script, modified for LAPPD tutorial

cat <<EOF
condor   dir: $CONDOR_DIR_INPUT
process   id: $PROCESS
output   dir: $CONDOR_DIR_OUTPUT
EOF

# Source the annie setup file on cvmfs
source /cvmfs/larsoft.opensciencegrid.org/products/setup
source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup fife_utils

HOSTNAME=$(hostname -f)

###MODIFY: Specify your user name
GRIDUSER="mnieslon"

echo "Job starting on $(uname -a)"

# Hack by Marcus to limit the number of ifdh cp tries
setup ifdhc   # for copying geometry & flux files
export IFDH_CP_MAXRETRIES=2  # default 8 tries is silly

# run the actual job
FILENAME=$1
TOOLCHAIN_FILE=$2
DIRNAME=$3
TARFILE=$4

# Create a dummy file in the output directory. This is a hack to get jobs
# that fail to end themselves quickly rather than hanging on for a long time
# waiting for output to arrive.
DUMMY_OUTPUT_FILE=${CONDOR_DIR_OUTPUT}/${JOBSUBJOBID}_dummy_output
touch ${DUMMY_OUTPUT_FILE}

# Go into the input directory and extract ratpac and geant4
cd $CONDOR_DIR_INPUT
tar -xzf ${TARFILE}

echo "Contents of CONDOR INPUT DIR:"
ls

# Creating the tool input files
echo "Creating my_inputs.txt or my_files.txt"

if [[ "$TOOLCHAIN_FILE" == *"GetLAPPDEvents"* ]]
then
    rm ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_files.txt
    echo $FILENAME > ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_files.txt
    ls ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE} > ${CONDOR_DIR_INPUT}/${DIRNAME}/temp_${FILENAME}.txt
    cat ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_files.txt >> ${CONDOR_DIR_INPUT}/${DIRNAME}/temp_${FILENAME}.txt
fi
if [[ "$TOOLCHAIN_FILE" == *"Decoder"* ]]
then
    rm ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_files.txt
    echo $FILENAME > ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_files.txt
fi
if [[ "$TOOLCHAIN_FILE" == *"ClusterFinder"* ]]
then
    rm ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_inputs.txt
    echo $FILENAME > ${CONDOR_DIR_INPUT}/${DIRNAME}/${TOOLCHAIN_FILE}/my_inputs.txt
fi

# setup software
export TOOLANALYSIS_PATH=${CONDOR_DIR_INPUT}/${DIRNAME}
singularity shell -B/pnfs:/pnfs,/annie/data/:/annie/data,/annie/app:/annie/app /cvmfs/singularity.opensciencegrid.org/anniesoft/toolanalysis\:latest/
cd ${TOOLANALYSIS_PATH}

ls /cvmfs/singularity.opensciencegrid.org/anniesoft/toolanalysis\:latest/ToolAnalysis/ToolDAQ
source SetupSingularityGrid.sh
echo "Contents of TA folder:"
ls

# Copy datafile in ToolAnalysis
ifdh cp -r $CONDOR_DIR_INPUT/$FILENAME $TOOLANALYSIS_PATH

# Change output filenames in config file
sed -i "3s#.*#OutputFile NumEvents_${FILENAME}.csv#" ${TOOLANALYSIS_PATH}/configfiles/GetLAPPDEvents/GetLAPPDEventsConfig
sed -i "4s#.*#OutputFileLAPPD LAPPDFiles_${FILENAME}.txt#" ${TOOLANALYSIS_PATH}/configfiles/GetLAPPDEvents/GetLAPPDEventsConfig

# Run toolanalysis
echo ${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig
${TOOLANALYSIS_PATH}/Analyse $TOOLCHAIN_FILE/ToolChainConfig > output_${FILENAME}.log
#exit

echo "Moving the output files to CONDOR OUTPUT:"


if [[ "$TOOLCHAIN_FILE" == *"GetLAPPDEvents"* ]] 
then
    ifdh cp -r ${TOOLANALYSIS_PATH}/NumEvents_${FILENAME}.csv ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/LAPPDFiles_${FILENAME}.txt ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/output_${FILENAME}.log ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/temp_${FILENAME}.txt ${CONDOR_DIR_OUTPUT}
fi
if [[ "$TOOLCHAIN_FILE" == *"Decoder"* ]] 
then
    echo ifdh cp -r ${TOOLANALYSIS_PATH}/ProcessedRawData* ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/ProcessedRawData* ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/OrphanStore* ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/decoding_${FILENAME}.log ${CONDOR_DIR_OUTPUT}
fi
if [[ "$TOOLCHAIN_FILE" == *"ClusterFinder"* ]]
then
    echo ifdh cp -r ${TOOLANALYSIS_PATH}/*.root ${CONDOR_DIR_OUTPUT}
    ifdh cp -r ${TOOLANALYSIS_PATH}/*.root ${CONDOR_DIR_OUTPUT}
fi
### END ###
