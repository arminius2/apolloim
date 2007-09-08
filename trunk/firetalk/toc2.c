/*
toc2.c - FireTalk TOC2 protocol definitions
Copyright (C) 2000 Ian Gulliver

Thanks to Jeffrey Rosen for the reverse engineering.

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
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <time.h>
#include <fcntl.h>
#include <errno.h>

typedef struct s_toc_connection * client_t;
#define _HAVE_CLIENT_T

#include "firetalk-int.h"
#include "firetalk.h"
#include "toc.h"
#include "toc2.h"
#include "aim.h"
#include "safestring.h"

enum firetalk_error toc2_im_add_buddy(client_t c, const char * const nickname, const char * const group) {
	char data[512];
	int length;
	struct s_firetalk_handle *fchandle;

	fchandle = firetalk_find_handle(c);

	safe_snprintf(&data[TOC_HEADER_LENGTH],512 - TOC_HEADER_LENGTH,"toc2_new_buddies {g:%s\nb:%s\n}",group,nickname);
	length = toc_fill_header((unsigned char *)data,SFLAP_FRAME_DATA,strlen(&data[TOC_HEADER_LENGTH]) + 1);
	firetalk_internal_send_data(fchandle,data,length,0);
	return FE_SUCCESS;
}

enum firetalk_error toc2_im_remove_buddy(client_t c, const char * const nickname, const char * const group) {
	return toc_send_printf(c,0,"toc2_remove_buddy %s %s",nickname,group);
}

enum firetalk_error toc2_im_add_deny(client_t c, const char * const nickname) {
	return toc_send_printf(c,0,"toc2_add_deny %s",nickname);
}

enum firetalk_error toc2_im_remove_deny(client_t c, const char * const nickname) {
	return toc_send_printf(c,0,"toc2_remove_deny %s",nickname);
}

enum firetalk_error toc2_im_send_message(client_t c, const char * const dest, const char * const message, const int auto_flag) {
	if ((auto_flag == 0) && (aim_compare_nicks(dest,c->nickname) == FE_NOMATCH))
		c->lasttalk = time(NULL);
	
	if (auto_flag == 1)
		return toc_send_printf(c,0,"toc2_send_im %s %s auto",dest,aim_interpolate_variables(message,dest));
	else
		return toc_send_printf(c,0,"toc2_send_im %s %s",dest,message);
}

enum firetalk_error toc2_im_send_action(client_t c, const char * const dest, const char * const message, const int auto_flag) {
	char tempbuf[2048]; 

	if (strlen(message) > 2042)
		return FE_PACKETSIZE;

	safe_strncpy(tempbuf,"/me ",2048);
	safe_strncat(tempbuf,message,2048);

	if (auto_flag == 0)
		c->lasttalk = time(NULL);
	
	if (auto_flag == 1)
		return toc_send_printf(c,0,"toc2_send_im %s %s auto",dest,tempbuf);
	else
		return toc_send_printf(c,0,"toc2_send_im %s %s",dest,tempbuf);
}

enum firetalk_error toc2_got_data(client_t c, unsigned char * buffer, unsigned short * bufferpos) {
	char *tempchr1;
	char *tempchr2;
	char *tempchr3;
	char data[8192 - TOC_HEADER_LENGTH + 1];
	char *arg0;
	char **args;
	enum firetalk_error r;
	unsigned short l;

got_data_start:

	r = toc_find_packet(c,buffer,bufferpos,data,SFLAP_FRAME_DATA,&l);
	if (r == FE_NOTFOUND)
		return FE_SUCCESS;
	else if (r != FE_SUCCESS)
		return r;

	arg0 = toc_get_arg0(data);
	if (!arg0)
		return FE_SUCCESS;
	if (strcmp(arg0,"ERROR") == 0) {
		args = toc_parse_args(data,3);
		if (!args[1]) {
			(void) toc_internal_disconnect(c,FE_INVALIDFORMAT);
			return FE_INVALIDFORMAT;
		}
		switch (atoi(args[1])) {
			case 901:
				firetalk_callback_error(c,FE_USERUNAVAILABLE,args[2],NULL);
				break;
			case 902:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,args[2],NULL);
				break;
			case 903:
				firetalk_callback_error(c,FE_TOOFAST,NULL,NULL);
				break;
			case 911:
				if (c->passchange != 0) {
					c->passchange--;
					firetalk_callback_error(c,FE_NOCHANGEPASS,NULL,NULL);
				} else
					firetalk_callback_error(c,FE_BADUSER,NULL,NULL);
				break;
			case 915:
				firetalk_callback_error(c,FE_TOOFAST,NULL,NULL);
				break;
			case 950:
				firetalk_callback_error(c,FE_ROOMUNAVAILABLE,args[2],NULL);
				break;
			case 960:
				firetalk_callback_error(c,FE_TOOFAST,args[2],NULL);
				break;
			case 961:
				firetalk_callback_error(c,FE_INCOMINGERROR,args[2],"Message too big.");
				break;
			case 962:
				firetalk_callback_error(c,FE_INCOMINGERROR,args[2],"Message sent too fast.");
				break;
			case 970:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,NULL);
				break;
			case 971:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Too many matches.");
				break;
			case 972:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Need more qualifiers.");
				break;
			case 973:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Directory service unavailable.");
				break;
			case 974:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Email lookup restricted.");
				break;
			case 975:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Keyword ignored.");
				break;
			case 976:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"No keywords.");
				break;
			case 977:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Language not supported.");
				break;
			case 978:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,"Country not supported.");
				break;
			case 979:
				firetalk_callback_error(c,FE_USERINFOUNAVAILABLE,NULL,NULL);
				break;
			case 980:
				firetalk_callback_error(c,FE_BADUSERPASS,NULL,NULL);
				break;
			case 981:
				firetalk_callback_error(c,FE_UNKNOWN,NULL,"Service temporarily unavailable.");
				break;
			case 982:
				firetalk_callback_error(c,FE_BLOCKED,NULL,"Your warning level is too high to sign on.");
				break;
			case 983:
				firetalk_callback_error(c,FE_BLOCKED,NULL,"You have been connected and disconnecting too frequently.  Wait 10 minutes.");
				break;
			case 989:
				firetalk_callback_error(c,FE_UNKNOWN,NULL,NULL);
				break;
			default:
				firetalk_callback_error(c,FE_UNKNOWN,NULL,NULL);
				break;
		}
	} else if (strcmp(arg0,"PAUSE") == 0) {
		c->connectstate = 1;
		firetalk_internal_set_connectstate(c,FCS_WAITING_SIGNON);
	} else if (strcmp(arg0,"NEW_BUDDY_REPLY2") == 0) {
		/* do nothing */
	} else if (strcmp(arg0,"IM_IN2") == 0) {
		args = toc_parse_args(data,5);
		if ((args[1] == NULL) || (args[2] == NULL) || (args[3] == NULL) || (args[4] == NULL)) {
			(void) toc_internal_disconnect(c,FE_INVALIDFORMAT);
			return FE_INVALIDFORMAT;
		}
		(void) aim_handle_ect(c,args[1],args[4],args[2][0] == 'T' ? 1 : 0);
		if (strlen(args[3]) > 0) {
			char *mestart;
			if (safe_strncasecmp(args[4],"/me ",4) == 0)
				firetalk_callback_im_getaction(c,args[1],args[2][0] == 'T' ? 1 : 0,&args[4][4]);
			else if ((mestart = strstr(args[4],">/me ")) != NULL)
				firetalk_callback_im_getaction(c,args[1],args[2][0] == 'T' ? 1 : 0,&mestart[5]);
			else {
				if (args[2][0] == 'T') /* interpolate only auto-messages */
					firetalk_callback_im_getmessage(c,args[1],1,aim_interpolate_variables(args[4],c->nickname));
				else
					firetalk_callback_im_getmessage(c,args[1],0,args[4]);
			}
		}
	} else if (strcmp(arg0,"UPDATE_BUDDY2") == 0) {
		args = toc_parse_args(data,8);
		if (!args[1] || !args[2] || !args[3] || !args[4] || !args[5] || !args[6] || !args[7]) {
			(void) toc_internal_disconnect(c,FE_INVALIDFORMAT);
			return FE_INVALIDFORMAT;
		}
		firetalk_callback_im_buddyonline(c,args[1],args[2][0] == 'T' ? 1 : 0);
		firetalk_callback_user_nickchanged(c,args[1],args[1]);
		firetalk_callback_im_buddyaway(c,args[1],args[6][2] == 'U' ? 1 : 0);
		firetalk_callback_idleinfo(c,args[1],atol(args[5]));
	} else if (strcmp(arg0,"GOTO_URL") == 0) {
		struct s_toc_infoget *i;
		/* create a new infoget object and set it to connecting state */
		args = toc_parse_args(data,3);
		if (!args[1] || !args[2]) {
			(void) toc_internal_disconnect(c,FE_INVALIDFORMAT);
			return FE_INVALIDFORMAT;
		}
		i = c->infoget_head;
		c->infoget_head = safe_malloc(sizeof(struct s_toc_infoget));
#define TOC_HTTP_REQUEST "GET /%s HTTP/1.0\r\n\r\n"

		safe_snprintf(c->infoget_head->buffer,TOC_HTML_MAXLEN,TOC_HTTP_REQUEST,args[2]);
		c->infoget_head->buflen = strlen(c->infoget_head->buffer);
		c->infoget_head->next = i;
		c->infoget_head->state = TOC_STATE_CONNECTING;
		c->infoget_head->sockfd = firetalk_internal_connect(firetalk_internal_remotehost4(c)
#ifdef FIRETALK_USE_IPV6
				,firetalk_internal_remotehost6(c)
#endif
				);
		if (c->infoget_head->sockfd == -1) {
			firetalk_callback_error(c,FE_CONNECT,c->lastinfo,"Failed to connect to info server");
			free(c->infoget_head);
			c->infoget_head = i;
			return FE_SUCCESS;
		}
	} else if (strcmp(arg0,"EVILED") == 0) {
		args = toc_parse_args(data,3);
		if (!args[1]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"EVILED");
			return FE_SUCCESS;
		}
		firetalk_callback_eviled(c,atoi(args[1]),args[2]);
	} else if (strcmp(arg0,"CHAT_JOIN") == 0) {
		int i;
		args = toc_parse_args(data,3);
		if (!args[1] || !args[2]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"CHAT_JOIN");
			return FE_SUCCESS;
		}
		i = toc_internal_find_exchange(c,args[2]);
		if (i != 0)
			if (toc_internal_set_id(c,args[2],i,args[1]) == FE_SUCCESS)
				if (toc_internal_set_joined(c,args[2],i) == FE_SUCCESS)
					firetalk_callback_chat_joined(c,toc_internal_find_room_name(c,args[1]));
	} else if (strcmp(arg0,"CHAT_LEFT") == 0) {
		args = toc_parse_args(data,2);
		if (!args[1]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"CHAT_LEFT");
			return FE_SUCCESS;
		}
		firetalk_callback_chat_left(c,toc_internal_find_room_name(c,args[1]));
	} else if (strcmp(arg0,"CHAT_IN") == 0) {
		args = toc_parse_args(data,5);
		if (!args[1] || !args[2] || !args[3] || !args[4]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"CHAT_IN");
			return FE_SUCCESS;
		}
		if (safe_strncasecmp(args[4],"<HTML><PRE>",11) == 0) {
			args[4] = &args[4][11];
			if ((tempchr1 = strchr(args[4],'<')))
				tempchr1[0] = '\0';
		}
		if ((safe_strncasecmp(args[4],"/me ",4) == 0) || (safe_strncasecmp(args[4],"<HTML>/me ",9) == 0))
			firetalk_callback_chat_getaction(c,toc_internal_find_room_name(c,args[1]),args[2],0,&args[4][4]);
		else
			firetalk_callback_chat_getmessage(c,toc_internal_find_room_name(c,args[1]),args[2],0,args[4]);
	} else if (strcmp(arg0,"CHAT_INVITE") == 0) {
		args = toc_parse_args(data,5);
		if (!args[1] || !args[2] || !args[3] || !args[4]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"CHAT_INVITE");
			return FE_SUCCESS;
		}
		if (toc_internal_add_room(c,args[1],4) == FE_SUCCESS)
			if (toc_internal_set_room_invited(c,args[1],1) == FE_SUCCESS)
				if (toc_internal_set_id(c,args[1],4,args[2]) == FE_SUCCESS)
					firetalk_callback_chat_invited(c,args[1],args[3],args[4]);
	} else if (strcmp(arg0,"CHAT_UPDATE_BUDDY") == 0) {
		args = toc_parse_args(data,4);
		if (!args[1] || !args[2] || !args[3]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"CHAT_UPDATE_BUDDY");
			return FE_SUCCESS;
		}
		tempchr1 = args[3];
		tempchr3 = toc_internal_find_room_name(c,args[1]);
		while ((tempchr2 = strchr(tempchr1,':'))) {
			/* cycle through list of buddies */
			tempchr2[0] = '\0';
			if (args[2][0] == 'T')
				firetalk_callback_chat_user_joined(c,tempchr3,tempchr1);
			else
				firetalk_callback_chat_user_left(c,tempchr3,tempchr1,NULL);
			tempchr1 = tempchr2 + 1;
		}
		if (args[2][0] == 'T')
			firetalk_callback_chat_user_joined(c,tempchr3,tempchr1);
		else
			firetalk_callback_chat_user_left(c,tempchr3,tempchr1,NULL);
	} else if (strcmp(arg0,"ADMIN_NICK_STATUS") == 0) {
		/* ignore this one */
	} else if (strcmp(arg0,"NICK") == 0) {
		args = toc_parse_args(data,2);
		if (!args[1]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"NICK");
			return FE_SUCCESS;
		}
		firetalk_callback_user_nickchanged(c,c->nickname,args[1]);
		free(c->nickname);
		c->nickname = safe_strdup(args[1]);
		firetalk_callback_newnick(c,args[1]);
	} else if (strcmp(arg0,"ADMIN_PASSWD_STATUS") == 0) {
		c->passchange--;
		args = toc_parse_args(data,3);
		if (!args[1]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"ADMIN_PASSWD_STATUS");
			return FE_SUCCESS;
		}
		if (atoi(args[1]) != 0)
			firetalk_callback_error(c,FE_NOCHANGEPASS,NULL,NULL);
		else
			firetalk_callback_passchanged(c);
	} else if (strcmp(arg0,"RVOUS_PROPOSE") == 0) {
		args = toc_parse_args(data,255);
		if (!args[1] || !args[2] || !args[3] || !args[4] || !args[5] || !args[6] || !args[7] || !args[8]) {
			firetalk_callback_error(c,FE_INVALIDFORMAT,NULL,"RVOUS_PROPOSE");
			return FE_SUCCESS;
		}
		if (strcmp(args[2],"09461343-4C7F-11D1-8222-444553540000") == 0) {
			/* file send offer */
			char filename[256];
			int length;
			int totalsize = 0;

			length = toc_get_tlv_value(args,9,10001,filename,255);

			if (length < 8) {
				firetalk_callback_error(c,FE_INVALIDFORMAT,args[1],"RVOUS_PROPOSE Invalid TLV length");
				return FE_SUCCESS;
			}
			if (filename[3] != 1) {
				firetalk_callback_error(c,FE_INVALIDFORMAT,args[1],"User offered multiple files (unsupported)");
				return FE_SUCCESS;
			}

			totalsize |= (filename[4] << 24) & 0xff000000;
			totalsize |= (filename[5] << 16) & 0x00ff0000;
			totalsize |= (filename[6] << 8) & 0x0000ff00;
			totalsize |= (filename[7] << 0) & 0x000000ff;

			firetalk_callback_file_offer(c,args[1],&filename[8],totalsize,args[7],NULL,(uint16_t)atoi(args[8]),FF_TYPE_CUSTOM,args[3]);
		}
	} else
		firetalk_callback_error(c,FE_WIERDPACKET,NULL,arg0);

	goto got_data_start;
}

