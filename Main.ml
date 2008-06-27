
(* vim: set ts=2 sw=2 et: *)
(* Listen on port *)
let _ =
  let storage_config = {
    Storage.name = "text" ;
    Storage.url = "wiki_data" ;
  }
  and  http_config = { 
    Http.default_config with 
    Http.port = 9009 ;
    Http.get_handler = HttpHandler.get_handler ;
    Http.post_handler = HttpHandler.post_handler ;
    }
in
(* Storage.create "file" *)
ignore storage_config ;
Printf.printf "Desktop-based Ocaml Wiki\n" ; flush stdout ;
Http.server_run http_config
;;


