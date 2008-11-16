
(* vim: set ts=2 sw=2 et: *)
(* Listen on port *)
let _ =
  let storage_config = {
    Storage.name = "file" ;
    Storage.url = "wiki_data" ;
  }
  and  http_config = { 
    Http.default_config with 
    Http.port = 9009 ;
    Http.get_handler = HttpHandler.get_handler ;
    Http.post_handler = HttpHandler.post_handler ;
    }
  in
  (* load configuration file *)
  (*

  storage.url = file://
  gui.gtk.enable = true

  gui.http.enable = true
  gui.http.port = 9009

  storage.
  # 
  *)
  (* Storage.create "file" *)
  let storage = Storage.create storage_config
  in
  ignore storage ; 
  Printf.printf "*** Dow : Desktop-based Ocaml Wiki ***\n" ; flush stdout ;
  GuiHttp.run http_config
;;

