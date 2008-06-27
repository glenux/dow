
(* vim: set ts=2 sw=2 et : *)
(* type storage_type_t = 
  | Storage_file
  | Storage_sqlite3
;; *)
  
type storage_t = {
  load : (* pagename *) string -> (* data *) string ;
  store : (* pagename *) string -> (* data *) string -> unit ; 
  exists : (* pagename *) string -> bool ;
}
;;

(* this is what the client wants *)
type config_t = {
  name: string ;
  url : string ;
}
;;

type handler_fun_t = string -> storage_t
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
    "Registering storage handler \"" ^ handler_str ^ "\".\n"
  in
  ( if ( is_registered handler_str ) then
    print_string register_warning 
  ) ; 
  print_string register_text ;
  flush stdout ;
  Hashtbl.add handlers handler_str handler_fun ;
;;


(* create user-requested storage type or die *)
let create storage_config = 
  if ( is_registered storage_config.name ) then
    (* FIXME: get storage constructor from hashtbl *)
    (* StorageFile.create StorageFile.config_default *)
    true
  else
    (* StorageFile.create StorageFile.config_default *)
    (* FIXME: raise something... or crash *)
    false
;;
