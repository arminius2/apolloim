/*
firedns.c - firedns library
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

#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include "firestring.h"
//#include "firemake.h"
#include "firedns.h"

static const char tagstring[] = "$Id: firedns.c,v 1.56 2002/11/12 22:38:36 ian Exp $";

#define FIREDNS_TRIES 3
#define min(a,b) (a < b ? a : b)

static struct in_addr servers4[FDNS_MAX]; /* up to FDNS_MAX nameservers; populated by firedns_init() */
static int i4; /* actual count of nameservers; set by firedns_init() */
#ifdef FIREDNS_USE_IPV6
static int i6;
static struct in6_addr servers6[FDNS_MAX];
#endif

static int initdone = 0; /* to ensure firedns_init() only runs once (on the first call) */
static int wantclose = 0;
static int lastcreate = -1;

struct s_connection { /* open DNS query */
	struct s_connection *next; /* next in list */
	unsigned char id[2]; /* unique ID (random number), matches header ID; both set by firedns_add_query() */
	unsigned short class;
	unsigned short type;
	int fd; /* file descriptor returned from sockets */
#ifdef FIREDNS_USE_IPV6
	int v6;
#endif
};

struct s_rr_middle {
	unsigned short type;
	unsigned short class;
	unsigned long ttl;
	unsigned short rdlength;
};

#define FIREDNS_POINTER_VALUE 0xc000

static pthread_mutex_t connlist_lock = PTHREAD_MUTEX_INITIALIZER;
static struct s_connection *connection_head = NULL; /* linked list of open DNS queries; populated by firedns_add_query(), decimated by firedns_getresult_s() */

struct s_header { /* DNS query header */
	unsigned char id[2];
	unsigned char flags1;
#define FLAGS1_MASK_QR 0x80
#define FLAGS1_MASK_OPCODE 0x78 /* bitshift right 3 */
#define FLAGS1_MASK_AA 0x04
#define FLAGS1_MASK_TC 0x02
#define FLAGS1_MASK_RD 0x01
	unsigned char flags2;
#define FLAGS2_MASK_RA 0x80
#define FLAGS2_MASK_Z  0x70
#define FLAGS2_MASK_RCODE 0x0f
	unsigned short qdcount;
	unsigned short ancount;
	unsigned short nscount;
	unsigned short arcount;
	unsigned char payload[512]; /* DNS question, populated by firedns_build_query_payload() */
};

static inline void firedns_close(int fd) { /* close query */
	if (fd == lastcreate) {
		wantclose = 1;
		return;
	}
	close(fd);
	return;
}

void firedns_init() { /* on first call only: populates servers4 (or -6) struct with up to FDNS_MAX nameserver IP addresses from /etc/firedns.conf (or /etc/resolv.conf) */
	FILE *f;
	int i;
	struct in_addr addr4;
	char buf[1024];
#ifdef FIREDNS_USE_IPV6
	struct in6_addr addr6;
#endif
	if (initdone == 1)
		return;
#ifdef FIREDNS_USE_IPV6
	i6 = 0;
#endif
	i4 = 0;

	initdone = 1;
	srand((unsigned int) time(NULL));
	memset(servers4,'\0',sizeof(struct in_addr) * FDNS_MAX);
#ifdef FIREDNS_USE_IPV6
	memset(servers6,'\0',sizeof(struct in6_addr) * FDNS_MAX);
#endif
	/* read /etc/firedns.conf if we've got it, otherwise parse /etc/resolv.conf */
	f = fopen(FDNS_CONFIG_PREF,"r");
	if (f == NULL) {
		f = fopen(FDNS_CONFIG_FBCK,"r");
		if (f == NULL)
			return;
		while (fgets(buf,1024,f) != NULL) {
			if (strncmp(buf,"nameserver",10) == 0) {
				i = 10;
				while (buf[i] == ' ' || buf[i] == '\t')
					i++;
#ifdef FIREDNS_USE_IPV6
				/* glibc /etc/resolv.conf seems to allow ipv6 server names */
				if (i6 < FDNS_MAX) {
					if (firedns_aton6_s(&buf[i],&addr6) != NULL) {
						memcpy(&servers6[i6++],&addr6,sizeof(struct in6_addr));
						continue;
					}
				}
#endif
				if (i4 < FDNS_MAX) {
					if (firedns_aton4_s(&buf[i],&addr4) != NULL)
						memcpy(&servers4[i4++],&addr4,sizeof(struct in_addr));
				}
			}
		}
	} else {
		while (fgets(buf,1024,f) != NULL) {
#ifdef FIREDNS_USE_IPV6
			if (i6 < FDNS_MAX) {
				if (firedns_aton6_s(buf,&addr6) != NULL) {
					memcpy(&servers6[i6++],&addr6,sizeof(struct in6_addr));
					continue;
				}
			}
#endif
			if (i4 < FDNS_MAX) {
				if (firedns_aton4_s(buf,&addr4) != NULL)
					memcpy(&servers4[i4++],&addr4,sizeof(struct in_addr));
			}
		}
	}
	fclose(f);

}

