#!/bin/bash

experimentId=88
clientRunTime=450
workLoad=1
inThread=10
outThread=0
noOfMW=1
poolSize=10
messType=1
repeatN=1


# for noOfClients in 2 6 12 18 24 30
# do
#    ./experiment_free_auto_redo.sh $experimentId $noOfClients $clientRunTime $workLoad $inThread $outThread $noOfMW $poolSize $messType $repeatN
# done

# experimentId=89
# noOfMW=2

# for noOfClients in 1 3 6 9 12 15
# do
#    ./experiment_free_auto_redo.sh $experimentId $noOfClients $clientRunTime $workLoad $inThread $outThread $noOfMW $poolSize $messType $repeatN
# done

experimentId=88
noOfMW=1
for totalClients in 2 6 12 18 24 30
do
	python client_RT_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN
	python middleware_TP_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN
done

experimentId=89
noOfMW=2
for totalClients in 2 6 18 24 30
do
	python client_RT_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN
	# python middleware_TP_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN
done

# Stability 
#./experiment_free_auto.sh 38 25 450 1 7 5 2 7 1 1

# Max throughput test 1

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 38 25 450 1 7 5 2 7 $i
# done
# python compute_CI.py 38 50

# Max throughput test 2

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 39 25 450 1 10 5 2 10 $i
# done

# python compute_CI.py 39 50

# Max throughput test 3

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 40 25 450 1 13 5 2 13 $i
# done

# python compute_CI.py 40 50

# Max throughput test 4

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 45 25 450 1 17 5 2 17 1 $i
# done

# python compute_CI.py 45 50

# RT Variation

# for i in 1 2 3
# do
# 	echo $i
#    ./experiment_free_auto.sh 41 30 450 1 10 5 2 10 1 $i
# done

# python compute_CI.py 41 60

# RT Variation 2

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 42 30 450 1 10 5 2 10 2 $i
# done

# python compute_CI.py 42 60

# RT Variation 3

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 43 15 450 1 13 5 4 13 1 $i
# done

# python compute_CI.py 43 60

# # RT Variation 4


# ./experiment_free_auto.sh 44 15 450 1 13 5 4 13 2 2


# python compute_CI.py 44 60

# Scalability

# for i in 1 2 3
# do
# 	echo $i
#    ./experiment_free_auto.sh 46 30 450 1 13 5 2 13 1 $i
# done

# python compute_CI.py 46 60

# Scalability

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 47 30 450 1 13 5 4 13 1 $i
# done

# python compute_CI.py 47 120

# Scalability

# for i in 1 2 3
# do
#    ./experiment_free_auto.sh 48 30 450 1 13 5 6 13 1 $i
# done

# python compute_CI.py 48 180


