/*
toc.c - FireTalk TOC shared definitions
Copyright (C) 2000 Ian Gulliver

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
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

typedef struct s_toc_connection * client_t;
#define _HAVE_CLIENT_T

#include "firetalk-int.h"
#include "firetalk.h"
#include "toc.h"
#include "aim.h"
#include "safestring.h"

int toc_send_printf(client_t c, int urgent, const char * const format, ...) {
	va_list ap;
	size_t len;
	size_t i;
	char data[2048];
	char tempnum[64];
	short datai;
	char *tempchr;
	unsigned short length;
	struct s_firetalk_handle *fchandle;

	fchandle = firetalk_find_handle(c);

	va_start(ap,format);
	datai = TOC_HEADER_LENGTH;

	len = strlen(format);
	for (i = 0; i < len; i++) {
		if (format[i] == '%') {
			switch (format[++i]) {
				case 's':
					tempchr = va_arg(ap, char *);
					tempchr = toc_quote(tempchr,1);
					if (!tempchr || (datai + strlen(tempchr) > 2046))
						return FE_PACKETSIZE;
					safe_strncpy(&data[datai],tempchr,(size_t) 2048-datai);
					datai += strlen(tempchr);
					break;
				case 'd':
					safe_snprintf(tempnum,50,"%d",va_arg(ap,int));
					safe_strncpy(&data[datai],tempnum,(size_t) 2048-datai);
					datai += strlen(tempnum);
					break;
				case 'l':
					safe_snprintf(tempnum,50,"%l",va_arg(ap, long));
					safe_strncpy(&data[datai],tempnum,(size_t) 2048-datai);
					datai += strlen(tempnum);
					break;
				case 'u':
					safe_snprintf(tempnum,50,"%u",va_arg(ap, unsigned int));
					safe_strncpy(&data[datai],tempnum,(size_t) 2048-datai);
					datai += strlen(tempnum);
					break;
				case 'y':
					safe_snprintf(tempnum,50,"%y",va_arg(ap, unsigned long));
					safe_strncpy(&data[datai],tempnum,(size_t) 2048-datai);
					datai += strlen(tempnum);
					break;
				case '%':
					data[datai++] = '%';
					break;
			}
		} else {
			data[datai++] = format[i];
			if (datai > 2046)
				return FE_PACKETSIZE;
		}
	}
	data[datai++] = '\0';

	length = toc_fill_header((unsigned char *)data,SFLAP_FRAME_DATA,datai - TOC_HEADER_LENGTH);

	firetalk_internal_send_data(fchandle,data,length,urgent);
	return FE_SUCCESS;
}

char *toc_quote(const char * const string, const int outside_flag) {
	static char output[2048];
	size_t length;
	size_t counter;
	int newcounter;

	length = strlen(string);
	if (outside_flag == 1) {
 		newcounter = 1;
		output[0] = '"';
	} else
		newcounter = 0;

	for (counter = 0; counter < length; counter++) {
		if (string[counter] == '$' || string[counter] == '{' || string[counter] == '}' || string[counter] == '[' || string[counter] == ']' || string[counter] == '(' || string[counter] == ')' || string[counter] == '\'' || string[counter] == '`' || string[counter] == '"' || string[counter] == '\\') {
			if (newcounter > 2044)
				return NULL;
			output[newcounter++] = '\\';
			output[newcounter++] = string[counter];
		} else {
			if (newcounter > 2045)
				return NULL;
			output[newcounter++] = string[counter];
		}
	}

	if (outside_flag == 1)
		output[newcounter++] = '"';
	output[newcounter] = '\0';

	return output;
}

unsigned short toc_fill_header(unsigned char * const header, unsigned char const frame_type, unsigned short const length) {
	header[0] = '*';            /* byte 0, length 1, magic 42 */
	header[1] = frame_type;     /* byte 1, length 1, frame type (defined above SFLAP_FRAME_* */
	header[4] = length/256;     /* byte 4, length 2, length, network byte order */
	header[5] = (unsigned char) length%256;
	return 6 + length;
}

enum firetalk_error toc_prepare_for_transmit(client_t c, char * const data, const int length) {
	unsigned char *d;
	unsigned long s;
	d = (unsigned char *)data;
	s = ++c->local_sequence;
	if (d[0] == '*' && length >= 6) {
		d[2] = s/256;
		d[3] = (unsigned char) s%256;
	}
	return FE_SUCCESS;
}

