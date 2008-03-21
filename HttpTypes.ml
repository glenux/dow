(* vim: set ts=2 sw=2 et : *)

exception Unknown_method of string;;

exception Unknown_protocol of string;;

exception Invalid_request of string;;

type status_information_t =
  | Continue
  | Switching_protocols
;;

type status_success_t = 
  | Ok
  | Created
  | Accepted
  | NonAuthoritative_information
  | No_content
  | Reset_content
  | Partial_content
;;

type status_redirection_t =
  | Multiple_Choices
  | Moved_Permanently
  | Found
  | See_Other
  | Not_Modified
  | Use_Proxy
  | Temporary_Redirect
;;

type status_clienterror_t =
  | Bad_request
  | Unauthorized
  | Payment_required
  | Forbidden
  | URI_Not_found
  | Method_not_allowed
  | Not_acceptable
  | Proxy_authentication_required
  | Request_timeout
  | Conflict
  | Gone
  | Length_required
  | Precondition_failed
  | Request_entity_too_large
  | Request_URI_too_long
  | Unsupported_media_type
  | Requested_range_not_satisfiable
  | Expectation_failed
;;

type status_servererror_t =
  | Internal_server_error
  | Not_implemented
  | Bad_gateway
  | Service_unavailable
  | Gateway_timeout
  | HTTP_version_not_supported
;;

(* http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html *)
type status_t =
  | Informational of status_information_t
  | Success of status_success_t
  | Redirection of status_redirection_t
  | Client_error of status_clienterror_t
  | Server_error of status_servererror_t
;;


type protocol_t =
  | Protocol_1_0
  | Protocol_1_1
;;


type method_t =
  | Get
  | Post
  | Put
  | Delete
  | Head
;;


type request_t = {
 rmethod : method_t ; (* don't forget the 'x' prefix... *)
 location : string ;
 rprotocol : protocol_t ;
 rheaders: string StringMap.t ;
 post: string StringMap.t ;
 get: string StringMap.t ;
}
;;


type answer_t = {
  status: status_t ;
  aheaders : string StringMap.t ;
  aprotocol : protocol_t ;
  content : string ;
}
;;

let string_of_status status = 
  match status with
  | Informational _ ->  "info"
  | Success _ ->  "success"
  | Redirection _ -> "redir"
  | Client_error _ -> "client-error"
  | Server_error _ -> "server-error"
;;

let code_of_status status = 
  match status with
  | Informational sub -> 100 + (
    match sub with
    | Continue -> 0
    | Switching_protocols -> 1 )
  | Success sub -> 200 + ( 
    match sub with
    | Ok -> 0
    | Created -> 1
    | Accepted -> 2
    | NonAuthoritative_information -> 3
    | No_content -> 4
    | Reset_content -> 5
    | Partial_content -> 6 )
  | Redirection sub -> 300 + ( 
    match sub with
    | Multiple_Choices -> 0
    | Moved_Permanently -> 1
    | Found -> 2
    | See_Other -> 3
    | Not_Modified -> 4
    | Use_Proxy -> 5
    | Temporary_Redirect -> 6 )
  | Client_error sub -> 400 + (
    match sub with
    | Bad_request -> 0
    | Unauthorized -> 1
    | Payment_required -> 2
    | Forbidden -> 3
    | URI_Not_found -> 4
    | Method_not_allowed -> 5
    | Not_acceptable -> 6
    | Proxy_authentication_required -> 7
    | Request_timeout -> 8 
    | Conflict -> 9 
    | Gone -> 10
    | Length_required -> 11
    | Precondition_failed -> 12
    | Request_entity_too_large -> 13
    | Request_URI_too_long -> 14
    | Unsupported_media_type -> 15
    | Requested_range_not_satisfiable -> 16
    | Expectation_failed -> 17 )
  | Server_error sub -> 500 + ( 
    match sub with
    | Internal_server_error -> 0
    | Not_implemented -> 1
    | Bad_gateway -> 2
    | Service_unavailable -> 3
    | Gateway_timeout -> 4
    | HTTP_version_not_supported -> 5 )
;;


let string_of_protocol protocol =
  match protocol with
  | Protocol_1_0 -> "1.0"
  | Protocol_1_1 -> "1.1"
;;

let protocol_of_string protocol_str = 
  match protocol_str with
  | "1.0" -> Protocol_1_0
  | "1.1" -> Protocol_1_1
  | _ -> raise ( Unknown_protocol protocol_str )
;;

