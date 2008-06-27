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
dow_LIBS=unix threads
#dow_LIBS=graphics unix threads bigarray sdl sdlloader sdlttf

include OCaml.mk

