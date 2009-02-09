#------------------------------------------
# On comparison between TCP Tahoe and TFRC
#------------------------------------------
#
# This is a test code for TCP basics written by Soo-Hyun Choi
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (Apr 28, 2004)
#

# Creat a simulatro object
set ns [new Simulator]

# File opening for nam 
set output [open out.tr w]
$ns trace-all $output

set nam_out [open out.nam w]
$ns namtrace-all $nam_out

set queue_out [open out.queue w]
set f0 [open out0.tr w]
set f1 [open out1.tr w]

# Define topology
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail orient right-down
$ns duplex-link $n1 $n2 5Mb 2ms DropTail orient right-up
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail orient right


# Queue definition
$ns queue-limit $n2 $n3 100 


# Set Dummy UDP Agent
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

# Create 4 TCP/Sack1 and 4 TFRC Agents
set tcp01 [new Agent/TCP]
set tcp02 [new Agent/TCP]
set tcp03 [new Agent/TCP]
set tcp04 [new Agent/TCP]
Agent/TCP set window_ 100

set tfrc01 [new Agent/TFRC]
set tfrc02 [new Agent/TFRC]
set tfrc03 [new Agent/TFRC]
set tfrc04 [new Agent/TFRC]

$ns attach-agent $n1 $tcp01
$ns attach-agent $n1 $tcp02
$ns attach-agent $n1 $tcp03
$ns attach-agent $n1 $tcp04

$ns attach-agent $n1 $tfrc01
$ns attach-agent $n1 $tfrc02
$ns attach-agent $n1 $tfrc03
$ns attach-agent $n1 $tfrc04

# Create a TCP/TFRC Sink Agent
set tcp_sink01 [new Agent/TCPSink]
set tcp_sink02 [new Agent/TCPSink]
set tcp_sink03 [new Agent/TCPSink]
set tcp_sink04 [new Agent/TCPSink]
                                                                                
set tfrc_sink01 [new Agent/TFRCSink]
set tfrc_sink02 [new Agent/TFRCSink]
set tfrc_sink03 [new Agent/TFRCSink]
set tfrc_sink04 [new Agent/TFRCSink]
                                                                                
Agent/TCPSink set packetSize_ 40
Agent/TFRCSink set discount 0
                                                                                
$ns attach-agent $n3 $tcp_sink01
$ns attach-agent $n3 $tcp_sink02
$ns attach-agent $n3 $tcp_sink03
$ns attach-agent $n3 $tcp_sink04
                                                                                
$ns attach-agent $n3 $tfrc_sink01
$ns attach-agent $n3 $tfrc_sink02
$ns attach-agent $n3 $tfrc_sink03
$ns attach-agent $n3 $tfrc_sink04

# Create FTPs from n1 to n3
set ftp01 [new Application/FTP]
set ftp02 [new Application/FTP]
set ftp03 [new Application/FTP]
set ftp04 [new Application/FTP]
                                                                                
set ftp05 [new Application/FTP]
set ftp06 [new Application/FTP]
set ftp07 [new Application/FTP]
set ftp08 [new Application/FTP]
                                                                                
$ftp01 attach-agent $tcp01
$ftp02 attach-agent $tcp02
$ftp03 attach-agent $tcp03
$ftp04 attach-agent $tcp04
                                                                                
$ftp05 attach-agent $tfrc01
$ftp06 attach-agent $tfrc02
$ftp07 attach-agent $tfrc03
$ftp08 attach-agent $tfrc04
                                                                                
$ns at 0.3 "$ftp01 start"
$ns at 0.3 "$ftp02 start"
$ns at 0.3 "$ftp03 start"
$ns at 0.3 "$ftp04 start"
                                                                                
$ns at 1.5 "$ftp05 start"
$ns at 1.5 "$ftp06 start"
$ns at 1.5 "$ftp07 start"
$ns at 1.5 "$ftp08 start"
                                                                                
$ns connect $tcp01 $tcp_sink01
$ns connect $tcp02 $tcp_sink02
$ns connect $tcp03 $tcp_sink03
$ns connect $tcp04 $tcp_sink04
                                                                                
$ns connect $tfrc01 $tfrc_sink01
$ns connect $tfrc02 $tfrc_sink02
$ns connect $tfrc03 $tfrc_sink03
$ns connect $tfrc04 $tfrc_sink04
                                                                                
$ns at 55.0 "$ns detach-agent $n0 $tcp01; $ns detach-agent $n3 $tcp_sink01"
$ns at 55.0 "$ns detach-agent $n0 $tcp02; $ns detach-agent $n3 $tcp_sink02"
$ns at 55.0 "$ns detach-agent $n0 $tcp03; $ns detach-agent $n3 $tcp_sink03"
$ns at 55.0 "$ns detach-agent $n0 $tcp04; $ns detach-agent $n3 $tcp_sink04"
                                                                                
