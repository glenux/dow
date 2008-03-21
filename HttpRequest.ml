(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;


let default_request = {
  rmethod = Get ;
  location = "" ;
  rprotocol = Protocol_1_0 ;
  rheaders = StringMap.empty ;
  get = StringMap.empty ;
  post = StringMap.empty ;
};;


let string_of_method xmethod = 
  match xmethod with
  | Head -> "HEAD"
  | Get -> "GET"
  | Post -> "POST"
  | Put -> "PUT"
  | Delete -> "DELETE" 
;;


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
  Printf.sprintf "method=[%s] location=[%s] protocol=[%s]" 
  ( string_of_method request.rmethod )
  request.location
  ( string_of_protocol request.rprotocol )
;;


let request_of_string request_str =
  let handle_request_str method_str location_str protocol_str = 
    { default_request with
      rmethod = method_of_string method_str ;
      location = location_str ;
      rprotocol = protocol_of_string protocol_str }
  in

  Printf.printf "<-- HTTP/RAW: [%s]\n" request_str ;
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

