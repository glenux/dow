(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;

let debug = false
;;

let default_request = {
  rmethod = Get ;
  location = "/" ;
  rprotocol = Protocol_1_0 ;
  rheaders = Hashtbl.create 5;
  get = Hashtbl.create 5 ;
  post = Hashtbl.create 5 ;
};;


let string_of_method xmethod = 
  match xmethod with
  | Head -> "HEAD"
  | Get -> "GET"
  | Post -> "POST"
  | Put -> "PUT"
  | Delete -> "DELETE" 
;;

(*
let rec string_of_location location =
  match location with 
  | hd_str::tail_str -> "/" ^ hd_str ^ ( string_of_location tail_str )
  | [] -> ""
;;

let rec location_of_string location_str =
  let len = String.length location_str
  and idx =
    try String.index location_str '/'
    with Not_found -> -1
  in
    match idx with
    | idx when idx < 0 -> 
        let suffix_str = String.sub location_str 0 len
        in [ suffix_str ]
    | 0 ->
        let suffix_str = String.sub location_str 1 ( len - 1 )
        in ( location_of_string suffix_str )
    | idx ->
        let prefix_str = String.sub location_str 0 idx
        and suffix_str = String.sub location_str (idx + 1) ( len - idx - 1)
        in prefix_str :: ( location_of_string suffix_str )
;;
*)

let method_of_string method_str = 
  match method_str with
  | "HEAD" -> Head
  | "GET" -> Get
  | "POST" -> Post
  | "PUT" -> Put
  | "DELETE" -> Delete
  | _ -> raise ( Unknown_method method_str )
;;


let string_of_request request =
  Printf.sprintf "( method=%s location=%s protocol=%s )" 
  ( string_of_method request.rmethod )
  request.location
  (* string_of_location request.location *)
  ( string_of_protocol request.rprotocol )
;;


let request_of_networkdata request_str =
  let handle_request_str method_str location_str protocol_str = 
    { default_request with
      rmethod = method_of_string method_str ;
      location = (* location_of_string *) location_str ;
      rprotocol = protocol_of_string protocol_str }
  in

  if debug then Printf.printf "<-- HTTP/RAW: [%s]\n" request_str ;
  flush stdout ;
  try 
      Scanf.sscanf request_str "%s %s HTTP/%s" handle_request_str
  with
  | Not_found -> raise (Invalid_request request_str)
  | End_of_file -> 
    try
      Scanf.sscanf request_str "%s %s "
      (fun x -> fun y -> handle_request_str x y "1.0")
    with
    | Not_found -> raise (Invalid_request request_str)
    | End_of_file -> raise (Invalid_request request_str)
;;