enum firetalk_error toc2_got_data_connecting(client_t c, unsigned char * buffer, unsigned short * bufferpos) {
	char data[8192 - TOC_HEADER_LENGTH + 1];
	char password[128];
	enum firetalk_error r;
	unsigned short length;
	char *arg0;
	char **args;
	char *tempchr1;
	char *tempchr2;
	int permit_mode;
	unsigned long o;
	firetalk_t fchandle;

got_data_connecting_start:
	
	r = toc_find_packet(c,buffer,bufferpos,data,c->connectstate == 0 ? SFLAP_FRAME_SIGNON : SFLAP_FRAME_DATA,&length);
	if (r == FE_NOTFOUND)
		return FE_SUCCESS;
	else if (r != FE_SUCCESS)
		return r;

	switch (c->connectstate) {
		case 0: /* we're waiting for the flap version number */
			if (length != TOC_HOST_SIGNON_LENGTH) {
				firetalk_callback_connectfailed(c,FE_PACKETSIZE,"Host signon length incorrect");
				return FE_PACKETSIZE;
			}
			if (data[0] != '\0' || data[1] != '\0' || data[2] != '\0' || data[3] != '\1') {
				firetalk_callback_connectfailed(c,FE_VERSION,NULL);
				return FE_VERSION;
			}
			srand((unsigned int) time(NULL));
			c->local_sequence = (unsigned short) 1+(unsigned short) (65536.0*rand()/(RAND_MAX+1.0));

			length = toc_fill_header((unsigned char *) data,SFLAP_FRAME_SIGNON,toc_fill_signon((unsigned char *)&data[TOC_HEADER_LENGTH],c->nickname));

			fchandle = firetalk_find_handle(c);
			firetalk_internal_send_data(fchandle,data,length,1);

			firetalk_callback_needpass(c,password,128);

			c->connectstate = 1;
 
			{
				unsigned long a,b,d;
		 		a = (c->nickname[0] - 96) * 7696 + 738816;
				b = (c->nickname[0] - 96) * 746512;
				d = (password[0] - 96) * a;
				o = d - a + b + 71665152;
			}
			r = toc_send_printf(c,1,"toc2_signon login.oscar.aol.com 5190 %s %s english TIC:AIMM 160 %y",c->nickname,toc_hash_password(password),o);
			if (r != FE_SUCCESS) {
				firetalk_callback_connectfailed(c,r,NULL);
				return r;
			}
			break;
		case 1:
			arg0 = toc_get_arg0(data);
			if (strcmp(arg0,"SIGN_ON") != 0) {
				if (strcmp(arg0,"ERROR") == 0) {
					args = toc_parse_args(data,3);
					if (args[1]) {
						switch (atoi(args[1])) {
							case 980:
								firetalk_callback_connectfailed(c,FE_BADUSERPASS,NULL);
								return FE_BADUSERPASS;
							case 981:
								firetalk_callback_connectfailed(c,FE_SERVER,NULL);
								return FE_SERVER;
							case 982:
								firetalk_callback_connectfailed(c,FE_BLOCKED,"Your warning level is too high to sign on");
								return FE_BLOCKED;
							case 983:
								firetalk_callback_connectfailed(c,FE_BLOCKED,"You have been connecting and disconnecting too frequently");
								return FE_BLOCKED;
						}
					}
				}
				firetalk_callback_connectfailed(c,FE_UNKNOWN,NULL);
				return FE_UNKNOWN;
			}
			c->connectstate = 2;
			break;
		case 2:
		case 3:
			arg0 = toc_get_arg0(data);
			if (arg0 == NULL)
				return FE_SUCCESS;
			if (strcmp(arg0,"NICK") == 0) {
				args = toc_parse_args(data,2);
				if (args[1]) {
					if (c->nickname)
						free(c->nickname);
					c->nickname = safe_strdup(args[1]);
				}
				c->connectstate = 3;
			} else if (strcmp(arg0,"CONFIG2") == 0) {
				char *curgroup = safe_strdup(DEFAULT_GROUP);
				fchandle = firetalk_find_handle(c);
				args = toc_parse_args(data,2);
				if (!args[1]) {
					firetalk_callback_connectfailed(c,FE_INVALIDFORMAT,"CONFIG2");
					return FE_INVALIDFORMAT;
				}
				tempchr1 = args[1];
				permit_mode = 0;
				c->gotconfig = 1;
				while ((tempchr2 = strchr(tempchr1,'\n'))) {
					/* rather stupidly, we have to tell it everything back that it just told us.  how dumb */
					tempchr2[0] = '\0';
					switch (tempchr1[0]) {
						case 'm':    /* permit mode */
							permit_mode = ((int) (tempchr1[2] - '1')) + 1;
							break;
						case 'd':    /* deny */
							firetalk_im_internal_add_deny(fchandle,&tempchr1[2]);
							break;
						case 'b':    /* buddy */
							firetalk_im_internal_add_buddy(fchandle,&tempchr1[2],curgroup);
							break;
						case 'g':
							free(curgroup);
							curgroup = safe_strdup(&tempchr1[2]);
							break;
					}
					tempchr1 = &tempchr2[1];
				}
				free(curgroup);
				if (permit_mode != 4)
					r = toc_send_printf(c,1,"toc_add_deny");
					if (r != FE_SUCCESS) {
						firetalk_callback_connectfailed(c,r,NULL);
						return r;
					}
			} else {
				firetalk_callback_connectfailed(c,FE_WIERDPACKET,arg0);
				return FE_WIERDPACKET;
			}
			if (c->gotconfig == 1 && c->connectstate == 3) {
				/* ask the client to handle its init */
				firetalk_callback_doinit(c,c->nickname);
				r = toc_send_printf(c,1,"toc_init_done");
				if (r != FE_SUCCESS) {
					firetalk_callback_connectfailed(c,r,NULL);
					return r;
				}
				
				c->online = 1;

				r = toc_send_printf(c,1,"toc_set_caps 09461343-4C7F-11D1-8222-444553540000");
				if (r != FE_SUCCESS) {
					firetalk_callback_connectfailed(c,r,NULL);
					return r;
				}
				firetalk_callback_connected(c);
				return FE_SUCCESS;
			}
			break;

	}
	goto got_data_connecting_start;
}

enum firetalk_error toc2_subcode_send_request(client_t c, const char * const to, const char * const command, const char * const args) {
	char buffer[2048];
	if (args == NULL)
		safe_snprintf(buffer,2048,"<!--ECT %s-->",command);
	else
		safe_snprintf(buffer,2048,"<!--ECT %s %s-->",command,args);
	return toc2_im_send_message(c,to,buffer,0);
}

enum firetalk_error toc2_subcode_send_reply(client_t c, const char * const to, const char * const command, const char * const args) {
	char buffer[2048];
	if (args == NULL)
		safe_snprintf(buffer,2048,"<!--ECT %s-->",command);
	else
		safe_snprintf(buffer,2048,"<!--ECT %s %s-->",command,args);
	return toc2_im_send_message(c,to,buffer,1);
}