$ns at 50.0 "$ns detach-agent $n0 $tfrc01; $ns detach-agent $n3 $tfrc_sink01"
$ns at 50.0 "$ns detach-agent $n0 $tfrc02; $ns detach-agent $n3 $tfrc_sink02"
$ns at 50.0 "$ns detach-agent $n0 $tfrc03; $ns detach-agent $n3 $tfrc_sink03"
$ns at 50.0 "$ns detach-agent $n0 $tfrc04; $ns detach-agent $n3 $tfrc_sink04"


# Make a queue trace
$ns trace-queue $n2 $n3 $queue_out

# A simulation runs for 3 sec.
$ns at 60.0 "finish"
proc finish {} {
		global ns output nam_out queue_out f0 f1
		$ns flush-trace
		close $output
		close $nam_out
		close $queue_out
		close $f0
		close $f1

		# exec nam out.nam &
		exec perl ../../ns-2.26/bin/set_flow_id -s out.tr 
		exec perl ../../ns-2.26/bin/getrc -s 2 -d 3 < out.tr > foo
		exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < foo > temp.rands
		exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Tahoe w/ DT Q=100" -geometry 1200x400 temp.rands &
		exec xgraph -P -x time -y "rate (Mb/s)" -t "Tx rate for 4xTCP Ta hoe and 4xTFRC w/ DT (Q=100)" -geometry 1200x400 out0.tr out1.tr &

		# thruput calculation
		exec awk -f thru.awk out.queue
		exec xgraph -P -x time -y "rate (Mb/s)" -t "Thruput for 4xTCP Tahoe and 4xTFRC w/ DT (Q=100)" -geometry 1200x400 temp.thru &

		exec awk -f tcp_thru.awk out.queue
		exec awk -f tf_thru.awk out.queue
                exec xgraph -P -x time -y "rate (Mb/s)" -t "Individual Thruput (4xTCP Tahoe and 4xTFRC) w/ DT (Q=100)" -geometry 1200x400 tcp_temp.thru tf_temp.thru &

		exit 0
		}

# Set the last bytes' value
set last_bytes_01 0
set last_bytes_02 0
set last_bytes_03 0
set last_bytes_04 0
                                                                         
set tf_last_bytes_01 0
set tf_last_bytes_02 0
set tf_last_bytes_03 0
set tf_last_bytes_04 0

proc record {} {
                global f0 f1 tcp01 tcp02 tcp03 tcp04 tfrc01 tfrc02 tfrc03 tfrc04
		global last_bytes_01 last_bytes_02 last_bytes_03 last_bytes_04 
		global tf_last_bytes_01 tf_last_bytes_02 tf_last_bytes_03 tf_last_bytes_04


                set ns [Simulator instance]
                set time 0.05

                # Number of bytes
                set bw1 [$tcp01 set ndatabytes_]
                set bw2 [$tcp02 set ndatabytes_]
                set bw3 [$tcp03 set ndatabytes_]
                set bw4 [$tcp04 set ndatabytes_]
                              
                set tfbw1 [$tfrc01 set ndatapack_]
                set tfbw2 [$tfrc02 set ndatapack_]
                set tfbw3 [$tfrc03 set ndatapack_]
                set tfbw4 [$tfrc04 set ndatapack_]
       
                # Get the current time
                set now [$ns now]

                # Calculate the sending rate (Mb/s)
                puts $f0 "$now [expr (($bw1-$last_bytes_01)+($bw2-$last_bytes_02)+($bw3-$last_bytes_03)+($bw4-$last_bytes_04))/$time*8/1000000]"
                puts $f1 "$now [expr (($tfbw1*1000-$tf_last_bytes_01)+($tfbw2*1000-$tf_last_bytes_02)+($tfbw3*1000-$tf_last_bytes_03)+($tfbw4*1000-$tf_last_bytes_04))/$time*8/1000000]"


                # Reset the bytes value
                set last_bytes_01 $bw1
                set last_bytes_02 $bw2
                set last_bytes_03 $bw3
                set last_bytes_04 $bw4

                set tf_last_bytes_01 $tfbw1*1000
                set tf_last_bytes_02 $tfbw2*1000
                set tf_last_bytes_03 $tfbw3*1000
                set tf_last_bytes_04 $tfbw4*1000
                                                         
                # Re-schedule the procedure
                $ns at [expr $now+$time] "record"
                }

# Start simulation
$ns at 0.0 "record"
$ns run
