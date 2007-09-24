/*
 ApolloIM-Callbacks.m: Objective-C libpurple interface.
 By Alex C. Schaefer

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

static void init_libpurple();
static void signed_on(PurpleConnection *gc, gpointer null);
static PurpleEventLoopUiOps glib_eventloops;
static PurpleConversationUiOps conv_uiops;
static PurpleCoreUiOps core_uiops;
static guint glib_input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction function, gpointer data);
static gboolean purple_glib_io_invoke(GIOChannel *source, GIOCondition condition, gpointer data);	
static void connect_to_signals();
static void buddy_event_cb(PurpleBuddy *buddy, PurpleBuddyEvent event);
static void write_conv(PurpleConversation *conv, const char *who, const char *alias,const char *message, PurpleMessageFlags flags, time_t mtime);
static void ui_init();
static void	apollo_conv_create(PurpleConversation *conv, const char *who, const char *message, PurpleMessageFlags flags, time_t mtime);
static void	apollo_conv_destroy(PurpleConversation *conv);
