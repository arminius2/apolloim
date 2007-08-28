/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/



// void ft_callback_setidle(void *c, long *idle);
void ft_callback_im_user_nickchanged(void *c, void *cs, const char * const nickname);

void ft_callback_listbuddy			(void *c, void *cs, const char * const nickname, const char * const group, const int online, const int away, const long idle);
void ft_callback_buddyonline		(void *c, void *cs, const char * const who, const char * const group);
void ft_callback_buddyoffline		(void *c, void *cs, const char * const who, const char * const group);
void ft_callback_buddyunaway		(void *c, void *cs, const char * const who, const char * const group);
void ft_callback_buddyaway			(void *c, void *cs, const char * const who, const char * const group);
void ft_callback_getinfo			(void *c, void *cs, const char * const who, const char * const info, const int warning, const int idle, const int flags);
void ft_callback_getaction			(void *c, void *cs, const char * const room, const char * const from, const int automessage, const char * message);
void ft_callback_error				(void *c, void *cs, const int error, const char * const roomoruser, const char * const description);
void ft_callback_connectfailed		(void *c, void *cs, int error, char *reason);
void ft_callback_doinit				(void *c, void *cs, char *nickname);
void ft_callback_getmessage			(void *c, void *cs, const char * const who, const int automessage, const char * const message);
void ft_callback_disconnect			(void *c, void *cs, const int error);
void ft_callback_needpass			(void *c, void *cs, char *p, const int size);
void ft_callback_storepass			(char* newpass);

