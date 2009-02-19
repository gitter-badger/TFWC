#
# Copyright(c) 1991-1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/reverse.tcp.tcl,v 1.4 2006/02/14 00:53:29 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

set	reverse_app_num	$src_num

#
# Backward TCP Agent
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        set reverse_tcp_src($i) [new Agent/TCP/Sack1]
        $ns attach-agent $n(3) $reverse_tcp_src($i)
}

#
# Backward TCP Sink Agent
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        set reverse_tcp_sink($i) [new Agent/TCPSink/Sack1]
        $ns attach-agent $src_node($i) $reverse_tcp_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        $ns connect $reverse_tcp_src($i) $reverse_tcp_sink($i)
}

#
# Queue Size Setting
#
for {set i 1} {$i <= $src_num} {incr i} {
        $ns queue-limit $n(2) $src_node($i)    2
}

#
# random variables for beginning reverse FTP connections
#
set RftpRNG [new RNG]
for {set i 1} {$i < $seedno} {incr i} {
	$RftpRNG next-substream
}

set rRVftp [new RandomVariable/Uniform]
$rRVftp	set	min_	10.0
$rRVftp	set	max_	15.0
$rRVftp	use-rng	$RftpRNG

#
# random start time for each FTP connection
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        set startT($i) [expr [$rRVftp value]]
}

#
# create reverse FTPs
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        set reverse_ftp($i) [new Application/FTP]
        $reverse_ftp($i) attach-agent $reverse_tcp_src($i)
}

#
# start FTP
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
        $ns at $startT($i) "$reverse_ftp($i) start"
}