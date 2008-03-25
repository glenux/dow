(* vim: set ts=2 sw=2 et : *)

type handler_fun_t = string -> unit
;;

type t = (string, handler_fun_t ) Hashtbl.t 
;;

let (handlers : t ) = Hashtbl.create 1
;;

let register handler_str handler_fun =
        (
                if ( Hashtbl.mem handlers handler_str ) then
                        print_string ( "WARNING: handler \"" ^ handler_str ^ 
                        "\" is already registered! Overiding." ) ;
                        flush stdout 
                        ) ;
        print_string ( 
                "Registering wiki handler \"" ^ handler_str ^ "\"." ) ;
        flush stdout ;
        Hashtbl.add handlers handler_str handler_fun 
;;

