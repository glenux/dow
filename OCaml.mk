MLI=$(wildcard *.mli)
ML=$(wildcard *.ml)

CMI=$(patsubst %.mli,%.cmi,$(MLI))
CMO=$(patsubst %.ml,%.cmo,$(ML))
CMX=$(patsubst %.ml,%.cmx,$(ML))

OCAMLDEP=ocamldep
OCAMLOPT=ocamlopt
OCAMLC=ocamlc

OPTS+=
INCS+=
LIBS+=

define PROGRAM_template
ALL_OBJS   += $($(1)_OBJS)
$(1): $$($(1)_OBJS:=.cmx)
	@echo -n -e "\x1B[31;1m"
	@echo "[L] $(1)"
	@echo -n -e "\x1B[0m"
	$(OCAMLOPT) $($(1)_OPTS) $(OPTS) $(INCS) $(LIBS) $($(1)_INCS) $($(1)_LIBS:=.cmxa) $($(1)_OBJS:=.cmx) -o $(1)
	@echo ""
endef

$(foreach prog,$(PROGRAMS),$(eval $(call PROGRAM_template,$(prog))))

.PHONY: all
all: $(PROGRAMS)

.PHONY: doc
doc: 
	ocamldoc $(INCS) -d doc -html $(ML) $(MLI)

%.cmi: %.mli
	@echo -n -e "\x1B[31;1m"
	@echo "[I] $<"
	@echo -n -e "\x1B[0m"
	$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -i $<
	$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -c $<
	@echo ""

%.cmx: %.ml
	@echo -n -e "\x1B[31;1m"
	@echo "[C] $<"
	@echo -n -e "\x1B[0m"
	$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -i $<
	$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -c $<
	@echo ""

%.cmo %.cmi: %.ml %.cmi %.mli
	@echo "[O] $<"
	$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -i $<
	$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -c $<
	echo ""

%.cmo %.cmi: %.ml
	@echo -n -e "\x1B[31;1m"
	@echo "[O] $<"
	@echo -n -e "\x1B[0m"
	$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -i $<
	$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -c $<
	echo ""

clean:
	rm -f $(PROGRAMS) *~ *.cm* *.o *.a *.so .depend *.cmxa *.cma

.depend: $(ML) $(MLI)
	$(OCAMLDEP) $(ML) $(MLI) > .depend
	@echo ""


.SUFFIXES:

-include .depend

