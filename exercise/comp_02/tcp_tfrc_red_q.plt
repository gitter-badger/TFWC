#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_q_tfrc_red_reverse.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Queue Size (TFRCs)"
set	xlabel		"time"
set	ylabel		"queue size in packets"

plot	"trace/tcp_q.xg" with linespoints, \
	"trace/tfrc_q.xg" with linespoints

#replot
#EOF
