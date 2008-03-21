(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;

let default_answer = {
  status = Client_error Method_not_allowed;
  aheaders = StringMap.empty ;
  aprotocol = Protocol_1_0 ;
  content = "" ;
}
;;

(* http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html *)
let string_of_answer answer =
  let protocol_str = string_of_protocol answer.aprotocol
  and status_code = code_of_status answer.status
  and status_str = string_of_status answer.status
  and data_str = "Whatever !!!\n"
  in
  let data_len = String.length data_str
  in
  (* status code *)
  (* content-type *)
  (* content length *)
  (* etc.. *)
  ( Printf.sprintf "HTTP/%s %d %s\n" protocol_str status_code status_str ) ^ 
  ( Printf.sprintf "Content-Type: text/html\n" ) ^
  ( Printf.sprintf "Content-Length: %d\n" data_len ) ^
  ( "\n" ) ^
  ( "Whatever !!!\n" )

;;