char **toc_parse_args(char * const instring, const int maxargs) {
	static char *args[256];
	int curarg;
	char *tempchr;
	char *tempchr2;

	curarg = 0;
	tempchr = instring;

	while (curarg < (maxargs - 1) && curarg < 256 && ((tempchr2 = strchr(tempchr,':')) != NULL)) {
		args[curarg++] = tempchr;
		tempchr2[0] = '\0';
		tempchr = tempchr2 + 1;
	}
	args[curarg++] = tempchr;
	args[curarg] = NULL;
	return args;
}

unsigned short toc_fill_signon(unsigned char * const signon, const char * const username) {
	size_t length;
	length = strlen(username);
	signon[0] = '\0';              /* byte 0, length 4, flap version (1) */
	signon[1] = '\0';
	signon[2] = '\0';
	signon[3] = '\001';
	signon[4] = '\0';              /* byte 4, length 2, tlv tag (1) */
	signon[5] = '\001';
	signon[6] = length/256;     /* byte 6, length 2, username length, network byte order */
	signon[7] = (unsigned char) length%256;
	memcpy(&signon[8],username,length);
	return(length + 8);
}

unsigned char toc_get_frame_type_from_header(const unsigned char * const header) {
	return header[1];
}

unsigned short toc_get_sequence_from_header(const unsigned char * const header) {
	unsigned short sequence;
	sequence = ntohs(* ((unsigned short *)(&header[2])));
	return sequence;
}

unsigned short toc_get_length_from_header(const unsigned char * const header) {
	unsigned short length;
	length = ntohs(* ((unsigned short *)(&header[4])));
	return length;
}

enum firetalk_error toc_free_contents(client_t c) {
	struct s_toc_room *roomiter,*roomiter2;
	struct s_toc_infoget *infoiter,*infoiter2;
	if (c->nickname != NULL) {
		free(c->nickname);
		c->nickname = NULL;
	}
	if (c->lastinfo != NULL) {
		free(c->lastinfo);
		c->lastinfo = NULL;
	}

	roomiter = c->room_head;
	c->room_head = NULL;
	while (roomiter != NULL) {
		roomiter2 = roomiter->next;
		if (roomiter->name != NULL)
			free(roomiter->name);
		if (roomiter->id != NULL)
			free(roomiter->id);
		free(roomiter);
		roomiter = roomiter2;
	}

	infoiter = c->infoget_head;
	c->infoget_head = NULL;
	while (infoiter != NULL) {
		infoiter2 = infoiter->next;
		if (infoiter->sockfd != -1)
			close(infoiter->sockfd);
		free(infoiter);
		infoiter = infoiter2;
	}
	return FE_SUCCESS;
}

enum firetalk_error toc_internal_disconnect(client_t c, const int error) {
	toc_free_contents(c);
	firetalk_callback_disconnect(c,error);
	return FE_SUCCESS;
}

char *toc_hash_password(const char * const password) {
#define HASH "Tic/Toc"
	const char hash[sizeof(HASH)] = HASH;
	static char output[2048];
	size_t counter;
	int newcounter;
	size_t length;

	length = strlen(password);

	output[0] = '0';
	output[1] = 'x';

	newcounter = 2;

	for (counter = 0; counter < length; counter++) {
		if (newcounter > 2044)
			return NULL;
		sprintf(&output[newcounter],"%02x",(unsigned int) password[counter] ^ hash[((counter) % (sizeof(HASH)-1))]);
		newcounter += 2;
	}

	output[newcounter] = '\0';

	return output;
}

int toc_internal_add_room(client_t c, const char * const name, const int exchange) {
	struct s_toc_room *iter;

	iter = c->room_head;
	c->room_head = safe_malloc(sizeof(struct s_toc_room));
	c->room_head->next = iter;
	c->room_head->name = safe_strdup(name);
	c->room_head->id = NULL;
	c->room_head->invited = 0;
	c->room_head->joined = 0;
	c->room_head->exchange = exchange;
	return FE_SUCCESS;
}

int toc_internal_find_exchange(client_t c, const char * const name) {
	struct s_toc_room *iter;

	iter = c->room_head;

	while (iter) {
		if (iter->joined == 0)
			if (aim_compare_nicks(iter->name,name) == 0)
				return iter->exchange;
		iter = iter->next;
	}

	firetalkerror = FE_NOTFOUND;
	return 0;
}

