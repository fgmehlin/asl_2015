

gnuplot << EOF
set terminal jpeg large size 1280,720
set output '/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo/15/C/stats/trace_client.jpg'

#set terminal pdf
#set output '$experimentDir/plot/trace_client_err.pdf'

set xlabel 'Client Id'
set ylabel 'Mean Response Time (ms)'
	
set title 'Each Client Response Time Trace'
set xrange [0:60]
set yrange [0:]

plot '/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo/15/C/stats/eachClient_sorted.stat' using 1:2:3 with errorlines title "test"
EOF
echo "OK"