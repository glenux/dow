(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;
(* open HttpRequest;;
open HttpAnswer;; *)


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
  let default_handler = (function _ -> HttpAnswer.default_answer )
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
  let handler = function 
  | Get -> config.get_handler
  | Post -> config.post_handler
  | Head -> config.head_handler
  | Delete -> config.delete_handler
  | Put -> config.put_handler
  in (handler request.rmethod) request
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
  (* get request string from client *)
  let request_str = read_string client_sock
  in

  (* fill request structure *)
  let request = HttpRequest.request_of_networkdata request_str
  in

  (* call the appropriate handler the request *)
  let answer = answer_of_request ~config ~request 
  in

  (* display some debug info *)
  let request_str = (HttpRequest.string_of_request request)
  and answer_str = (HttpAnswer.string_of_answer answer)
  and answer_netdata = (HttpAnswer.networkdata_of_answer answer)
  in
  Printf.printf "<-- HTTP.REQUEST [%s]\n" request_str ;
  Printf.printf "--> HTTP.ANSWER [%s]\n" answer_str ; 

  (* send answer back to client *)
  flush stdout ;
  send_string client_sock answer_netdata ;
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