static int firedns_send_requests(const struct s_header *  const h, const struct s_connection *  const s, const int l) { /* send DNS query */
	int i;
	struct sockaddr_in addr4;
#ifdef FIREDNS_USE_IPV6
	struct sockaddr_in6 addr6;
	/* if we've got ipv6 support, an ip v6 socket, and ipv6 servers, send to them */
	if (i6 > 0 && s->v6 == 1) {
		for (i = 0; i < i6; i++) {
			memset(&addr6,0,sizeof(addr6));
			memcpy(&addr6.sin6_addr,&servers6[i],sizeof(addr6.sin6_addr));
			addr6.sin6_family = AF_INET6;
			addr6.sin6_port = htons(FDNS_PORT);
			sendto(s->fd, h, l + 12, 0, (struct sockaddr *) &addr6, sizeof(addr6));
		}
	}
#endif

	for (i = 0; i < i4; i++) {
#ifdef FIREDNS_USE_IPV6
		/* send via ipv4-over-ipv6 if we've got an ipv6 socket */
		if (s->v6 == 1) {
			memset(&addr6,0,sizeof(addr6));
			memcpy(addr6.sin6_addr.s6_addr,"\0\0\0\0\0\0\0\0\0\0\xff\xff",12);
			memcpy(&addr6.sin6_addr.s6_addr[12],&servers4[i].s_addr,4);
			addr6.sin6_family = AF_INET6;
			addr6.sin6_port = htons(FDNS_PORT);
			sendto(s->fd, h, l + 12, 0, (struct sockaddr *) &addr6, sizeof(addr6));
			continue;
		}
#endif
		/* otherwise send via standard ipv4 boringness */
		memset(&addr4,0,sizeof(addr4));
		memcpy(&addr4.sin_addr,&servers4[i],sizeof(addr4.sin_addr));
		addr4.sin_family = AF_INET;
		addr4.sin_port = htons(FDNS_PORT);
		sendto(s->fd, h, l + 12, 0, (struct sockaddr *) &addr4, sizeof(addr4));
	}

	return 0;
}

static struct s_connection *firedns_add_query(struct s_header *  const h) { /* build DNS query, add to list */
	struct s_connection *  s;

	/* set header flags */
	h->id[0] = rand() % 255; /* verified by firedns_getresult_s() */
	h->id[1] = rand() % 255;
	h->flags1 = 0 | FLAGS1_MASK_RD;
	h->flags2 = 0;
	h->qdcount = htons(1);
	h->ancount = htons(0);
	h->nscount = htons(0);
	h->arcount = htons(0);

	/* create new connection object, add to linked list */
	s = firestring_malloc(sizeof(struct s_connection));
	pthread_mutex_lock(&connlist_lock);
	s->next = connection_head;
	connection_head = s;

	/* needed for security later */
	memcpy(s->id,h->id,2);

