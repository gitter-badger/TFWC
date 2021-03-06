/*
 * Copyright(c) 2008-2010 University College London
 * All rights reserved.
 *
 * AUTHOR: Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE
 *
 * $Id$
 */

/*
 * compute fairness between TCP and TFRC, and TCP and TFWC.
 *
 * Usage: ./fairness [tcp-tfrc|tcp-tfwc] [queue_type] [bandwidth] [# of flows] [tcp_data] [tfrc/tfwc_data]
 */

#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <string.h>

using namespace std;

int main (int argc, char *argv[]) {
	double	tcpRate		= 0.0;
	double	friendlyRate	= 0.0;
	double	fairness 	= 0.0;
	double	bandwidth	= 0.0;
	int	num_flow	= 0;

	if (argc < 6) {
		cout << "Usage: ./fairness [tcp-tfrc|tcp-tfwc] [queue_type] \
[bandwidth] [# of flows] [tcp_data] [tfrc/tfwc_data]" << endl;
		exit (0);
	}

	bandwidth = atof(argv[3]);
	num_flow = atoi(argv[4]);

	ifstream tcp (argv[5]);
	ifstream tcpFriend (argv[6]);
	ofstream record;

	if (tcp.is_open() && tcpFriend.is_open()) {
		tcp >> tcpRate;
		tcpFriend >> friendlyRate;

		tcp.close();
		tcpFriend.close();
	} else {
		cout << "Unable to open the file!!!" << endl;
	}

	fairness = tcpRate / (tcpRate + friendlyRate);
	
	if (!strcmp(argv[1],"tcp-tfrc")) {
		if (!strcmp(argv[2],"DropTail")) {
			record.open ("trace/tcp-tfrc_fifo_fairness.xg", ios::app);
			record << bandwidth << "\t" << num_flow << "\t" << fairness << endl;
			record.close();
		} else if (!strcmp(argv[2],"RED")) {
			record.open ("trace/tcp-tfrc_red_fairness.xg", ios::app);
			record << bandwidth << "\t" << num_flow << "\t" << fairness << endl;
			record.close();
		}
	} else if (!strcmp(argv[1],"tcp-tfwc")) {
		if (!strcmp(argv[2],"DropTail")) {
			record.open ("trace/tcp-tfwc_fifo_fairness.xg", ios::app);
			record << bandwidth << "\t" << num_flow << "\t" << fairness << endl;
			record.close();
		} else if (!strcmp(argv[2],"RED")) {
			record.open ("trace/tcp-tfwc_red_fairness.xg", ios::app);
			record << bandwidth << "\t" << num_flow << "\t" << fairness << endl;
			record.close();
		}
	}

	return 0;
}