int toc_internal_set_joined(client_t c, const char * const name, const int exchange) {
	struct s_toc_room *iter;

	iter = c->room_head;

	while (iter) {
		if (iter->joined == 0) {
			if ((iter->exchange == exchange) && (aim_compare_nicks(iter->name,name) == 0)) {
				iter->joined = 1;
				return FE_SUCCESS;
			}
		}
		iter = iter->next;
	}
	return FE_NOTFOUND;
}

int toc_internal_set_id(client_t c, const char * const name, const int exchange, const char * const id) {
	struct s_toc_room *iter;

	iter = c->room_head;

	while (iter) {
		if (iter->joined == 0) {
			if ((iter->exchange == exchange) && (aim_compare_nicks(iter->name,name) == 0)) {
				iter->id = safe_strdup(id);
				return FE_SUCCESS;
			}
		}
		iter = iter->next;
	}
	return FE_NOTFOUND;
}

char * toc_internal_find_room_id(client_t c, const char * const name) {
	struct s_toc_room *iter;
	char *namepart;
	int exchange;

	namepart = toc_internal_split_name(name);
	exchange = toc_internal_split_exchange(name);

	iter = c->room_head;

	while (iter) {
		if (iter->exchange == exchange)
			if (aim_compare_nicks(iter->name,namepart) == 0)
				return iter->id;
		iter = iter->next;
	}

	firetalkerror = FE_NOTFOUND;
	return NULL;
}

char * toc_internal_find_room_name(client_t c, const char * const id) {
	struct s_toc_room *iter;
	static char newname[2048];

	iter = c->room_head;

	while (iter) {
		if (aim_compare_nicks(iter->id,id) == 0) {
			safe_snprintf(newname,2048,"%d:%s",iter->exchange,iter->name);
			return newname;
		}
		iter = iter->next;
	}

	firetalkerror = FE_NOTFOUND;
	return NULL;
}

int toc_internal_split_exchange(const char * const string) {
	return atoi(string);
}

char *toc_internal_split_name(const char * const string) {
	return strchr(string,':') + 1;
}

int toc_internal_set_room_invited(client_t c, const char * const name, const int invited) {
	struct s_toc_room *iter;

	iter = c->room_head;

	while (iter) {
		if (aim_compare_nicks(iter->name,name) == 0) {
			iter->invited = invited;
			return FE_SUCCESS;
		}
		iter = iter->next;
	}

	return FE_NOTFOUND;
}

int toc_internal_get_room_invited(client_t c, const char * const name) {
	struct s_toc_room *iter;

	iter = c->room_head;

	while (iter) {
		if (aim_compare_nicks(iter->name,name) == FE_SUCCESS && iter->invited == 1)
			return 1;
		iter = iter->next;
	}

	return 0;
}

int toc_get_tlv_value(char **args, const int startarg, const int type, char *dest, int destlen) {
	int i,o,s,l;
	i = startarg;
	while (args[i]) {
		if (atoi(args[i]) == type) {
			/* got it, now de-base 64 the next block */
			i++;
			o = 0;
			l = (int) strlen(args[i]);
			for (s = 0, o = 0; s <= l - 3 && o + 3 < destlen; s += 4) {
				dest[o++] = (aim_debase64(args[i][s]) << 2) | (aim_debase64(args[i][s+1]) >> 4);
				dest[o++] = (aim_debase64(args[i][s+1]) << 4) | (aim_debase64(args[i][s+2]) >> 2);
				dest[o++] = (aim_debase64(args[i][s+2]) << 6) | aim_debase64(args[i][s+3]);
			}
			return o;
		}
		i += 2;
	}
	return 0;
}

enum firetalk_error toc_find_packet(client_t c, unsigned char * buffer, unsigned short * bufferpos, char * outbuffer, const int frametype, unsigned short *l) {
	unsigned short length;

	if (*bufferpos < TOC_HEADER_LENGTH) /* don't have the whole header yet */
		return FE_NOTFOUND;

	length = toc_get_length_from_header(buffer);
	if (length > (8192 - TOC_HEADER_LENGTH)) {
		toc_internal_disconnect(c,FE_PACKETSIZE);
		return FE_DISCONNECT;
	}

	if (*bufferpos < length + TOC_HEADER_LENGTH) /* don't have the whole packet yet */
		return FE_NOTFOUND;

