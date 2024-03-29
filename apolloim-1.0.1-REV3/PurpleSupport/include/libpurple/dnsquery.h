/**
 * @file dnsquery.h DNS query API
 * @ingroup core
 *
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
#ifndef _PURPLE_DNSQUERY_H_
#define _PURPLE_DNSQUERY_H_

#include <glib.h>
#include "eventloop.h"
#include "account.h"

typedef struct _PurpleDnsQueryData PurpleDnsQueryData;

/**
 * The "hosts" parameter is a linked list containing pairs of
 * one size_t addrlen and one struct sockaddr *addr.  It should
 * be free'd by the callback function.
 */
typedef void (*PurpleDnsQueryConnectFunction)(GSList *hosts, gpointer data, const char *error_message);

/**
 * Callbacks used by the UI if it handles resolving DNS
 */
typedef void  (*PurpleDnsQueryResolvedCallback) (PurpleDnsQueryData *query_data, GSList *hosts);
typedef void  (*PurpleDnsQueryFailedCallback) (PurpleDnsQueryData *query_data, const gchar *error_message);

/**
 * DNS Request UI operations
 */
typedef struct
{
	/* If implemented, the UI is responsible for DNS queries */
	gboolean (*resolve_host)(PurpleDnsQueryData *query_data, PurpleDnsQueryResolvedCallback resolved_cb, PurpleDnsQueryFailedCallback failed_cb);

	/* After destroy is called, query_data will be feed, so this must
	 * cancel any further use of it the UI would do. Unneeded if 
	 * resolve_host is not implemented.
	 */
	void (*destroy)(PurpleDnsQueryData *query_data);

	void (*_purple_reserved1)(void);
	void (*_purple_reserved2)(void);
	void (*_purple_reserved3)(void);
	void (*_purple_reserved4)(void);
} PurpleDnsQueryUiOps;

#ifdef __cplusplus
extern "C" {
#endif

/**************************************************************************/
/** @name DNS query API                                                   */
/**************************************************************************/
/*@{*/

/**
 * Perform an asynchronous DNS query.
 *
 * @param hostname The hostname to resolve.
 * @param port     A port number which is stored in the struct sockaddr.
 * @param callback The callback function to call after resolving.
 * @param data     Extra data to pass to the callback function.
 *
 * @return NULL if there was an error, otherwise return a reference to
 *         a data structure that can be used to cancel the pending
 *         DNS query, if needed.
 */
PurpleDnsQueryData *purple_dnsquery_a(const char *hostname, int port, PurpleDnsQueryConnectFunction callback, gpointer data);

/**
 * Cancel a DNS query and destroy the associated data structure.
 *
 * @param query_data The DNS query to cancel.  This data structure
 *        is freed by this function.
 */
void purple_dnsquery_destroy(PurpleDnsQueryData *query_data);

/**
 * Sets the UI operations structure to be used when doing a DNS
 * resolve.  The UI operations need only be set if the UI wants to
 * handle the resolve itself; otherwise, leave it as NULL.
 *
 * @param ops The UI operations structure.
 */
void purple_dnsquery_set_ui_ops(PurpleDnsQueryUiOps *ops);

/**
 * Returns the UI operations structure to be used when doing a DNS
 * resolve.
 *
 * @return The UI operations structure.
 */
PurpleDnsQueryUiOps *purple_dnsquery_get_ui_ops(void);

/**
 * Get the host associated with a PurpleDnsQueryData
 *
 * @param query_data The DNS query
 * @return The host.
 */
char *purple_dnsquery_get_host(PurpleDnsQueryData *query_data);

/**
 * Get the port associated with a PurpleDnsQueryData
 *
 * @param query_data The DNS query
 * @return The port.
 */
unsigned short purple_dnsquery_get_port(PurpleDnsQueryData *query_data);

/**
 * Initializes the DNS query subsystem.
 */
void purple_dnsquery_init(void);

/**
 * Uninitializes the DNS query subsystem.
 */
void purple_dnsquery_uninit(void);

/*@}*/

#ifdef __cplusplus
}
#endif

#endif /* _PURPLE_DNSQUERY_H_ */
