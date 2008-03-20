(* vim: set ts=2 sw=2 et : *)

exception Not_a_method of string
;;


exception Not_a_proto of string
;;


type handler_t =
  | EditPost
  | EditGet
  | View
;;

type status_t = 
  (* http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html *)
  (* 1xx *)
  | Continue
  | Switching_Protocols
  (* 2xx *)
  | Ok
  | Created
  | Accepted
  | NonAuthoritative_Information
  | NoContent
  | Reset_Content
  | Partial_Content
  (* 3xx *)
  | Multiple_Choices
  | Moved_Permanently
  | Found
  | See_Other
  | Not_Modified
  | Use_Proxy
  | Temporary_Redirect
  (* 4xx *)
;;


type proto_t = 
  | P1_0
  | P1_1
;;


type method_t = 
  | Get
  | Post
  | Put
;;


type request_t = {
 xmethod : method_t ; (* don't forget the 'x' prefix... *)
 location : string ;
 protocol : proto_t ;
}
;;


type response_t = {
  status: status_t ;
  headers: string list ;
  data: string ;
}
;;


(* Port to listen on *)
let port = 9090
;;


let listen_sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0
;;


let read_string sock = 
  let strlen = 1024 in
  let strbuf = String.make strlen '\000' in
  let _ = Unix.recv sock strbuf 0 strlen [] in
  strbuf
;;


  (* Sends the gives string to the given socket *)
  (* Unix.file_descr -> string -> unit *)
let send_string sock str =
  let len = String.length str in
  let _ = Unix.send sock str 0 len [] in
  ()
;;

let html_from_request request =
  let page_from_request request =
    try 
      Scanf.sscanf request.location "/%[a-zA-Z]" 
      (fun page_str -> 
        ( page_str, "view" ))
    with
    | End_of_file ->  
        Printf.printf "<-- HTTP.WIKIDATA: EOF [%s]\n" request.location;
        flush stdout ;
        ( Wiki.homepage, "view" )
    | Scanf.Scan_failure _ -> 
        Printf.printf "<-- WIKI.WIKIDATA: Invalid page [%s]\n" request.location ;
        flush stdout ;
        ( Wiki.homepage, "view" )
  in

  let page_handler_from_request request = 
    try 
      Scanf.sscanf request.location "/%[a-zA-Z]/%[a-z]" 
      (fun page_str -> 
        fun handler_str -> 
          ( page_str, handler_str ))
    with
    | End_of_file -> 
        page_from_request request
    | Scanf.Scan_failure _ -> 
        Printf.printf "<-- WIKI.WIKIDATA: Invalid page [%s]\n" request.location ;
        flush stdout ;
        ( Wiki.homepage, "view" )
  in

  let ( wiki_page, wiki_handler_str ) = page_handler_from_request request
  in

  let wiki_action = 
    match wiki_handler_str with
    | "view" -> Wiki.Html
    | "edit" -> 
        if request.xmethod = Get then Wiki.Raw
        else Wiki.Change "blabla"
    | _ -> Wiki.Html

  in
  
  let wiki_html = Wiki.handle wiki_page wiki_action
  in

  (* send_string client_sock  *)
  Printf.sprintf "<html><body>%s</body></html>" wiki_html
;;



let string_from_method xmethod = 
  match xmethod with
  | Get -> "GET"
  | Post -> "POST"
  | Put -> "PUT"
;;


let method_from_string method_str = 
  match method_str with
  | "GET" -> Get
  | "POST" -> Post
  | "PUT" -> Put
  | _ -> raise ( Not_a_method method_str )
;;


let string_from_protocol protocol =
  match protocol with
  | P1_0 -> "1.0"
  | P1_1 -> "1.1"
;;

let protocol_from_string protocol_str = 
  match protocol_str with
  | "1.0" -> P1_0
  | "1.1" -> P1_1
  | _ -> raise ( Not_a_proto protocol_str )
;;

let string_from_request request =
  Printf.sprintf "method=[%s] location=[%s] protocol=[%s]" 
  ( string_from_method request.xmethod )
  request.location
  ( string_from_protocol request.protocol )
;;


let answer_from_request request =
  let header = ref [] in
  let status = ref Ok in (*  *)
  ignore header ; (* FIXME *)
  ignore status ; (* FIXME *)
  Printf.printf "<-- HTTP.REQUEST: [%s]\n" ( string_from_request request ) ;
  flush stdout ; 
  let wiki_html = html_from_request request 
  in
  (* add HTTP response *)
  (* add headers *)
   "HTTP/1.1 200/OK\nContent-type: text/html\n\n" ^
  (* add html *)
   wiki_html
;;


(* handle accept *)
let do_accept client_sock =
  let request_str = read_string client_sock
  in

  let handle_request_str method_str location_str protocol_str = 
    { xmethod = method_from_string method_str ;
      location = location_str ;
      protocol = protocol_from_string protocol_str }
  in

  let request_from_string request_str =
    Printf.printf "<-- HTTP/RAW: [%s]\n" request_str ;
    flush stdout ;
    try 
      let request = 
        Scanf.sscanf request_str "%s %s HTTP/%s" handle_request_str
      in
      send_string client_sock (html_from_request request)
    with 
    | Not_found -> print_string "not found?\n" ; flush stdout
    | End_of_file -> print_string "EOF\n" ; flush stdout
  in

  request_from_string request_str ; 
  Unix.close client_sock
;;


(* Listen on port *)
let run () =
  let inet_addr = 
    (Unix.ADDR_INET (Unix.inet_addr_of_string "0.0.0.0", port)) in
  Unix.bind listen_sock inet_addr;
  Unix.listen listen_sock 8;
  while true do
    let (client_sock, _) = Unix.accept listen_sock in
    match Unix.fork () with 
    | 0 -> do_accept client_sock 
    | id -> Unix.close client_sock ; ignore(Unix.waitpid [] id)
  done
;;