	if (frametype == SFLAP_FRAME_SIGNON)
		c->remote_sequence = toc_get_sequence_from_header(buffer);
	else {
		if (toc_get_sequence_from_header(buffer) != ++c->remote_sequence) {
			toc_internal_disconnect(c,FE_SEQUENCE);
			return FE_DISCONNECT;
		}
	}

	if (toc_get_frame_type_from_header(buffer) != frametype) {
		/*toc_internal_disconnect(c,FE_FRAMETYPE);
		return FE_DISCONNECT;*/
	}

	memcpy(outbuffer,&buffer[TOC_HEADER_LENGTH],length);
	*bufferpos -= length + TOC_HEADER_LENGTH;
	memmove(buffer,&buffer[TOC_HEADER_LENGTH + length],*bufferpos);
	outbuffer[length] = '\0';
	*l = length;
	return FE_SUCCESS;
}

void toc_infoget_parse(client_t c, struct s_toc_infoget *i) {
	char *tempchr1, *tempchr2, *tempchr3, *tempchr4;
	int tempint, tempint2;
	i->buffer[i->buflen] = '\0';
#define USER_STRING "Username : <B>"
	tempchr1 = strstr(i->buffer,USER_STRING);
	if (!tempchr1) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,c->lastinfo,"Can't find username in info HTML");
		return;
	}
	tempchr1 += sizeof(USER_STRING) - 1;
	tempchr2 = strchr(tempchr1,'<');
	if (!tempchr2) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,c->lastinfo,"Can't find end of username in info HTML");
		return;
	}
	tempchr2[0] = '\0';
	tempchr2++;
#define WARNING_STRING "Warning Level : <B>"
	tempchr3 = strstr(tempchr2,WARNING_STRING);
	if (!tempchr3) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,tempchr1,"Can't find warning level in info HTML");
		return;
	}
	tempchr3[0] = '\0';
	tempint = 0;
	if ((strstr(tempchr2,"free") != NULL) || (strstr(tempchr2,"dt") != NULL))
		tempint |= FF_SUBSTANDARD;
	if (strstr(tempchr2,"aol") != NULL)
		tempint |= FF_NORMAL;
	if (strstr(tempchr2,"admin") != NULL)
		tempint |= FF_ADMIN;
	tempchr3 += sizeof(WARNING_STRING) - 1;
	tempchr2 = strchr(tempchr3,'%');
	if (!tempchr2) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,tempchr1,"Can't find %% in info HTML");
		return;
	}
	tempchr2[0] = '\0';
	tempchr2++;
	tempint2 = atoi(tempchr3);
#define IDLE_STRING "Idle Minutes : <B>" 
	tempchr3 = strstr(tempchr2,IDLE_STRING);
	if (!tempchr3) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,tempchr1,"Can't find idle minutes in info HTML");
		return;
	}
	tempchr3 += sizeof(IDLE_STRING) - 1;
	tempchr2 = strchr(tempchr3,'<');
	if (!tempchr2) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,tempchr1,"Can't find end of idle minutes in info HTML");
		return;
	}
	tempchr2[0] = '\0';
	tempchr2++;
#define INFO_STRING "<hr><br>\n"
#define INFO_END_STRING "<br><hr>"
	tempchr4 = strstr(tempchr2,INFO_STRING);
	if (!tempchr4) {
		firetalk_callback_error(c,FE_INVALIDFORMAT,tempchr1,"Can't find info string in info HTML");
		return;
	}
	tempchr4 += sizeof(INFO_STRING) - 1;
	tempchr2 = strstr(tempchr4,INFO_END_STRING);
	if (!tempchr2) {
		firetalk_callback_gotinfo(c,tempchr1,NULL,tempint2,atoi(tempchr3),tempint);
	} else {
		tempchr2[0] = '\0';
		firetalk_callback_gotinfo(c,tempchr1,aim_handle_ect(c,tempchr1,aim_interpolate_variables(tempchr4,c->nickname),1),tempint2,atoi(tempchr3),tempint);
	}
}

void toc_infoget_remove(client_t c, struct s_toc_infoget *i, char *error) {
	struct s_toc_infoget *m, *m2;
	if (error != NULL)
		firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,error);
	m = c->infoget_head;
	m2 = NULL;
	while (m != NULL) {
		if (m == i) {
			if (m2 == NULL)
				c->infoget_head = m->next;
			else
				m2->next = m->next;
			close(m->sockfd);
			free(m);
			return;
		}
		m2 = m;
		m = m->next;
	}
}

