## rebuild stats, temp

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

for i in 1 2 3
do
   ./rebuild_stat.sh 40 25 450 1 13 5 2 13 $i
done

python compute_CI.py 40 50