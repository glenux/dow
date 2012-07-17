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

V=0
ifeq ($(V),1)
Q=
else
Q=@
endif

define PROGRAM_template
ALL_OBJS   += $($(1)_OBJS)
$(1): $$($(1)_OBJS:=.cmx)
	@printf "\033[31;1m"
	@echo "[L] $(1)"
	@printf "\033[0m"
	$(Q)$(OCAMLOPT) $($(1)_OPTS) $(OPTS) $(INCS) $(LIBS) $($(1)_INCS) $($(1)_LIBS:=.cmxa) $($(1)_OBJS:=.cmx) -o $(1)
endef

$(foreach prog,$(PROGRAMS),$(eval $(call PROGRAM_template,$(prog))))

.PHONY: all
all: $(PROGRAMS)

.PHONY: doc
doc: 
	ocamldoc $(INCS) -d doc -html $(ML) $(MLI)

%.cmi: %.mli
	@printf "\033[31;1m"
	@echo "[I] $<"
	@printf "\033[0m"
	$(Q)test $(V) -ne 1 || $(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -i $<
	$(Q)$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -c $<
	@test $(V) -ne 1 || echo ""

%.cmx: %.ml
	@printf "\033[31;1m"
	@echo "[C] $<"
	@printf "\033[0m"
	$(Q)test $(V) -ne 1 || $(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -i $<
	$(Q)$(OCAMLOPT) $(OPTS) $(INCS) $(LIBS) -c $<
	@test $(V) -ne 1 || echo ""

%.cmo %.cmi: %.ml %.cmi %.mli
	@echo "[O] $<"
	$(Q)test $(V) -ne 1 || $(OCAMLC) $(OPTS) $(INCS) $(LIBS) -i $<
	$(Q)$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -c $<
	@test $(V) -ne 1 || echo ""

%.cmo %.cmi: %.ml
	@printf "\033[31;1m"
	@echo "[O] $<"
	@printf "\033[0m"
	$(Q)test $(V) -ne 1 || $(OCAMLC) $(OPTS) $(INCS) $(LIBS) -i $<
	$(Q)$(OCAMLC) $(OPTS) $(INCS) $(LIBS) -c $<
	@test $(V) -ne 1 || echo ""

clean:
	$(Q)rm -f $(PROGRAMS) *~ *.cm* *.o *.a *.so .depend *.cmxa *.cma

.depend: $(ML) $(MLI)
	$(Q)$(OCAMLDEP) $(ML) $(MLI) > .depend
	@test $(V) -ne 1 || echo ""


.SUFFIXES:

-include .depend

