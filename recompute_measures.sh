# #!/bin/bash 

# # params : expid, noCLi, in, out, mw, pool, wl, repeat

# #36 stability
# # python client_RT_trace.py
# # python middleware_TP_trace.py



# #38 max TP 55
# for i in 1 2 3
# do
# 	echo "38 repeat $i"
# 	python client_RT_trace.py 38 50 5 5 2 5 1 $i
# 	python middleware_TP_trace.py 38 50 5 5 2 5 1 $i
# done

# #39 max TP 1010
# for i in 1 2 3
# do
# 	echo "39 repeat $i"
# 	python client_RT_trace.py 39 50 10 5 2 10 1 $i
# 	python middleware_TP_trace.py 39 50 10 5 2 10 1 $i
# done

# #40 nax TP 1313
# for i in 1 2 3
# do
# 	echo "40 repeat $i"
# 	python client_RT_trace.py 40 50 13 5 2 13 1 $i
# 	python middleware_TP_trace.py 40 50 13 5 2 13 1 $i
# done

# #45 max TP 1717
# for i in 1 2 3
# do
# 	echo "45 repeat $i"
# 	python client_RT_trace.py 45 50 17 5 2 17 1 $i
# 	python middleware_TP_trace.py 45 50 17 5 2 17 1 $i
# done

# #41 RT Var 2 200
# for i in 1 2 3
# do
# 	echo "41 repeat $i"
# 	python client_RT_trace.py 41 60 10 5 2 10 1 $i
# 	python middleware_TP_trace.py 41 60 10 5 2 10 1 $i
# done

# #42 RT Var 2 2000
# for i in 1 2 3
# do
# 	echo "42 repeat $i"
# 	python client_RT_trace.py 42 60 10 5 2 10 1 $i
# 	python middleware_TP_trace.py 42 60 10 5 2 10 1 $i
# done

# #43 RT Var 4 200
# for i in 1 2 3
# do
# 	echo "43 repeat $i"
# 	python client_RT_trace.py 43 60 10 5 4 10 1 $i
# 	python middleware_TP_trace.py 43 60 10 4 2 10 1 $i
# done

# #44 RT Var 4 2000
# for i in 1 2 3
# do
# 	echo "44 repeat $i"
# 	python client_RT_trace.py 44 60 10 5 4 10 1 $i
# 	python middleware_TP_trace.py 44 60 10 5 4 10 1 $i
# done

# #46 Scal 60
# for i in 1 2 3
# do
# 	echo "46 repeat $i"
# 	python client_RT_trace.py 46 60 13 5 2 13 1 $i
# 	python middleware_TP_trace.py 46 60 13 5 2 13 1 $i
# done

# #47 Scal 120
# for i in 1 2 3
# do
# 	echo "47 repeat $i"
# 	python client_RT_trace.py 47 120 13 5 4 13 1 $i
# 	python middleware_TP_trace.py 47 120 13 5 4 13 1 $i
# done

#48 Scal 180
for i in 1 2 3
do
	echo "48 repeat $i"
	python client_RT_trace.py 48 180 13 5 6 13 1 $i
	python middleware_TP_trace.py 48 180 13 5 6 13 1 $i
done
