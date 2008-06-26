(* vim: set ts=2 sw=2 et : *)

open HttpTypes;;

let default_answer = {
  status = Client_error Method_not_allowed;
  aheaders = Hashtbl.create 5 ;
  aprotocol = Protocol_1_0 ;
  content = 
    "<html>" ^ 
    "<head><title>Method Not Allowed<title></head>" ^
    "<body><h1>Method Not Allowed</h1></body>" ^
    "</html>" ;
  send_content = false;
}
;;

(* http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html *)
let string_of_answer answer =
  let protocol_str = string_of_protocol answer.aprotocol
  and status_code = code_of_status answer.status
  and status_str = string_of_status answer.status
  in
  let content_len = String.length answer.content
  in
  (* status code *)
  (* content-type *)
  (* content length *)
  (* etc.. *)
  ( Printf.sprintf "HTTP/%s %d %s\n" protocol_str status_code status_str ) ^ 
  ( Printf.sprintf "Content-Type: text/html\n" ) ^
  ( Printf.sprintf "Content-Length: %d\n" content_len ) ^
  ( "\n" ) ^
  ( if answer.send_content then answer.content else "" )

;;
