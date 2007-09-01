/*
dummy.c - FireTalk dummy protocol definitions
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
#include "firetalk-int.h"
#include "firetalk.h"
#include "dummy.h"
#include "safestring.h"

enum firetalk_error dummy_set_nickname(client_t c, const char * const nickname) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_set_password(client_t c, const char * const oldpass, const char * const newpass) {
	return FE_SUCCESS;
}

void dummy_destroy_handle(client_t c) {
	return;
}

enum firetalk_error dummy_disconnect(client_t c) {
	return FE_SUCCESS;
}

client_t dummy_create_handle() {
	return NULL;
}

enum firetalk_error dummy_signon(client_t c, const char * const nickname) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_save_config(client_t c) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_preselect(client_t c, fd_set *read, fd_set *write, fd_set *except, int *n) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_postselect(client_t c, fd_set *read, fd_set *write, fd_set *except) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_got_data(client_t c, unsigned char * buffer, unsigned short * bufferpos) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_got_data_connecting(client_t c, unsigned char * buffer, unsigned short * bufferpos) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_compare_nicks(const char * const nick1, const char * const nick2) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_join(client_t c, const char * const room) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_part(client_t c, const char * const room) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_send_message(client_t c, const char * const room, const char * const message, const int auto_flag) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_send_action(client_t c, const char * const room, const char * const message, const int auto_flag) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_invite(client_t c, const char * const room, const char * const who, const char * const message) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_send_message(client_t c, const char * const dest, const char * const message, const int auto_flag) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_send_action(client_t c, const char * const dest, const char * const message, const int auto_flag) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_set_topic(client_t c, const char * const room, const char * const topic) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_op(client_t c, const char * const room, const char * const who) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_deop(client_t c, const char * const room, const char * const who) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_chat_kick(client_t c, const char * const room, const char * const who, const char * const reason) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_add_buddy(client_t c, const char * const nickname, const char * const group) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_remove_buddy(client_t c, const char * const nickname, const char * const group) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_add_deny(client_t c, const char * const nickname) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_remove_deny(client_t c, const char * const nickname) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_upload_buddies(client_t c) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_upload_denies(client_t c) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_im_evil(client_t c, const char * const who) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_get_info(client_t c, const char * const nickname) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_set_info(client_t c, const char * const info) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_set_away(client_t c, const char * const message) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_periodic(struct s_firetalk_handle * const c) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_subcode_send_request(client_t c, const char * const to, const char * const command, const char * const args) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_subcode_send_reply(client_t c, const char * const to, const char * const command, const char * const args) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_file_handle_custom(client_t c, const int fd, char *buffer, long *bufferpos, const char * const cookie) {
	return FE_SUCCESS;
}

enum firetalk_error dummy_file_complete_custom(client_t c, const int fd, void *customdata) {
	return FE_SUCCESS;
}

const char * const dummy_normalize_room_name(const char * const name) {
	return name;
}

enum firetalk_error dummy_prepare_for_transmit(client_t c, char * const data, const int length) {
	return FE_SUCCESS;
}

char *dummy_translate_open_font(client_t c, const char * const color, const char * const back, const char * const size) {
	static char ret[256];
	char temp[64];
	safe_strncpy(ret,"<font",256);
	if (color != NULL) {
		safe_snprintf(temp,64," color=\"%s\"",color);
		safe_strncat(ret,temp,256);
	}
	if (back != NULL) {
		safe_snprintf(temp,64," back=\"%s\"",back);
		safe_strncat(ret,temp,256);
	}
	if (size != NULL) {
		safe_snprintf(temp,64," size=\"%d\"",atoi(size));
		safe_strncat(ret,temp,256);
	}
	safe_strncat(ret,">",256);
	return ret;
}

char *dummy_translate_open_b(client_t c) {
	return "<b>";
}

char *dummy_translate_open_u(client_t c) {
	return "<u>";
}

char *dummy_translate_open_i(client_t c) {
	return "<i>";
}

char *dummy_translate_open_img(client_t c, const char * const src) {
	static char ret[256];
	char temp[64];
	safe_strncpy(ret,"<img",256);
	if (src != NULL) {
		safe_snprintf(temp,64," src=\"%s\"",src);
		safe_strncat(ret,temp,256);
	}
	safe_strncat(ret,">",256);
	return ret;
}

char *dummy_translate_open_br(client_t c) {
	return "<br>";
}

char *dummy_translate_close_font(client_t c) {
	return "</font>";
}

char *dummy_translate_close_b(client_t c) {
	return "</b>";
}

char *dummy_translate_close_u(client_t c) {
	return "</u>";
}

char *dummy_translate_close_i(client_t c) {
	return "</i>";
}
