PROGRAMS=dow

dow_OBJS= \
	  wiki \
	  http \
	  document \
	  main

dow_LIBS=unix threads
#dow_LIBS=graphics unix threads bigarray sdl sdlloader sdlttf

include OCaml.mk

