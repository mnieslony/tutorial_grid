# Submit all data decoder TA jobs for one particular run on the grid
# M. Nieslony, using V. Fischers TA submission script (code based on other people's code as usual)

if [ "$#" -ne 2 ]; then
      #echo "Usage: ./submit_DataDecoder_Run.sh FILEDIR RUN_NR FILES_SUB TRIGOVERLAPZIP BEAMSTATUS"
      #echo "Options are: file directory containing raw data files, run number, files being transferred at submission (1/0), zip-file with trigger overlap files, Beam status file"
      echo "Usage: ./submit_DataDecoder_Run.sh RUN_NR FILES_SUB"
      echo "Options are: run number, files being transferred at submission (1/0)"
      exit 1
fi

#FILEDIR=$1
#RUN_NR=$2
#FILES_SUB=$3
#TRIGOVERLAP=$4
#BEAMSTATUS=$5

RUN_NR=$1
FILES_SUB=$2

#FILEDIR=/pnfs/annie/raw/raw/${RUN_NR}
FILEDIR=/pnfs/annie/persistent/raw/raw/${RUN_NR}
TRIGOVERLAP=/pnfs/annie/persistent/users/mnieslon/data/trigoverlap/TrigOverlap_R${RUN_NR}.tar.gz
BEAMSTATUS=/pnfs/annie/persistent/users/mnieslon/data/beamdb/${RUN_NR}_beamdb

#Go through all raw data files in the listed directory
for entry in "${FILEDIR}/RAWDataR${RUN_NR}"*
do
	echo $entry
        FILE_SIZE=`du -k "${entry}" | cut -f1`
        echo ${FILE_SIZE}
        if [ ${FILE_SIZE} -ge 800000 ]; then
                echo "File size greater 1GB"
		echo "./submit_ToolAnalysis_job_8GB.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}"
		./submit_ToolAnalysis_job_8GB.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}
        else
                echo "File size smaller than 1GB"
		echo "./submit_ToolAnalysis_job.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}"
		./submit_ToolAnalysis_job.sh ${entry} DataDecoder ${FILES_SUB} ${TRIGOVERLAP} ${BEAMSTATUS}
        fi
done

