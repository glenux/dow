
let config_default = {
    Storage.name = "file" ;
    Storage.url = "wiki_data" ; 
}
;;


let exists config page =
  try 
    ignore ( Unix.stat (config.Storage.url ^ "/" ^ page) );
    true
  with
  Unix.Unix_error(_, _, _) -> false
;;

let load config page =
  let filename = (config.Storage.url ^ "/" ^ page)
  in
  let ch_in= open_in filename
  in 
  let data = "FIXME: read ch_in 'til eof"
  in
  close_in ch_in;
  data
;;

let store config page data =
  let filename = (config.Storage.url ^ "/" ^ page)
  and oflags = [Unix.O_CREAT; Unix.O_WRONLY; Unix.O_TRUNC]
  and datalen = String.length data
  in
  let fd = Unix.openfile filename oflags 0644
  in 
  ignore ( Unix.write fd data 0 datalen );
  Unix.close fd ;
  ()
;;

let create config = {
    Storage.load = load config ;
    Storage.store = store config ;
    Storage.exists = exists config ;
}
;;

Storage.register config_default.Storage.name create;;

