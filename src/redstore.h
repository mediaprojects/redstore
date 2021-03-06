/*
    RedStore - a lightweight RDF triplestore powered by Redland
    Copyright (C) 2010-2011 Nicholas J Humfrey <njh@aelius.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "redstore_config.h"

#include <stdarg.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/time.h>

#include <redland.h>
#include "redhttp/redhttp.h"


#ifndef _REDSTORE_H_
#define _REDSTORE_H_


// ------- Constants -------
#define DEFAULT_PORT            "8080"
#define DEFAULT_ADDRESS         (NULL)
#define DEFAULT_STORAGE_NAME    "redstore"
#define DEFAULT_STORAGE_TYPE    "hashes"
#define DEFAULT_STORAGE_OPTIONS "hash-type='memory'"
#define DEFAULT_QUERY_LANGUAGE  "laqrs"
#define DEFAULT_GRAPH_FORMAT    "rdfxml"
#define DEFAULT_PARSE_FORMAT    "ntriples"
#define DEFAULT_RESULTS_FORMAT  "xml"


// ------- Logging ---------

// Only display debug if verbose
#define redstore_debug( ... ) \
		redstore_log(LIBRDF_LOG_DEBUG, __VA_ARGS__ )

// Don't show info when quiet
#define redstore_info( ... ) \
		redstore_log(LIBRDF_LOG_INFO, __VA_ARGS__ )

#define redstore_warn( ... ) \
		redstore_log(LIBRDF_LOG_WARN, __VA_ARGS__ )

// Always display
#define redstore_error( ... ) \
		redstore_log(LIBRDF_LOG_ERROR, __VA_ARGS__ )

// Quit if fatal
#define redstore_fatal( ... ) \
		redstore_log(LIBRDF_LOG_FATAL, __VA_ARGS__ )



// ------- Globals ---------
extern int quiet;
extern int verbose;
extern int running;
extern int exit_code;
extern unsigned long query_count;
extern unsigned long import_count;
extern unsigned long request_count;
extern const char *storage_name;
extern const char *storage_type;
extern char *public_storage_options;
extern librdf_world *world;
extern librdf_storage *storage;
extern librdf_model *model;
extern raptor_stringbuffer *error_buffer;

extern librdf_uri *format_ns_uri;
extern librdf_uri *sd_ns_uri;
extern librdf_uri *void_ns_uri;


// ------- Callbacks ---------

typedef redhttp_response_t *(*redstore_stream_processor) (redhttp_request_t * request,
                                                          librdf_stream * stream,
                                                          librdf_node * graph);

typedef const raptor_syntax_description* (*description_proc_t) (librdf_world *world, unsigned int c);


// ------- Prototypes -------

int description_init(void);
redhttp_response_t *handle_description_get(redhttp_request_t * request, void *user_data);
void description_free(void);

redhttp_response_t *handle_page_home(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_page_query_form(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_page_update_form(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_page_load_form(redhttp_request_t * request, void *user_data);

redhttp_response_t *handle_query(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_sparql(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_page_robots_txt(redhttp_request_t * request, void *user_data);

redhttp_response_t *redstore_page_new(int code, const char *title);
redhttp_response_t *redstore_page_new_with_message(redhttp_request_t *request, int log_level, int code, const char *format, ...);
int redstore_page_append_string(redhttp_response_t * response, const char *str);
int redstore_page_append_decimal(redhttp_response_t * response, int decimal);
int redstore_page_append_strings(redhttp_response_t * response, ...);
int redstore_page_append_string_buffer(redhttp_response_t * response, raptor_stringbuffer *buffer, int escape);
int redstore_page_append_escaped(redhttp_response_t * response, const char *str, char quote);
void redstore_page_end(redhttp_response_t * response);

void page_append_html_header(redhttp_response_t * response, const char *title);
void page_append_html_footer(redhttp_response_t * response);

redhttp_response_t *handle_graph_index(redhttp_request_t * request, void *user_data);

redhttp_response_t *handle_data_head(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_data_get(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_data_put(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_data_post(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_data_delete(redhttp_request_t * request, void *user_data);


redhttp_response_t *load_stream_into_new_graph(redhttp_request_t * request, librdf_stream * stream,
                                               librdf_node * graph_node);
redhttp_response_t *load_stream_into_graph(redhttp_request_t * request, librdf_stream * stream,
                                           librdf_node * graph);
redhttp_response_t *clear_and_load_stream_into_graph(redhttp_request_t * request,
                                                     librdf_stream * stream, librdf_node * graph);
redhttp_response_t *delete_stream_from_graph(redhttp_request_t * request, librdf_stream * stream,
                                             librdf_node * graph);
redhttp_response_t *parse_data_from_buffer(redhttp_request_t * request, unsigned char *buffer,
                                           size_t content_length, const char *parser_name,
                                           librdf_node *graph_node,
                                           redstore_stream_processor stream_proc);
redhttp_response_t *parse_data_from_request_body(redhttp_request_t * request,
                                                 librdf_node *graph_node,
                                                 redstore_stream_processor stream_proc);
redhttp_response_t *handle_load_post(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_insert_post(redhttp_request_t * request, void *user_data);
redhttp_response_t *handle_delete_post(redhttp_request_t * request, void *user_data);

redhttp_response_t *format_bindings_query_result(redhttp_request_t * request,
                                                 librdf_query_results * results);

redhttp_response_t *format_graph_stream(redhttp_request_t * request, librdf_stream * stream);

redhttp_response_t *handle_image_favicon(redhttp_request_t * request, void *user_data);

void redstore_log(librdf_log_level level, const char *format, ...);

const raptor_syntax_description* redstore_get_format_by_name(description_proc_t desc_proc, const char* format_name);
const raptor_syntax_description* redstore_negotiate_format(redhttp_request_t * request, description_proc_t desc_proc, const char* default_format, const char** chosen_mime);
char *redstore_negotiate_string(redhttp_request_t * request, const char* supported, const char* default_format);
int redstore_is_html_format(const char *str);
int redstore_is_text_format(const char *str);
int redstore_is_nquads_format(const char *str);

char* redstore_genid(void);


#endif
