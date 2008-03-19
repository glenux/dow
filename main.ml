
(* Port to listen on *)
let port = 9090

let listen_sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0

let read_string sock = 
        let strlen = 1024 in
        let strbuf = String.make strlen '\000' in
        let _ = Unix.recv sock strbuf 0 strlen [] in
        strbuf

(* Sends the gives string to the given socket *)
(* Unix.file_descr -> string -> unit *)
let send_string sock str =
        let len = String.length str in
        let _ = Unix.send sock str 0 len [] in
        ()

let do_get client_sock location = 
        send_string client_sock "HTTP/1.1 200/OK\nContent-type: text/html\n\n" ;
        let location_html = Wiki.render location 
        in
        send_string client_sock 
                (Printf.sprintf "<html><body>%s</body></html>" location_html) ;
        ()

let do_post client_sock location =
        send_string client_sock "HTTP/1.1 200/OK\nContent-type: text/html\n\n" ;
        send_string client_sock 
                (Printf.sprintf "<html><body><h1>Edit %s</h1></body></html>"
                location) ;
        ()

(* handle accept *)
let do_accept client_sock =
        let client_request = read_string client_sock 
        in

        let handle_httpdata http_req http_location http_proto = 
                Printf.printf 
                        "<-- HTTP: req=[%s] location=[%s] proto=[%s]\n" 
                        http_req http_location http_proto ; 
                flush stdout ;
                match http_req with
                | "GET" -> do_get client_sock http_location
                | "POST" -> do_post client_sock http_location
                | _ -> Printf.printf "Bad http-req %s\n" http_req ; ()
        in

        let httpdata_from_request request = 
                Printf.printf "<-- HTTP/RAW: [%s]\n" request ;
                flush stdout ;
                try
                        Scanf.sscanf request "%s %s HTTP/%s" 
                        handle_httpdata
                with 
                | Not_found -> print_string "not found?\n" ; flush stdout
                (* | _ -> print_string "Bad request. Dropping.\n" ; flush stdout
                 * *)
                | End_of_file -> print_string "EOF\n" ; flush stdout
        in
        
        httpdata_from_request client_request ;
        Unix.close client_sock


(* Listen on port *)
let _ =
        Printf.printf "Desktop-based Ocaml Wiki\n" ; 
        let inet_addr = 
                (Unix.ADDR_INET (Unix.inet_addr_of_string "0.0.0.0", port)) in
        Unix.bind listen_sock inet_addr;
        Unix.listen listen_sock 8;
        while true do
                let (client_sock, _) = Unix.accept listen_sock in
                print_string "Accepting\n" ; flush stdout ;
                match Unix.fork () with 
                | 0 -> do_accept client_sock 
                | id -> Unix.close client_sock ; ignore(Unix.waitpid [] id)
        done
