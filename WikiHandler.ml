
(* vim: set ts=2 sw=2 et : *)

type handler_fun_t = string -> unit
;;

type t = (string, handler_fun_t ) Hashtbl.t 
;;

let (handlers : t ) = Hashtbl.create 1
;;

let is_registered handler_str =
  Hashtbl.mem handlers handler_str
;;

let register handler_str handler_fun =
  let register_warning = 
    "WARNING: handler \"" ^ handler_str ^ "\" is already registered! Overiding."
  and register_text = 
    "Registering wiki handler \"" ^ handler_str ^ "\".\n"
  in
  ( if ( is_registered handler_str ) then
    print_string register_warning 
  ) ; 
  print_string register_text ;
  flush stdout ;
  Hashtbl.add handlers handler_str handler_fun ;
;;
