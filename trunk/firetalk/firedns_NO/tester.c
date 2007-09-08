#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include "firedns.h"
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


void do_firedns_aton4(char * string) {
	struct in_addr *inaddr4;

	fprintf(stderr,"taking firedns_aton4(%s): ",string);
	inaddr4 = firedns_aton4(string);
	if (inaddr4 == NULL)
		fprintf(stderr,"got NULL\n");
	else
		fprintf(stderr,"%d.%d.%d.%d\n",((char *)&inaddr4->s_addr)[0],
				((char *)&inaddr4->s_addr)[1],
				((char *)&inaddr4->s_addr)[2],
				((char *)&inaddr4->s_addr)[3]);
}

void do_firedns_getip4(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;
	struct in_addr addr4;

	fprintf(stderr,"taking firedns_getip4(%s): ",string);
	fd = firedns_getip4(string);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	if (m == NULL)
		fprintf(stderr,"getting result: (null)\n");
	else {
		memcpy(&addr4,m,sizeof(struct in_addr));
		fprintf(stderr,"getting result: %s\n",firedns_ntoa4(&addr4));
	}
}

void do_firedns_getip6(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;
	struct in6_addr addr6;

	fprintf(stderr,"taking firedns_getip6(%s): ",string);
	fd = firedns_getip6(string);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	if (m == NULL)
		fprintf(stderr,"getting result: (null)\n");
	else {
		memcpy(&addr6,m,sizeof(struct in6_addr));
		fprintf(stderr,"getting result: %s\n",firedns_ntoa6(&addr6));
	}
}

void do_firedns_gettxt(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;

	fprintf(stderr,"taking firedns_gettxt(%s): ",string);
	fd = firedns_gettxt(string);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	fprintf(stderr,"getting result: %s\n",m);
}

void do_firedns_getmx(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;

	fprintf(stderr,"taking firedns_getmx(%s): ",string);
	fd = firedns_getmx(string);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	fprintf(stderr,"getting result: %s\n",m);
}

void do_firedns_getname4(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;
	struct in_addr *addr4;

	fprintf(stderr,"taking firedns_getname4(%s): ",string);
	addr4 = firedns_aton4(string);
	if (addr4 == NULL) {
		fprintf(stderr,"(null)\n");
		return;
	}
	fd = firedns_getname4(addr4);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	fprintf(stderr,"getting result: %s\n",m);
}

void do_firedns_getname6(char * string) {
	int fd;
	fd_set s;
	int n;
	struct timeval tv;
	char *m;
	struct in6_addr *addr6;

	fprintf(stderr,"taking firedns_getname6(%s): ",string);
	addr6 = firedns_aton6(string);
	if (addr6 == NULL) {
		fprintf(stderr,"(null)\n");
		return;
	}
	fd = firedns_getname6(addr6);
	fprintf(stderr,"%d\n",fd);
	if (fd == -1)
		return;
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	FD_ZERO(&s);
	FD_SET(fd,&s);
	n = select(fd + 1,&s,NULL,NULL,&tv);
	m = firedns_getresult(fd);
	fprintf(stderr,"getting result: %s\n",m);
}

void do_firedns_aton6(char * string) {
	struct in6_addr *inaddr6;

	fprintf(stderr,"taking firedns_aton6(%s): ",string);
	inaddr6 = firedns_aton6(string);
	if (inaddr6 == NULL)
		fprintf(stderr,"got NULL\n");
	else
		fprintf(stderr,"%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x:%02x%02x\n",
				inaddr6->s6_addr[0],
				inaddr6->s6_addr[1],
				inaddr6->s6_addr[2],
				inaddr6->s6_addr[3],
				inaddr6->s6_addr[4],
				inaddr6->s6_addr[5],
				inaddr6->s6_addr[6],
				inaddr6->s6_addr[7],
				inaddr6->s6_addr[8],
				inaddr6->s6_addr[9],
				inaddr6->s6_addr[10],
				inaddr6->s6_addr[11],
				inaddr6->s6_addr[12],
				inaddr6->s6_addr[13],
				inaddr6->s6_addr[14],
				inaddr6->s6_addr[15]);
}

void do_firedns_gethostbyname(char * string) {
	struct hostent *h;
	struct in_addr a;
	fprintf(stderr,"taking gethostbyname(%s): ",string);
	h = gethostbyname(string);
	if (h == NULL)
		fprintf(stderr,"(null)\n");
	else {
		memcpy(&a,h->h_addr_list[0],sizeof(struct in_addr));
		fprintf(stderr,"%s\n",inet_ntoa(a));
	}
}

void do_firedns_gethostbyaddr(char * string) {
	struct hostent *h;
	struct in_addr a;
	fprintf(stderr,"taking gethostbyaddr(%s): ",string);
	inet_aton(string,&a);
	h = gethostbyaddr(&a,sizeof(struct in_addr),AF_INET);
	fprintf(stderr,"%s\n",h->h_name);
}

int main() {
	do_firedns_aton4("1.2.3.4");
	do_firedns_aton4("101.102.103.104");
	do_firedns_aton4("bah");
	do_firedns_aton4("1.2.3.400");

	do_firedns_aton6("::");
	do_firedns_aton6("3ffe:b80:346:1:204:5aff:fece:7852");
	do_firedns_aton6("fe80::204:5aff:fece:7852");
	do_firedns_aton6("bah");

	do_firedns_getip4("host.taconic.net");
	do_firedns_getip4("celery.n.ml.org");
	do_firedns_getip4("incandescent.mp3revolution.net");
	do_firedns_getip4("dharr.stu.rpi.edu");
	do_firedns_getip4("ftp.us.kernel.org");

	do_firedns_getip6("ftp.stealth.net");
	do_firedns_getip6("www.ipv6.org");
	do_firedns_getip6("z.ip6.int");

	do_firedns_gettxt("2.0.0.127.inputs.orbz.org");
	do_firedns_gettxt("2.0.0.127.outputs.orbz.org");
	do_firedns_gettxt("2.0.0.127.bl.spamcop.net");
	do_firedns_gettxt("2.0.0.127.relays.ordb.org");

	do_firedns_getmx("spamcop.net");
	do_firedns_getmx("penguinhosting.net");
	do_firedns_getmx("taconic.net");
	do_firedns_getmx("microsoft.com");

	do_firedns_getname4("205.231.144.10");
	do_firedns_getname4("208.171.237.190");
	do_firedns_getname4("64.28.67.150");

	do_firedns_getname6("3FFE:0:1:0:0:0:C620:242");
	do_firedns_getname6("2001:660:1180:1:192:134:0:49");
	do_firedns_getname6("3FFE:50E:0:0:0:0:0:1");

	do_firedns_gethostbyname("www.slashdot.org");
	do_firedns_gethostbyname("host.taconic.net");

	do_firedns_gethostbyaddr("205.231.144.10");

	return 0;
}
