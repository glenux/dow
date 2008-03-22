
(* Listen on port *)
let _ =
    let http_config = { 
        Http.default_config with 
        Http.port = 9009 ;
        Http.get_handler = WikiEngine.get_handler ;
        Http.post_handler = WikiEngine.post_handler ;
    }
    in
    Printf.printf "Desktop-based Ocaml Wiki\n" ; flush stdout ;
    Http.server_run http_config
;;
