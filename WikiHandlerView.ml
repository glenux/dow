(* vim: set ts=2 sw=2 et: *)

let handle str =
  ignore str ;
        ()
;;

WikiHandler.register "view" handle;;