enum firetalk_error toc_preselect(client_t c, fd_set *read, fd_set *write, fd_set *except, int *n) {
	struct s_toc_infoget *i;
	i = c->infoget_head;
	while (i != NULL) {
		if (i->state == TOC_STATE_CONNECTING)
			FD_SET(i->sockfd,write);
		else if (i->state == TOC_STATE_TRANSFERRING)
			FD_SET(i->sockfd,read);
		FD_SET(i->sockfd,read);
		if (i->sockfd >= *n)
			*n = i->sockfd + 1;
		i = i->next;
	}
	return FE_SUCCESS;
}

enum firetalk_error toc_postselect(client_t c, fd_set *read, fd_set *write, fd_set *except) {
	struct s_toc_infoget *i,*i2;
	i = c->infoget_head;
	while (i != NULL) {
		if (FD_ISSET(i->sockfd,except)) {
			toc_infoget_remove(c,i,strerror(errno));
			i = i->next;
			continue;
		}
		if (i->state == TOC_STATE_CONNECTING && FD_ISSET(i->sockfd,write)) {
			int r;
			unsigned int o = sizeof(int);
			if (getsockopt(i->sockfd,SOL_SOCKET,SO_ERROR,&r,&o)) {
				i2 = i->next;
				toc_infoget_remove(c,i,strerror(errno));
				i = i2;
				continue;
			}
			if (r != 0) {
				i2 = i->next;
				toc_infoget_remove(c,i,strerror(r));
				i = i2;
				continue;
			}
			if (send(i->sockfd,i->buffer,i->buflen,0) != i->buflen) {
				i2 = i->next;
				toc_infoget_remove(c,i,strerror(errno));
				i = i2;
				continue;
			}
			i->buflen = 0;
			i->state = TOC_STATE_TRANSFERRING;
		} else if (i->state == TOC_STATE_TRANSFERRING && FD_ISSET(i->sockfd,read)) {
			ssize_t s;
			while (1) {
				s = recv(i->sockfd,&i->buffer[i->buflen],TOC_HTML_MAXLEN - i->buflen - 1,0);
				if (s <= 0)
					break;
				i->buflen += s;
				if (i->buflen == TOC_HTML_MAXLEN - 1) {
					s = -2;
					break;
				}
			}
			if (s == -2) {
				i2 = i->next;
				toc_infoget_remove(c,i,"Too much data");
				i = i2;
				continue;
			}
			if (s == -1) {
				i2 = i->next;
				if (errno != EAGAIN)
					toc_infoget_remove(c,i,strerror(errno));
				i = i2;
				continue;
			}
			if (s == 0) {
				/* finished, parse results here */
				toc_infoget_parse(c,i);
				i2 = i->next;
				toc_infoget_remove(c,i,NULL);
				i = i2;
				continue;
			}

		}
		i = i->next;
	}

	return FE_SUCCESS;
}

char *toc_get_arg0(char * const instring) {
	static char data[8192];
	char *tempchr;

	if (strlen(instring) > 8192) {
		firetalkerror = FE_PACKETSIZE;
		return NULL;
	}

	safe_strncpy(data,instring,8192);
	tempchr = strchr(data,':');
	if (tempchr)
		tempchr[0] = '\0';
	return data;
}

client_t toc_create_handle() {
	client_t c;

	c = safe_malloc(sizeof(struct s_toc_connection));

	c->nickname = NULL;
	c->room_head = NULL;
	c->infoget_head = NULL;
	c->lasttalk = time(NULL);
	c->lastidle = 0;
	c->lastinfo = NULL;
	c->passchange = 0;
	c->local_sequence = 0;
	c->lastsend = 0;
	c->remote_sequence = 0;
	c->online = 0;

	return c;
}

void toc_destroy_handle(client_t c) {
	toc_free_contents(c);
	free(c);
}

enum firetalk_error toc_disconnect(client_t c) {
	return toc_internal_disconnect(c,FE_USERDISCONNECT);
}

enum firetalk_error toc_signon(client_t c, const char * const username) {
	struct s_firetalk_handle *conn;

	/* fill & send the flap signon packet */

	conn = firetalk_find_handle(c);

