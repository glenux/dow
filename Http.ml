(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;
open HttpRequest;;
open HttpAnswer;;


type config_t = {
  port: int ;
  address : string ;
  head_handler : request_t -> answer_t ;
  get_handler : request_t -> answer_t ;
  post_handler : request_t -> answer_t ;
  put_handler : request_t -> answer_t ; 
  delete_handler : request_t -> answer_t ;
}
;;


let default_config = 
  let default_handler = (function _ -> default_answer )
  in
  {
    port = 80 ; (* Port to listen on *)
    address = "0.0.0.0" ; (* Address to listen on *)
    head_handler = default_handler ;
    get_handler = default_handler ;
    post_handler = default_handler ;
    put_handler = default_handler ;
    delete_handler = default_handler ;
  }
;;

let answer_of_request ~config ~request =
  match request.rmethod with 
  | Get -> config.get_handler request
  | Post -> config.post_handler request
  | Head -> config.head_handler request
  | Delete -> config.delete_handler request
  | Put -> config.put_handler request
;;

let string_of_config config =
  let port_str = Printf.sprintf "port=[%d]" config.port
  and address_str = Printf.sprintf "address=[%s]" config.address
  in
  Printf.sprintf "config=[%s %s]" address_str port_str
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


(* handle accept *)
let do_accept ~client_sock ~config =
  (* get request string *)
  let request_str = read_string client_sock
  in

  (* fill request structure *)
  let request = HttpRequest.request_of_string request_str
  in

  (* call handler for given request *)
  let answer = answer_of_request ~config ~request 
  in

  let request_str = (string_of_request request)
  and answer_str = (string_of_answer answer)
  in

  (* send answer back to client *)
  Printf.printf "<-- HTTP.REQUEST [%s]\n" request_str ;
  Printf.printf "--> HTTP.RAW [%s]\n" answer_str ; 
  flush stdout ;
  send_string client_sock answer_str ;
  Unix.close client_sock
;;


let server_run config =
  Printf.printf "%s\n" (string_of_config config) ; flush stdout ;
  let listen_sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0
  and inet_addr = 
    (Unix.ADDR_INET (Unix.inet_addr_of_string config.address, config.port)) 
  in

  Unix.bind listen_sock inet_addr;
  Unix.listen listen_sock 8;
  while true do
    let (client_sock, _) = Unix.accept listen_sock in
    match Unix.fork () with 
    | 0 -> do_accept ~client_sock ~config
    | id -> Unix.close client_sock ; ignore(Unix.waitpid [] id)
  done
;;

