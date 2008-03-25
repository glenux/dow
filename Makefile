PROGRAMS=dow

dow_OBJS= \
	  HttpTypes \
	  HttpRequest \
	  HttpAnswer \
	  Http \
	  WikiHandler \
	  WikiHandlerEdit \
	  WikiHandlerView \
	  WikiEngine \
	  WikiHttp \
	  Document \
	  Main

OPTS=-w A -warn-error A -g -thread 
dow_LIBS=unix threads
#dow_LIBS=graphics unix threads bigarray sdl sdlloader sdlttf

include OCaml.mk