	/* try to create ipv6 or ipv4 socket */
#ifdef FIREDNS_USE_IPV6
	s->v6 = 0;
	if (i6 > 0) {
		s->fd = socket(PF_INET6, SOCK_DGRAM, 0);
		if (s->fd != -1) {
			if (fcntl(s->fd, F_SETFL, O_NONBLOCK) != 0) {
				close(s->fd);
				s->fd = -1;
			}
		}
		if (s->fd != -1) {
			struct sockaddr_in6 addr6;
			memset(&addr6,0,sizeof(addr6));
			addr6.sin6_family = AF_INET6;
			if (bind(s->fd,(struct sockaddr *)&addr6,sizeof(addr6)) == 0)
				s->v6 = 1;
			else
				close(s->fd);
		}
	}
	if (s->v6 == 0) {
#endif
		s->fd = socket(PF_INET, SOCK_DGRAM, 0);
		if (s->fd != -1) {
			if (fcntl(s->fd, F_SETFL, O_NONBLOCK) != 0) {
				close(s->fd);
				s->fd = -1;
			}
		}
		if (s->fd != -1) {
			struct sockaddr_in addr;
			memset(&addr,0,sizeof(addr));
			addr.sin_family = AF_INET;
			addr.sin_port = 0;
			addr.sin_addr.s_addr = INADDR_ANY;
			if (bind(s->fd,(struct sockaddr *)&addr,sizeof(addr)) != 0) {
				close(s->fd);
				s->fd = -1;
			}
		}
		if (s->fd == -1) {
			connection_head = s->next;
			pthread_mutex_unlock(&connlist_lock);
			free(s);
			return NULL;
		}
#ifdef FIREDNS_USE_IPV6
	}
#endif
	if (wantclose == 1) {
		close(lastcreate);
		wantclose = 0;
	}
	lastcreate = s->fd;
	pthread_mutex_unlock(&connlist_lock);
	return s;
}

static int firedns_build_query_payload(const char * const name, const unsigned short rr, const unsigned short class, unsigned char * const payload) { /* populate payload with query: name= question, rr= record type */
	short payloadpos;
	const char * tempchr, * tempchr2;
	unsigned short l;
	
	payloadpos = 0;
	tempchr2 = name;

	/* split name up into labels, create query */
	while ((tempchr = strchr(tempchr2,'.')) != NULL) {
		l = tempchr - tempchr2;
		if (payloadpos + l + 1 > 507)
			return -1;
		payload[payloadpos++] = l;
		memcpy(&payload[payloadpos],tempchr2,l);
		payloadpos += l;
		tempchr2 = &tempchr[1];
	}
	l = strlen(tempchr2);
	if (l) {
		if (payloadpos + l + 2 > 507)
			return -1;
		payload[payloadpos++] = l;
		memcpy(&payload[payloadpos],tempchr2,l);
		payloadpos += l;
		payload[payloadpos++] = '\0';
	}
	if (payloadpos > 508)
		return -1;
	l = htons(rr);
	memcpy(&payload[payloadpos],&l,2);
	l = htons(class);
	memcpy(&payload[payloadpos + 2],&l,2);
	return payloadpos + 4;
}

struct in_addr *firedns_aton4(const char * const ipstring) { /* ascii to numeric: convert string to static 4part IP addr struct */
	static struct in_addr ip;
	return firedns_aton4_s(ipstring,&ip);
}

struct in_addr *firedns_aton4_r(const char *  const ipstring) { /* ascii to numeric (reentrant): convert string to new 4part IP addr struct */
	struct in_addr *  ip;
	ip = firestring_malloc(sizeof(struct in_addr));
	return firedns_aton4_s(ipstring,ip);
}

struct in_addr *firedns_aton4_s(const char *  const ipstring, struct in_addr *  const ip) { /* ascii to numeric (buffered): convert string to given 4part IP addr struct */
	unsigned char *myip;
	int i,part = 0;
	myip = (unsigned char *)ip;

