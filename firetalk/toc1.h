/*
toc.h - FireTalk TOC1 protocol declarations
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
#ifndef _TOC1_H
#define _TOC1_H

#include "firetalk.h"
#include "firetalk-int.h"
#include <unistd.h>
#include <sys/time.h>

/* AOL/TOC Functions */
enum firetalk_error toc1_im_add_buddy(client_t c, const char * const nickname, const char * const group);
enum firetalk_error toc1_im_remove_buddy(client_t c, const char * const nickname, const char * const group);
enum firetalk_error toc1_im_add_deny(client_t c, const char * const nickname);
enum firetalk_error toc1_im_upload_buddies(client_t c);
enum firetalk_error toc1_im_upload_denies(client_t c);
enum firetalk_error toc1_im_send_message(client_t c, const char * const dest, const char * const message, const int auto_flag);
enum firetalk_error toc1_im_send_action(client_t c, const char * const dest, const char * const message, const int auto_flag);

enum firetalk_error toc1_subcode_send_request(client_t c, const char * const to, const char * const command, const char * const args);
enum firetalk_error toc1_subcode_send_reply(client_t c, const char * const to, const char * const command, const char * const args);

enum firetalk_error toc1_save_config(client_t c);
enum firetalk_error toc1_got_data(client_t c, unsigned char * buffer, unsigned short * bufferpos);
enum firetalk_error toc1_got_data_connecting(client_t c, unsigned char * buffer, unsigned short * bufferpos);

#endif