	c->lasttalk = time(NULL);
	c->connectstate = 0;
	c->gotconfig = 0;
	c->nickname = safe_strdup(username);

	/* send the signon string to indicate that we're speaking FLAP here */

	firetalk_internal_send_data(conn,SIGNON_STRING,strlen(SIGNON_STRING),1);

	return FE_SUCCESS;
}

enum firetalk_error toc_get_info(client_t c, const char * const nickname) {
	if (c->lastinfo != NULL)
		free(c->lastinfo);
	c->lastinfo = safe_strdup(nickname);
	return toc_send_printf(c,0,"toc_get_info %s",nickname);
}

enum firetalk_error toc_set_info(client_t c, const char * const info) {
	return toc_send_printf(c,1,"toc_set_info %s",info);
}

enum firetalk_error toc_set_nickname(client_t c, const char * const nickname) {
	return toc_send_printf(c,0,"toc_format_nickname %s",nickname);
}

enum firetalk_error toc_set_password(client_t c, const char * const oldpass, const char * const newpass) {
	c->passchange++;
	return toc_send_printf(c,0,"toc_change_passwd %s %s",oldpass,newpass);
}

enum firetalk_error toc_set_away(client_t c, const char * const message) {
	if (message)
		return toc_send_printf(c,0,"toc_set_away %s",message);
	else
		return toc_send_printf(c,0,"toc_set_away");
}

enum firetalk_error toc_im_evil(client_t c, const char * const who) {
	return toc_send_printf(c,0,"toc_evil %s norm",who);
}

enum firetalk_error toc_periodic(struct s_firetalk_handle * const c) {
	struct s_toc_connection *conn;
	time_t idle;
	long passidle;

	conn = c->handle;

	if (firetalk_internal_get_connectstate(conn) != FCS_ACTIVE)
		return FE_NOTCONNECTED;

	idle = (long) time(NULL) - conn->lasttalk;

	passidle = (long) idle;
	firetalk_callback_setidle(conn,&passidle);

	if (passidle < 600)
		passidle = 0;

	if (passidle == conn->lastidle)
		return FE_IDLEFAST;

	if (passidle - conn->lastidle < 40)
		if (passidle - conn->lastidle > 0)
			return FE_IDLEFAST;

	conn->lastidle = passidle;
	return toc_send_printf(conn,0,"toc_set_idle %l",passidle);
}

enum firetalk_error toc_chat_join(client_t c, const char * const room) {
	int i;
	char *s;
	s = toc_internal_split_name(room);
	i = toc_internal_get_room_invited(c,s);
	if (i == 1) {
		(void) toc_internal_set_room_invited(c,room,0);
		return toc_send_printf(c,0,"toc_chat_accept %s",toc_internal_find_room_id(c,room));
	} else {
		int m;
		(void) toc_internal_add_room(c,s,m = toc_internal_split_exchange(room));
		return toc_send_printf(c,0,"toc_chat_join %d %s",m,s);
	}
}

enum firetalk_error toc_chat_part(client_t c, const char * const room) {
	char *temp = toc_internal_find_room_id(c,room);
	if (!temp)
		return FE_ROOMUNAVAILABLE;
	return toc_send_printf(c,0,"toc_chat_leave %s",temp);
}

enum firetalk_error toc_chat_send_message(client_t c, const char * const room, const char * const message, const int auto_flag) {
	char *temp = toc_internal_find_room_id(c,room);
	if (!temp)
		return FE_ROOMUNAVAILABLE;
	return toc_send_printf(c,0,"toc_chat_send %s %s",temp,message);
}

enum firetalk_error toc_chat_send_action(client_t c, const char * const room, const char * const message, const int auto_flag) {
	char tempbuf[2048];

	if (strlen(message) > 2042)
		return FE_PACKETSIZE;
		
	safe_strncpy(tempbuf,"/me ",2048);
	safe_strncat(tempbuf,message,2048);
	return toc_send_printf(c,0,"toc_chat_send %s %s",toc_internal_find_room_id(c,room),tempbuf);
}

enum firetalk_error toc_chat_invite(client_t c, const char * const room, const char * const who, const char * const message) {
	char *roomid;
	roomid = toc_internal_find_room_id(c,room);
	if (roomid != NULL)
		return toc_send_printf(c,0,"toc_chat_invite %s %s %s",toc_internal_find_room_id(c,room),message,who);
	else
		return FE_NOTFOUND;
}
