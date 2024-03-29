/*
 * purple
 *
 * Purple is the legal property of its developers, whose names are too numerous
 * to list here.  Please refer to the COPYRIGHT file distributed with this
 * source distribution.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#ifndef _YAHOO_FILEXFER_H_
#define _YAHOO_FILEXFER_H_

#include "ft.h"

/**
 * Process ymsg events, particular IMViroments like Doodle
 */
void yahoo_process_p2pfilexfer( PurpleConnection *gc, struct yahoo_packet *pkt );

/**
 * Process ymsg file receive invites.
 */
void yahoo_process_filetransfer(PurpleConnection *gc, struct yahoo_packet *pkt);

/**
 * Create a new PurpleXfer
 *
 * @param gc The PurpleConnection handle.
 * @param who Who will we be sending it to?
 */
PurpleXfer *yahoo_new_xfer(PurpleConnection *gc, const char *who);

/**
 * Send a file.
 *
 * @param gc The PurpleConnection handle.
 * @param who Who are we sending it to?
 * @param file What file? If NULL, user will choose after this call.
 */
void yahoo_send_file(PurpleConnection *gc, const char *who, const char *file);

#endif
