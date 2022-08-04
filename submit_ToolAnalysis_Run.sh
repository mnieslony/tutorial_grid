# Submit all data decoder TA jobs for one particular run on the grid
# M. Nieslony, using V. Fischers TA submission script (code based on other people's code as usual)

if [ "$#" -ne 2 ]; then
      echo "Usage: ./submit_ToolAnalysis_Run.sh RUN_NR FILES_SUB"
      echo "Options are: run number, files being transferred at submission (1/0)"
      exit 1
fi

RUN_NR=$1
FILES_SUB=$2

FILEDIR=/pnfs/annie/persistent/raw/raw/${RUN_NR}
DIRNAME=MyToolAnalysis_LAPPD
TARFILE=ToolAnalysis_for_grid_Tutorial.tar.gz 

#Go through all raw data files in the listed directory
for entry in "${FILEDIR}/RAWDataR${RUN_NR}"*
do
	echo $entry
	./submit_ToolAnalysis_job.sh ${entry} GetLAPPDEvents ${FILES_SUB} ${DIRNAME} ${TARFILE}
done

