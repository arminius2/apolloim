/*
toc.h - FireTalk TOC shared declarations
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
#ifndef _TOC_H
#define _TOC_H

#include <time.h>

struct s_toc_room {
	struct s_toc_room *next;
	int exchange;
	char *name;
	char *id;
	int invited;
	int joined;
};

#define TOC_HTML_MAXLEN 65536

struct s_toc_infoget {
	int sockfd;
	struct s_toc_infoget *next;
#define TOC_STATE_CONNECTING 0
#define TOC_STATE_TRANSFERRING 1
	int state;
	char buffer[TOC_HTML_MAXLEN];
	int buflen;
};

struct s_toc_connection {
	unsigned short local_sequence;                       /* our sequence number */
	unsigned short remote_sequence;                      /* toc's sequence number */
	char *nickname;                                      /* our nickname (correctly spaced) */
	struct s_toc_room *room_head;
	struct s_toc_infoget *infoget_head;
	char *lastinfo;
	time_t lasttalk;                                     /* last time we talked */
	time_t lastidle;                                  /* last idle that we told the server */
	double lastsend;
	int passchange;                                      /* whether we're changing our password right now */
	int online;
	int connectstate;
	int gotconfig;
};

#define TOC_HEADER_LENGTH 6
#define TOC_SIGNON_LENGTH 24
#define TOC_HOST_SIGNON_LENGTH 4
#define TOC_USERNAME_MAXLEN 16

#define SFLAP_FRAME_SIGNON ((unsigned char)1)
#define SFLAP_FRAME_DATA ((unsigned char)2)
#define SFLAP_FRAME_ERROR ((unsigned char)3)
#define SFLAP_FRAME_SIGNOFF ((unsigned char)4)
#define SFLAP_FRAME_KEEPALIVE ((unsigned char)5)

#define SIGNON_STRING "FLAPON\r\n\r\n"

int toc_send_printf(client_t c, int urgent, const char * const format, ...);
char *toc_quote(const char * const string, const int outside_flag);
unsigned short toc_fill_header(unsigned char * const header, unsigned char const frame_type, unsigned short const length);
enum firetalk_error toc_prepare_for_transmit(client_t c, char * const data, const int length);
char **toc_parse_args(char * const instring, int maxargs);
unsigned short toc_fill_signon(unsigned char * const signon, const char * const username);
unsigned char toc_get_frame_type_from_header(const unsigned char * const header);
unsigned short toc_get_sequence_from_header(const unsigned char * const header);
unsigned short toc_get_length_from_header(const unsigned char * const header);
enum firetalk_error toc_internal_disconnect(client_t c, const int error);
char *toc_hash_password(const char * const password);
int toc_internal_add_room(client_t c, const char * const name, const int exchange);
int toc_internal_find_exchange(client_t c, const char * const name);
int toc_internal_set_joined(client_t c, const char * const name, const int exchange);
int toc_internal_set_id(client_t c, const char * const name, const int exchange, const char * const id);
char *toc_internal_find_room_id(client_t c, const char * const name);
char *toc_internal_find_room_name(client_t c, const char * const id);
int toc_internal_split_exchange(const char * const string);
char *toc_internal_split_name(const char * const string);
int toc_internal_set_room_invited(client_t c, const char * const name, const int invited);
int toc_internal_get_room_invited(client_t c, const char * const name);
int toc_get_tlv_value(char ** args, const int startarg, const int type, char *dest, int destlen);
enum firetalk_error toc_find_packet(client_t c, unsigned char * buffer, unsigned short * bufferpos, char * outbuffer, const int frametype, unsigned short *l);
void toc_infoget_parse(client_t c, struct s_toc_infoget *i);
void toc_infoget_remove(client_t c, struct s_toc_infoget *i, char *error);
enum firetalk_error toc_preselect(client_t c, fd_set *read, fd_set *write, fd_set *except, int *n);
enum firetalk_error toc_postselect(client_t c, fd_set *read, fd_set *write, fd_set *except);
char *toc_get_arg0(char * const instring);
client_t toc_create_handle();
void toc_destroy_handle(client_t c);
enum firetalk_error toc_disconnect(client_t c);
enum firetalk_error toc_signon(client_t c, const char * const username);
enum firetalk_error toc_get_info(client_t c, const char * const nickname);
enum firetalk_error toc_set_info(client_t c, const char * const info);
enum firetalk_error toc_set_nickname(client_t c, const char * const nickname);
enum firetalk_error toc_set_password(client_t c, const char * const oldpass, const char * const newpass);
enum firetalk_error toc_set_away(client_t c, const char * const message);
enum firetalk_error toc_im_evil(client_t c, const char * const who);
enum firetalk_error toc_periodic(struct s_firetalk_handle * const c);
enum firetalk_error toc_chat_join(client_t c, const char * const room);
enum firetalk_error toc_chat_part(client_t c, const char * const room);
enum firetalk_error toc_chat_send_message(client_t c, const char * const room, const char * const message, const int auto_flag);
enum firetalk_error toc_chat_send_action(client_t c, const char * const room, const char * const message, const int auto_flag);
enum firetalk_error toc_chat_invite(client_t c, const char * const room, const char * const who, const char * const message);
enum firetalk_error toc_free_contents(client_t c);

#endif
