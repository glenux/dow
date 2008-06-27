PROGRAMS=dow

dow_OBJS= \
	  StorageFile \
	  StorageSqlite3 \
	  Wiki \
	  WikiHandler \
	  WikiHandlerEdit \
	  WikiHandlerView \
	  WikiEngine \
	  HttpTypes \
	  HttpRequest \
	  HttpAnswer \
	  HttpHandler \
	  Http \
	  Document \
	  Main

OPTS=-w A -warn-error A -g -thread 

dow_INCS=-I +lablgtk2

dow_LIBS=unix threads lablgtk

include OCaml.mk