	memset(myip,'\0',4);
	for (i = 0; i < 16; i++) {
		switch (ipstring[i]) {
			case '\0':
				if (part != 3)
					return NULL;
				return ip;
				break;
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				if (myip[part] > 25)
					return NULL;
				myip[part] *= 10;
				if (myip[part] == 250 && ipstring[i] - '0' > 6)
					return NULL;
				myip[part] += ipstring[i] - '0';
				break;
			case '.':
				if (part == 3)
					return ip;
				else
					part++;
				break;
			default:
				if (part == 3)
					return ip;
				else
					return NULL;
				break;
		}
	}
	if (part == 3)
		return ip;
	else
		return NULL;
}

struct in6_addr *firedns_aton6(const char * const ipstring) {
	static struct in6_addr ip;
	return firedns_aton6_s(ipstring,&ip);
}

struct in6_addr *firedns_aton6_r(const char *  const ipstring) {
	struct in6_addr *  ip;
	ip = firestring_malloc(sizeof(struct in6_addr));
	return firedns_aton6_s(ipstring,ip);
}

struct in6_addr *firedns_aton6_s(const char *  const ipstring, struct in6_addr *  const ip) {
	/* black magic */
	char instring[40];
	char tempstr[5];
	int i,o;
	int direction = 1;
	char *tempchr,*tempchr2;;

	i = strlen(ipstring);
	if (i > 39)
		return NULL;
	memcpy(instring,ipstring,i+1);

	memset(ip->s6_addr,'\0',16);

	tempchr2 = instring;
	i = 0;
	while (direction > 0) {
		if (direction == 1) {
			tempchr = strchr(tempchr2,':');
			if (tempchr == NULL && i != 14)
				return NULL;
			if (tempchr != NULL)
				tempchr[0] = '\0';
			o = strlen(tempchr2);
			if (o > 4)
				return NULL;
			strcpy(tempstr,"0000");
			strcpy(&tempstr[4 - o],tempchr2);
			o = firestring_hextoi(tempstr);
			if (o == -1)
				return NULL;
			ip->s6_addr[i++] = o;
			o = firestring_hextoi(&tempstr[2]);
			if (o == -1)
				return NULL;
			ip->s6_addr[i++] = o;
			if (i >= 15)
				break;
			tempchr2 = tempchr + 1;
			if (tempchr2[0] == ':') {
				tempchr2++;
				direction = 2;
				i = 15;
				continue;
			}
		}
		if (direction == 2) {
			tempchr = strrchr(tempchr2,':');
			if (tempchr == NULL)
				tempchr = tempchr2;
			else {
				tempchr[0] = '\0';
				tempchr++;
			}
			o = strlen(tempchr);
			if (o > 4)
				return NULL;
			strcpy(tempstr,"0000");
			strcpy(&tempstr[4 - o],tempchr);
			o = firestring_hextoi(&tempstr[2]);
			if (o == -1)
				return NULL;
			ip->s6_addr[i--] = o;
			o = firestring_hextoi(tempstr);
			if (o == -1)
				return NULL;
			ip->s6_addr[i--] = o;
			if (i <= 1)
				break;
			if (tempchr == tempchr2)
				break;
		}
	}
	return ip;
}

