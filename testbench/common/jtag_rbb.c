///////////////////////////////////////////
// jtag_rbb.c
//
// Written: David Harris David_Harris@hmc.edu with Claude, 8 November 2026
//
// Purpose: DPI-C server for the remote_bitbang JTAG protocol (as served by
//   Spike's --rbb-port and used by OpenOCD's remote_bitbang adapter).
//   A host debugger connects over TCP and sends one character per pin change:
//     '0'-'7'  set {TCK, TMS, TDI}
//     'R'      read TDO; the server replies '0' or '1'
//     'Q'      quit
//     'B' 'b'  blink (ignored); 'r' 's' 't' 'u' TRST/SRST (ignored: no TRST pin)
//   jtag_rbb.sv applies each pin change to the DUT.
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// Copyright (C) 2026 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
////////////////////////////////////////////////////////////////////////////////////////////////

#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

// Verilator compiles this file as C++; DPI imports need C linkage.
#ifdef __cplusplus
extern "C" {
#endif

int rbb_open(int port);
int rbb_next(int tdo);

static int listen_fd = -1;
static int client_fd = -1;
static unsigned char recv_buf[4096];
static size_t recv_len = 0, recv_pos = 0;
static char send_buf[4096];
static size_t send_len = 0;

// Listen on 127.0.0.1:port (port 0 picks a free port). Returns the port or -1.
int rbb_open(int port) {
  struct sockaddr_in addr;
  socklen_t len = sizeof(addr);
  int one = 1;

  listen_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (listen_fd < 0) {
    perror("jtag_rbb: socket");
    return -1;
  }
  setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  addr.sin_port = htons(port);
  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0 || listen(listen_fd, 1) < 0 ||
      getsockname(listen_fd, (struct sockaddr *)&addr, &len) < 0) {
    perror("jtag_rbb: bind/listen");
    return -1;
  }
  return ntohs(addr.sin_port);
}

static int flush_send(void) {
  size_t off = 0;
  while (off < send_len) {
    ssize_t n = write(client_fd, send_buf + off, send_len - off);
    if (n < 0 && errno == EINTR) continue;
    if (n <= 0) return -1;
    off += (size_t)n;
  }
  send_len = 0;
  return 0;
}

// Next command character, blocking until the host sends one. -1 on end of connection.
static int next_char(void) {
  if (client_fd < 0) {
    int one = 1;
    do client_fd = accept(listen_fd, NULL, NULL);
    while (client_fd < 0 && errno == EINTR);
    if (client_fd < 0) return -1;
    setsockopt(client_fd, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one));
  }
  if (recv_pos == recv_len) {
    ssize_t n;
    if (flush_send() < 0) return -1;  // the host may be waiting for TDO before it sends more
    do n = read(client_fd, recv_buf, sizeof(recv_buf));
    while (n < 0 && errno == EINTR);
    if (n <= 0) return -1;
    recv_len = (size_t)n;
    recv_pos = 0;
  }
  return recv_buf[recv_pos++];
}

// Process host commands until the next pin change. tdo is the DUT's current TDO.
// Returns {tck, tms, tdi} as 0-7, or -1 when the host quits or disconnects.
int rbb_next(int tdo) {
  for (;;) {
    int c = next_char();
    if (c < 0 || c == 'Q') {
      if (client_fd >= 0) {
        flush_send();
        close(client_fd);
      }
      client_fd = -1;
      return -1;
    }
    if (c >= '0' && c <= '7') return c - '0';
    if (c == 'R') {
      if (send_len == sizeof(send_buf) && flush_send() < 0) return -1;
      send_buf[send_len++] = tdo ? '1' : '0';
    }
    // Other characters (blink, TRST/SRST) need no action.
  }
}

#ifdef __cplusplus
}
#endif
