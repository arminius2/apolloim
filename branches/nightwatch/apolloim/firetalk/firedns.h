/*
firedns.h - firedns library declarations
Copyright (C) 2002 Ian Gulliver

This program is free software; you can redistribute it and/or modify
it under the terms of version 2 of the GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _FIREDNS_H
#define _FIREDNS_H

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define FIREDNS_NO_IPV6

#ifdef AF_INET6
#ifndef FIREDNS_NO_IPV6
#define FIREDNS_USE_IPV6
#endif
#endif

#ifndef AF_INET6
struct in6_addr {
	unsigned char   s6_addr[16];
};
#endif

#define FDNS_MAX              8                    /* max number of nameservers used */
#define FDNS_CONFIG_PREF     "/etc/firedns.conf"   /* preferred firedns config file */
#define FDNS_CONFIG_FBCK     "/etc/resolv.conf"    /* fallback config file */
#define FDNS_PORT            53                    /* DNS well known port */
#define FDNS_QRY_A            1                    /* name to IP address */
#define FDNS_QRY_AAAA        28                    /* name to IP6 address */
#define FDNS_QRY_PTR         12                    /* IP address to name */
#define FDNS_QRY_MX          15                    /* name to MX */
#define FDNS_QRY_TXT         16                    /* name to TXT */

void firedns_init();

/* non-blocking functions */
struct in_addr *firedns_aton4(const char * const ipstring);
struct in6_addr *firedns_aton6(const char * const ipstring);
char *firedns_ntoa4(const struct in_addr * const ip);
char *firedns_ntoa6(const struct in6_addr * const ip);
int firedns_getip4(const char * const name);
int firedns_getip6(const char * const name);
int firedns_gettxt(const char * const name);
int firedns_getmx(const char * const name);
int firedns_getname4(const struct in_addr * const ip);
int firedns_getname6(const struct in6_addr * const ip);
int firedns_dnsbl_lookup_a(const struct in_addr * const ip, const char * const name);
int firedns_dnsbl_lookup_txt(const struct in_addr * const ip, const char * const name);
char *firedns_getresult(const int fd);

/* buffer pass-in non-blocking functions */
struct in_addr *firedns_aton4_s(const char * const ipstring, struct in_addr * const ip);
struct in6_addr *firedns_aton6_s(const char * const ipstring, struct in6_addr * const ip);
char *firedns_ntoa4_s(const struct in_addr * const ip, char * const result);
char *firedns_ntoa6_s(const struct in6_addr * const ip, char * const result);
char *firedns_getresult_s(const int fd, char * const result);

/* thread-safe functions that allocate their own buffers */
struct in_addr *firedns_aton4_r(const char * const ipstring);
struct in6_addr *firedns_aton6_r(const char * const ipstring);
char *firedns_ntoa4_r(const struct in_addr * const ip);
char *firedns_ntoa6_r(const struct in6_addr * const ip);
char *firedns_getresult_r(const int fd);

/* low-timeout blocking functions */
struct in_addr *firedns_resolveip4(const char * const name);
struct in6_addr *firedns_resolveip6(const char * const name);
char *firedns_resolvetxt(const char * const name);
char *firedns_resolvemx(const char * const name);
char *firedns_resolvename4(const struct in_addr * const ip);
char *firedns_resolvename6(const struct in6_addr * const ip);

/* reentrant low-timeout blocking functions */
struct in_addr *firedns_resolveip4_r(const char * const name);
struct in6_addr *firedns_resolveip6_r(const char * const name);
char *firedns_resolvetxt_r(const char * const name);
char *firedns_resolvemx_r(const char * const name);
char *firedns_resolvename4_r(const struct in_addr * const ip);
char *firedns_resolvename6_r(const struct in6_addr * const ip);

#endif
