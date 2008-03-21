
(* Listen on port *)
let _ =
    let http_config = { 
        Http.default_config with 
        Http.port = 9009 ;
    }
    in
    Printf.printf "Desktop-based Ocaml Wiki\n" ; flush stdout ;
    Http.server_run http_config
;;
