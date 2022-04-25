#!/bin/csh
# Submit this script as : sbatch ./[script-name]
#SBATCH -A esmd
#SBATCH -q slurm
#SBATCH -t 12:00:00
#SBATCH -N 5
#SBATCH  --job-name=nudge

setenv OMP_NUM_THREADS 1

set workdir = `pwd`

cd $workdir

set ii = 1

while ( $ii < 11 ) 
 
 set file = run_process_exp`printf "%02d" $ii`.csh
 echo $file 
 csh $file > csh`printf "%02d" $ii`.log & 
 @ ii++ 
end 
set file = run_process_exp`printf "%02d" $ii`.csh
csh $file  > csh`printf "%02d" $ii`.log 

wait