int firedns_getip4(const char *  const name) { /* build, add and send A query; retrieve result with firedns_getresult() */
	struct s_header h;
	struct s_connection *  s;
	int l;

	firedns_init();
	

	l = firedns_build_query_payload(name,FDNS_QRY_A,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = FDNS_QRY_A;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_getip6(const char *  const name) {
	struct s_header h;
	struct s_connection *  s;
	int l;

	firedns_init();

	l = firedns_build_query_payload(name,FDNS_QRY_AAAA,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = FDNS_QRY_AAAA;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_gettxt(const char *  const name) { /* build, add and send TXT query; retrieve result with firedns_getresult() */
	struct s_header h;
	struct s_connection *  s;
	int l;

	firedns_init();

	l = firedns_build_query_payload(name,FDNS_QRY_TXT,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = FDNS_QRY_TXT;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_getmx(const char *  const name) { /* build, add and send MX query; retrieve result with firedns_getresult() */
	struct s_header h;
	struct s_connection *  s;
	int l;

	firedns_init();

	l = firedns_build_query_payload(name,FDNS_QRY_MX,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = FDNS_QRY_MX;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_getname4(const struct in_addr *  const ip) { /* build, add and send PTR query; retrieve result with firedns_getresult() */
	char query[512];
	struct s_header h;
	struct s_connection *  s;
	unsigned char *c;
	int l;

	firedns_init();

	c = (unsigned char *)&ip->s_addr;

	sprintf(query,"%d.%d.%d.%d.in-addr.arpa",c[3],c[2],c[1],c[0]);

	l = firedns_build_query_payload(query,FDNS_QRY_PTR,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = FDNS_QRY_PTR;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_getname6(const struct in6_addr *  const ip) {
	char query[512];
	struct s_header h;
	struct s_connection *  s;
	int l;

	firedns_init();

	sprintf(query,"%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.%0x.ip6.int",
			ip->s6_addr[15] & 0x0f,
			(ip->s6_addr[15] & 0xf0) >> 4,
			ip->s6_addr[14] & 0x0f,
			(ip->s6_addr[14] & 0xf0) >> 4,
			ip->s6_addr[13] & 0x0f,
			(ip->s6_addr[13] & 0xf0) >> 4,
			ip->s6_addr[12] & 0x0f,
			(ip->s6_addr[12] & 0xf0) >> 4,
			ip->s6_addr[11] & 0x0f,
			(ip->s6_addr[11] & 0xf0) >> 4,
			ip->s6_addr[10] & 0x0f,
			(ip->s6_addr[10] & 0xf0) >> 4,
			ip->s6_addr[9] & 0x0f,
			(ip->s6_addr[9] & 0xf0) >> 4,
			ip->s6_addr[8] & 0x0f,
			(ip->s6_addr[8] & 0xf0) >> 4,
			ip->s6_addr[7] & 0x0f,
			(ip->s6_addr[7] & 0xf0) >> 4,
			ip->s6_addr[6] & 0x0f,
			(ip->s6_addr[6] & 0xf0) >> 4,
			ip->s6_addr[5] & 0x0f,
			(ip->s6_addr[5] & 0xf0) >> 4,
			ip->s6_addr[4] & 0x0f,
			(ip->s6_addr[4] & 0xf0) >> 4,
			ip->s6_addr[3] & 0x0f,
			(ip->s6_addr[3] & 0xf0) >> 4,
			ip->s6_addr[2] & 0x0f,
			(ip->s6_addr[2] & 0xf0) >> 4,
			ip->s6_addr[1] & 0x0f,
			(ip->s6_addr[1] & 0xf0) >> 4,
			ip->s6_addr[0] & 0x0f,
			(ip->s6_addr[0] & 0xf0) >> 4
			);

	l = firedns_build_query_payload(query,12,1,(unsigned char *)&h.payload);
	if (l == -1)
		return -1;
	s = firedns_add_query(&h);
	if (s == NULL)
		return -1;
	s->class = 1;
	s->type = 12;
	if (firedns_send_requests(&h,s,l) == -1)
		return -1;

	return s->fd;
}

int firedns_dnsbl_lookup_a(const struct in_addr *  const ip, const char *  const name) { /* build, add and send A query to given DNSBL list; retrieve result with firedns_getresult() */
	char hostname[256];
	firestring_snprintf(hostname,256,"%u.%u.%u.%u.%s",(unsigned int) ((unsigned char *)&ip->s_addr)[3],(unsigned int) ((unsigned char *)&ip->s_addr)[2],(unsigned int) ((unsigned char *)&ip->s_addr)[1],(unsigned int) ((unsigned char *)&ip->s_addr)[0],name);
	return firedns_getip4(hostname);
}

int firedns_dnsbl_lookup_txt(const struct in_addr *  const ip, const char *  const name) { /* build, add and send TXT query to given DNSBL list; retrieve result with firedns_getresult() */
	char hostname[256];
	firestring_snprintf(hostname,256,"%u.%u.%u.%u.%s",(unsigned int) ((unsigned char *)&ip->s_addr)[3],(unsigned int) ((unsigned char *)&ip->s_addr)[2],(unsigned int) ((unsigned char *)&ip->s_addr)[1],(unsigned int) ((unsigned char *)&ip->s_addr)[0],name);
	return firedns_gettxt(hostname);
}

char *firedns_ntoa4(const struct in_addr * const ip) { /* numeric to ascii: convert 4part IP addr struct to static string */
	static char result[256];
	return firedns_ntoa4_s(ip,result);
}

char *firedns_ntoa4_r(const struct in_addr *  const ip) { /* numeric to ascii (reentrant): convert 4part IP addr struct to new string */
	char *  result;
	result = firestring_malloc(256);
	return firedns_ntoa4_s(ip,result);
}

char *firedns_ntoa4_s(const struct in_addr *  const ip, char *  const result) { /* numeric to ascii (buffered): convert 4part IP addr struct to given string */
	unsigned char *m;
	m = (unsigned char *)&ip->s_addr;
	sprintf(result,"%d.%d.%d.%d",m[0],m[1],m[2],m[3]);
	return result;
}

char *firedns_ntoa6(const struct in6_addr *ip) {
	static char result[256];
	return firedns_ntoa6_s(ip,result);
}

char *firedns_ntoa6_r(const struct in6_addr *  ip) {
	char *  result;
	result = firestring_malloc(256);
	return firedns_ntoa6_s(ip,result);
}

char *firedns_ntoa6_s(const struct in6_addr *  const ip, char *  const result) {
	sprintf(result,"%x:%x:%x:%x:%x:%x:%x:%x",
			ntohs(*((unsigned short *)&ip->s6_addr[0])),
			ntohs(*((unsigned short *)&ip->s6_addr[2])),
			ntohs(*((unsigned short *)&ip->s6_addr[4])),
			ntohs(*((unsigned short *)&ip->s6_addr[6])),
			ntohs(*((unsigned short *)&ip->s6_addr[8])),
			ntohs(*((unsigned short *)&ip->s6_addr[10])),
			ntohs(*((unsigned short *)&ip->s6_addr[12])),
			ntohs(*((unsigned short *)&ip->s6_addr[14])));
	return result;
}

char *firedns_getresult(const int fd) { /* retrieve result of DNS query */
	static char result[1024];
	return firedns_getresult_s(fd,result);
}

char *firedns_getresult_r(const int fd) { /* retrieve result of DNS query (reentrant) */
	char *result;
	result = firestring_malloc(1024);
	return firedns_getresult_s(fd,result);
}

char *firedns_getresult_s(const int fd, char *  const result) { /* retrieve result of DNS query (buffered) */
	struct s_header h;
	struct s_connection *  c, *prev;
	int l,i,q,curanswer,o;
	struct s_rr_middle *  rr, rrbacking;
	char *src, *  dst;
	int bytes;
	unsigned short p;

	prev = NULL;
	pthread_mutex_lock(&connlist_lock);
	c = connection_head;
	while (c != NULL) { /* find query in list of open queries */
		if (c->fd == fd)
			break;
		prev = c;
		c = c->next;
	}
	if (c == NULL) {
		pthread_mutex_unlock(&connlist_lock);
		return NULL; /* query not found */
	}
	/* query found-- pull from list: */
	if (prev != NULL)
		prev->next = c->next;
	else
		connection_head = c->next;
	pthread_mutex_unlock(&connlist_lock);

	l = recv(c->fd,&h,sizeof(struct s_header),0);
	firedns_close(c->fd);
	if (l < 12) {
		free(c);
		return NULL;
	}
	if (c->id[0] != h.id[0] || c->id[1] != h.id[1]) {
		free(c);
		return NULL; /* ID mismatch */
	}
	if ((h.flags1 & FLAGS1_MASK_QR) == 0) {
		free(c);
		return NULL;
	}
	if ((h.flags1 & FLAGS1_MASK_OPCODE) != 0) {
		free(c);
		return NULL;
	}
	if ((h.flags2 & FLAGS2_MASK_RCODE) != 0) {
		free(c);
		return NULL;
	}
	h.ancount = ntohs(h.ancount);
	if (h.ancount < 1)  { /* no sense going on if we don't have any answers */
		free(c);
		return NULL;
	}
	/* skip queries */
	i = 0;
	q = 0;
	l -= 12;
	h.qdcount = ntohs(h.qdcount);
	while (q < h.qdcount && i < l) {
		if (h.payload[i] > 63) { /* pointer */
			i += 6; /* skip pointer, class and type */
			q++;
		} else { /* label */
			if (h.payload[i] == 0) {
				q++;
				i += 5; /* skip nil, class and type */
			} else
				i += h.payload[i] + 1; /* skip length and label */
		}
	}
	/* &h.payload[i] should now be the start of the first response */
	curanswer = 0;
	while (curanswer < h.ancount) {
		q = 0;
		while (q == 0 && i < l) {
			if (h.payload[i] > 63) { /* pointer */
				i += 2; /* skip pointer */
				q = 1;
			} else { /* label */
				if (h.payload[i] == 0) {
					i++;
					q = 1;
				} else
					i += h.payload[i] + 1; /* skip length and label */
			}
		}
		if (l - i < 10) {
			free(c);
			return NULL;
		}
		rr = (struct s_rr_middle *)&h.payload[i];
		src = (char *) rr;
		dst = (char *) &rrbacking;
		for (bytes = sizeof(rrbacking); bytes; bytes--)
			*dst++ = *src++;
		rr = &rrbacking;
		i += 10;
		rr->rdlength = ntohs(rr->rdlength);
		if (ntohs(rr->type) != c->type) {
			curanswer++;
			i += rr->rdlength;
			continue;
		}
		if (ntohs(rr->class) != c->class) {
			curanswer++;
			i += rr->rdlength;
			continue;
		}
		break;
	}
	free(c);
	if (curanswer == h.ancount)
		return NULL;
	if (i + rr->rdlength > l)
		return NULL;
	if (rr->rdlength > 1023)
		return NULL;

	switch (ntohs(rr->type)) {
		case FDNS_QRY_PTR:
			o = 0;
			q = 0;
			while (q == 0 && i < l && o + 256 < 1023) {
				if (h.payload[i] > 63) { /* pointer */
					memcpy(&p,&h.payload[i],2);
					i = ntohs(p) - FIREDNS_POINTER_VALUE - 12;
				} else { /* label */
					if (h.payload[i] == 0)
						q = 1;
					else {
						result[o] = '\0';
						if (o != 0)
							result[o++] = '.';
						memcpy(&result[o],&h.payload[i + 1],h.payload[i]);
						o += h.payload[i];
						i += h.payload[i] + 1;
					}
				}
			}
			result[o] = '\0';
			break;
		case FDNS_QRY_MX:
			i += 2;
			o = 0;
			q = 0;
			while (q == 0 && i < l && o + 256 < 1023) {
				if (h.payload[i] > 63) { /* pointer */
					memcpy(&p,&h.payload[i],2);
					i = ntohs(p) - FIREDNS_POINTER_VALUE - 12;
				} else { /* label */
					if (h.payload[i] == 0)
						q = 1;
					else {
						result[o] = '\0';
						if (o != 0)
							result[o++] = '.';
						memcpy(&result[o],&h.payload[i + 1],h.payload[i]);
						o += h.payload[i];
						i += h.payload[i] + 1;
					}
				}
			}
			result[o] = '\0';
			break;
		case FDNS_QRY_TXT:
			memcpy(result,&h.payload[i + 1],h.payload[i]);
			result[h.payload[i]] = '\0';
			break;
		default:
			memcpy(result,&h.payload[i],rr->rdlength);
			result[rr->rdlength] = '\0';
			break;
	}
	return result;
}

static inline struct in_addr *firedns_resolveip4_i(const char *  const name, char *(* const result)(int)) { /* immediate A query */
	int fd;
	int t,i;
	struct in_addr *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_getip4(name);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = (struct in_addr *) result(fd);
		if (ret != NULL || i != 0)
			return ret;
	}
	return NULL;
}

struct in_addr *firedns_resolveip4(const char * const name) { /* immediate A query */
	return firedns_resolveip4_i(name,firedns_getresult);
}

struct in_addr *firedns_resolveip4_r(const char * const name) { /* immediate A query (reentrant) */
	return firedns_resolveip4_i(name,firedns_getresult_r);
}

static inline struct in6_addr *firedns_resolveip6_i(const char *  const name, char *(* const result)(int)) {
	int fd;
	int t,i;
	struct in6_addr *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_getip6(name);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = (struct in6_addr *) result(fd);
		if (ret != NULL || i != 0)
			return ret;
	}
	return NULL;
}

struct in6_addr *firedns_resolveip6(const char * const name) {
	return firedns_resolveip6_i(name,firedns_getresult);
}

struct in6_addr *firedns_resolevip6_r(const char * const name) {
	return firedns_resolveip6_i(name,firedns_getresult_r);
}

static inline char *firedns_resolvetxt_i(const char *  const name, char *(* const result)(int)) {
	int fd;
	int t,i;
	char *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_gettxt(name);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = result(fd);
		if (ret != NULL || i != 0)
			return ret;
	}
	return NULL;
}

char *firedns_resolvetxt(const char * const name) { /* immediate TXT query */
	return firedns_resolvetxt_i(name,firedns_getresult);
}

char *firedns_resolvetxt_r(const char * const name) {
	return firedns_resolvetxt_i(name,firedns_getresult_r);
}

static inline char *firedns_resolvemx_i(const char *  const name, char *(* const result)(int)) {
	int fd;
	int t,i;
	char *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_getmx(name);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = result(fd);
		if (ret != NULL || i != 0)
			return ret;

	}
	return NULL;
}

char *firedns_resolvemx(const char * const name) { /* immediate MX query */
	return firedns_resolvemx_i(name,firedns_getresult);
}

char *firedns_resolvemx_r(const char * const name) {
	return firedns_resolvemx_i(name,firedns_getresult_r);
}

static inline char *firedns_resolvename4_i(const struct in_addr *  const ip, char *(* const result)(int)) {
	int fd;
	int t,i;
	char *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_getname4(ip);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = result(fd);
		if (ret != NULL || i != 0)
			return ret;
	}
	return NULL;
}

char *firedns_resolvename4(const struct in_addr * const ip) { /* immediate PTR query */
	return firedns_resolvename4_i(ip,firedns_getresult);
}

char *firedns_resolvename4_r(const struct in_addr * const ip) {
	return firedns_resolvename4_i(ip,firedns_getresult_r);
}

static inline char *firedns_resolvename6_i(const struct in6_addr *  const ip, char *(* const result)(int)) {
	int fd;
	int t,i;
	char *  ret;
	fd_set s;
	struct timeval tv;

	for (t = 0; t < FIREDNS_TRIES; t++) {
		fd = firedns_getname6(ip);
		if (fd == -1)
			return NULL;
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		FD_ZERO(&s);
		FD_SET(fd,&s);
		i = select(fd + 1,&s,NULL,NULL,&tv);
		ret = result(fd);
		if (ret != NULL || i != 0)
			return ret;
	}
	return NULL;
}

char *firedns_resolvename6(const struct in6_addr * const ip) {
	return firedns_resolvename6_i(ip,firedns_getresult);
}

char *firedns_resolvename6_r(const struct in6_addr * const ip) {
	return firedns_resolvename6_i(ip,firedns_getresult_r);
}
