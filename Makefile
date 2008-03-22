PROGRAMS=dow

dow_OBJS= \
	  StringMap \
	  HttpTypes \
	  HttpRequest \
	  HttpAnswer \
	  Http \
	  WikiEngine \
	  WikiHtml \
	  Document \
	  Main

OPTS=-w A -warn-error A -g -thread 
dow_LIBS=unix threads
#dow_LIBS=graphics unix threads bigarray sdl sdlloader sdlttf

include OCaml.mk

