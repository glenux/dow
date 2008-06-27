
(* vim: set ts=2 sw=2 et: *)
(* Listen on port *)
let _ =
  let wiki_config = Wiki.default_config
  and  http_config = { 
    Http.default_config with 
    Http.port = 9009 ;
    Http.get_handler = HttpHandler.get_handler ;
    Http.post_handler = HttpHandler.post_handler ;
    }
in
ignore wiki_config ;
Printf.printf "Desktop-based Ocaml Wiki\n" ; flush stdout ;
Http.server_run http_config
;;


