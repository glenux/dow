
(* vim: set ts=2 sw=2 et : *)

type storage_t = 
  | Storage_file
  | Storage_sqlite3
;;

type config_t = {
  storage: storage_t ;
  url : string ;
}
;;


let default_storage = Storage_file
;;

let default_url = "wiki_data"
;;

let default_config = 
  {
    storage = default_storage ;
    url = default_url ;
  }
;;

let create ~config = 
  ignore config ;
  true
;;

let exists ~config ~page =
  try 
    ignore ( Unix.stat (config.url ^ "/" ^ page) );
    true
  with
  Unix.Unix_error(_, _, _) -> false
;;

let load ~config ~page =
  let filename = (config.url ^ "/" ^ page)
  in
  let ch_in= open_in filename
  in 
  let data = "FIXME: read ch_in 'til eof"
  in
  close_in ch_in;
  data
;;

let store ~config ~page ~data =
  let filename = (config.url ^ "/" ^ page)
  and oflags = [Unix.O_CREAT; Unix.O_WRONLY; Unix.O_TRUNC]
  and datalen = String.length data
  in
  let fd = Unix.openfile filename oflags 0644
  in 
  ignore ( Unix.write fd data 0 datalen );
  Unix.close fd ;
  ()
;;

