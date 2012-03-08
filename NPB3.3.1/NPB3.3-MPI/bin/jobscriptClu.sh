#!/bin/sh
#PBS -l walltime=02:00:00
#PBS -N lu.C
#PBS -q normal
#PBS -l nodes=32:ppn=12
#PBS -m bea
#PBS -M moussa.taifi@temple.edu
#PBS -o lu.C.log
#PBS -o lu.C.err

cd $PBS_O_WORKDIR
cat $PBS_NODEFILE > nodefile.txt
python parsenodefile.py nodefile.txt 

mpirun -n 2 -npernode 2 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n2.p2-results.txt;
mpirun -n 2 -npernode 8 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n2.p8-results.txt;
mpirun -n 2 -npernode 12 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n2.p12-results.txt;

mpirun -n 4 -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n4.p1-results.txt;
mpirun -n 4 -npernode 2 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n4.p2-results.txt;
mpirun -n 4 -npernode 4 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n4.p4-results.txt;
mpirun -n 4 -npernode 8 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n4.p8-results.txt;
mpirun -n 4 -npernode 12 -hostfile myhostfile.txt ./lu.C.36 | tee lu.C.36.n4.p12-results.txt;

mpirun -n 8 -npernode 1 -hostfile myhostfile.txt ./lu.C.4 | tee lu.C.4.n8.p1-results.txt;
mpirun -n 8 -npernode 2 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n8.p2-results.txt;
mpirun -n 8 -npernode 4 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n8.p4-results.txt;
mpirun -n 8 -npernode 8 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n8.p8-results.txt;
mpirun -n 8 -npernode 12 -hostfile myhostfile.txt ./lu.C.81 | tee lu.C.81.n8.p12-results.txt;

mpirun -n 16 -npernode 1 -hostfile myhostfile.txt ./lu.C.16 | tee lu.C.16.n16.p1-results.txt;
mpirun -n 16 -npernode 2 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n16.p2-results.txt;
mpirun -n 16 -npernode 4 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n16.p4-results.txt;
mpirun -n 16 -npernode 8 -hostfile myhostfile.txt ./lu.C.121 | tee lu.C.121.n16.p8-results.txt;
mpirun -n 16 -npernode 12 -hostfile myhostfile.txt ./lu.C.169 | tee lu.C.169.n16.p12-results.txt;

mpirun -n 32 -npernode 1 -hostfile myhostfile.txt ./lu.C.25 | tee lu.C.25.n32.p1-results.txt;
mpirun -n 32 -npernode 2 -hostfile myhostfile.txt ./lu.C.64 | tee lu.C.64.n32.p2-results.txt;
mpirun -n 32 -npernode 4 -hostfile myhostfile.txt ./lu.C.121 | tee lu.C.121.n32.p4-results.txt;
mpirun -n 32 -npernode 8 -hostfile myhostfile.txt ./lu.C.256 | tee lu.C.256.n32.p8-results.txt;
mpirun -n 32 -npernode 12 -hostfile myhostfile.txt ./lu.C.361 | tee lu.C.361.n32.p12-results.txt;






