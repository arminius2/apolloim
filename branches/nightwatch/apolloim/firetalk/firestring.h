/*
firestring.h - FireString string function declarations
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
#ifndef _FIRESTRING_H
#define _FIRESTRING_H

#include <stdlib.h>

struct firestring_conf_t {
	char *var;
	char *value;
	struct firestring_conf_t *next;
};

struct firestring_estr_t {
	char *s;
	long a;
	long l;
};

void *firestring_malloc(const size_t size);
void *firestring_realloc(void *old, const size_t new);
char *firestring_strdup(const char * const input);
void firestring_strncpy(char * const to, const char * const from, const size_t size);
void firestring_strncat(char * const to, const char * const from, const size_t size);
int firestring_snprintf(char * out, const size_t size, const char * const format, ...);
int firestring_strncasecmp(const char * const s1, const char * const s2, const size_t n);
int firestring_strcasecmp(const char * const s1, const char * const s2);
char *firestring_concat(const char *s, ...);
char *firestring_chomp(char * const s);
char *firestring_chug(char *s);
int firestring_hextoi(const char * const input);

/* estr functions */
void firestring_estr_alloc(struct firestring_estr_t * const f, const long a);
void firestring_estr_expand(struct firestring_estr_t * const f, const long a);
void firestring_estr_free(struct firestring_estr_t * const f);
int firestring_estr_base64_encode(struct firestring_estr_t * const t, const struct firestring_estr_t * const f);
int firestring_estr_base64_decode(struct firestring_estr_t * const t, const struct firestring_estr_t * const f);
int firestring_estr_xml_encode(struct firestring_estr_t * const t, const struct firestring_estr_t * const f);
int firestring_estr_xml_decode(struct firestring_estr_t * const t, const struct firestring_estr_t * const f);
int firestring_estr_read(struct firestring_estr_t * const f, const int fd);
long firestring_estr_sprintf(struct firestring_estr_t * const o, const char * const format, ...);
long firestring_estr_strchr(const struct firestring_estr_t * const f, const char c, const long start);
long firestring_estr_strstr(const struct firestring_estr_t * const f, const char * const s, const long start);
long firestring_estr_stristr(const struct firestring_estr_t * const f, const char * const s, const long start);
int firestring_estr_starts(const struct firestring_estr_t * const f, const char * const s);
int firestring_estr_ends(const struct firestring_estr_t * const f, const char * const s);
int firestring_estr_strcasecmp(const struct firestring_estr_t * const f, const char * const s);
int firestring_estr_strcmp(const struct firestring_estr_t * const f, const char * const s);
int firestring_estr_strcpy(struct firestring_estr_t * const f, const char * const s);
int firestring_estr_strcat(struct firestring_estr_t * const f, const char * const s);
int firestring_estr_estrcasecmp(const struct firestring_estr_t * const t, const struct firestring_estr_t * const f, const long start);
int firestring_estr_estrncasecmp(const struct firestring_estr_t * const t, const struct firestring_estr_t * const f, const long length, const long start);
int firestring_estr_estrcpy(struct firestring_estr_t * const t, const struct firestring_estr_t * const f, const long start);
int firestring_estr_estrcmp(const struct firestring_estr_t * const t, const struct firestring_estr_t * const f, const long start);
int firestring_estr_estrcat(struct firestring_estr_t * const t, const struct firestring_estr_t * const f, const long start);
long firestring_estr_estrstr(const struct firestring_estr_t * const haystack, const struct firestring_estr_t * const needle, const long start);
long firestring_estr_estristr(const struct firestring_estr_t * const haystack, const struct firestring_estr_t * const needle, const long start);
int firestring_estr_eends(const struct firestring_estr_t * const f, const struct firestring_estr_t * const s);
int firestring_estr_estarts(const struct firestring_estr_t * const f, const struct firestring_estr_t * const s);
void firestring_estr_0(struct firestring_estr_t * const f);

/* configuration system functions */
struct firestring_conf_t *firestring_conf_parse(const char * const filename);
struct firestring_conf_t *firestring_conf_parse_next(const char * const filename, struct firestring_conf_t * const prev);
struct firestring_conf_t *firestring_conf_add(struct firestring_conf_t * const next, const char * const var, const char * const value);
char *firestring_conf_find(const struct firestring_conf_t *config, const char * const var);
char *firestring_conf_find_next(const struct firestring_conf_t *config, const char * const var, const char * const prev);
void firestring_conf_free(struct firestring_conf_t *config);

#endif
