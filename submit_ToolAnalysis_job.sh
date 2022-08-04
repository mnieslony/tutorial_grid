# Submit a single TA job on the grid
# V. Fischer (code based on other people's code as usual)

if [ "$#" -ne 5 ]; then
      echo "Usage: ./submit_ToolAnalysis_job.sh FILENAME TOOLCHAIN TRANSFER_FILES_SUB DIRNAME TARFILE"
      echo "Options are: filename (with path), name of toolchain, files being transferred at submission (1/0), directory name of ToolAnalysis directory, tar-file name"
      exit 1
fi

source /cvmfs/annie.opensciencegrid.org/setup_annie.sh
setup jobsub_client

###MODIFY SCRIPT_PATH
export SCRIPT_PATH=/annie/app/users/mnieslon/tutorial_lappd/grid
###MODIFY GRID PATH
export GRID_TAR_PATH=/pnfs/annie/persistent/users/mnieslon/grid

FILENAME=$1
TOOLCHAIN=$2
TRANSFER_FILES_SUBMISSION=$3
DIRNAME=$4
TARFILE=$5

QUEUE=medium

FILENAME_NOPATH=${FILENAME##*/}
FILENAME_PATH=${FILENAME%/*}
FILENAME_NOSUFFIX="${FILENAME_NOPATH#RAWData}"
FILENAME_RUNONLY="${FILENAME_NOSUFFIX%S*}"


if [[ "$TOOLCHAIN" == *"GetLAPPDEvents"* ]]
then
    ###MODIFY OUTPUT_FOLDER
    OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/grid_example/$FILENAME_RUNONLY
    mkdir -p $OUTPUT_FOLDER
fi

if [[ "$TOOLCHAIN" == *"Decoder"* ]]
then
    OUTPUT_FOLDER=/pnfs/annie/persistent/users/mnieslon/data/processed_lappd/$FILENAME_RUNONLY
    mkdir -p $OUTPUT_FOLDER
fi

if [[ "$TOOLCHAIN" == *"ClusterFinder"* ]]
then
    OUTPUT_FOLDER=$FILENAME_PATH
fi    

if [ $TRANSFER_FILES_SUBMISSION -eq 0 ]
then
    echo "Submitting job..."
    jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f $FILENAME \
            -f ${GRID_TAR_PATH}/${TARFILE}  \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_grid.sh $FILENAME_NOPATH configfiles/$TOOLCHAIN $DIRNAME $TARFILE
fi

if [ $TRANSFER_FILES_SUBMISSION -eq 1 ]
then
    echo "Submitting job..."
    jobsub_submit -g --memory=4000MB --expected-lifetime=${QUEUE} --group=annie --disk=30GB \
            --resource-provides=usage_model=OPPORTUNISTIC,DEDICATED \
            --jobsub-server=https://fifebatch.fnal.gov:8443 -q \
            -f dropbox://$FILENAME \
            -f dropbox://${GRID_TAR_PATH}/${TARFILE}  \
            -d OUTPUT $OUTPUT_FOLDER \
            file://${SCRIPT_PATH}/ToolAnalysis_grid.sh $FILENAME_NOPATH configfiles/$TOOLCHAIN $DIRNAME $TARFILE
fi
