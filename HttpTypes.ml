(* vim: set ts=2 sw=2 et : *)

(** This module provides the basic types and operations for the HTTP components. *)


(** {2 Exceptions} *)


(** the {! Unknown_method} exception is raised when receiving an invalid HTTP request
 *)
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
  | Multiple_choices
  | Moved_permanently
  | Found
  | See_other
  | Not_modified
  | Use_proxy
  | Temporary_redirect
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
 location : string list ;
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
  send_content : bool ;
  content : string ;
}
;;


(**
 @param status an HTTP status
 *)
let string_of_status status = 
  match status with
  | Informational sub -> (
    match sub with
    | Continue -> "Continue"
    | Switching_protocols -> "Switching Protocols" )
  | Success sub -> ( 
    match sub with
    | Ok -> "Ok"
    | Created -> "Created"
    | Accepted -> "Accepted"
    | NonAuthoritative_information -> "Non-Authoritative Information"
    | No_content -> "No Content"
    | Reset_content -> "Reset Content"
    | Partial_content -> "Partial Content" )
  | Redirection sub -> ( 
    match sub with
    | Multiple_choices -> "Multiple Choices"
    | Moved_permanently -> "Moved Permanently"
    | Found -> "Found"
    | See_other -> "See Other"
    | Not_modified -> "Not Modified"
    | Use_proxy -> "Use Proxy"
    | Temporary_redirect -> "Temporary Redirect" )
  | Client_error sub -> (
    match sub with
    | Bad_request -> "Bad Request"
    | Unauthorized -> "Unauthorized"
    | Payment_required -> "Payment Required"
    | Forbidden -> "Forbidden"
    | URI_Not_found -> "Not Found"
    | Method_not_allowed -> "Method Not Allowed"
    | Not_acceptable -> "Not Acceptable"
    | Proxy_authentication_required -> "Proxy Authentication Required"
    | Request_timeout -> "Request Timeout"
    | Conflict -> "Conflict"
    | Gone -> "Gone"
    | Length_required -> "Length Required"
    | Precondition_failed -> "Precondition Failed"
    | Request_entity_too_large -> "Request Entity Too Large"
    | Request_URI_too_long -> "Request URI Too Long"
    | Unsupported_media_type -> "Unsupported Media Type"
    | Requested_range_not_satisfiable -> "Requested Range Not Satisfiable"
    | Expectation_failed -> "Expectation Failed" )
  | Server_error sub -> ( 
    match sub with
    | Internal_server_error -> "Internal Server Error"
    | Not_implemented -> "Not Implemented"
    | Bad_gateway -> "Bad Gateway"
    | Service_unavailable -> "Service Unavailable"
    | Gateway_timeout -> "Gateway Timeout"
    | HTTP_version_not_supported -> "HTTP Version Not Supported" )

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
    | Multiple_choices -> 0
    | Moved_permanently -> 1
    | Found -> 2
    | See_other -> 3
    | Not_modified -> 4
    | Use_proxy -> 5
    | Temporary_redirect -> 6 )
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

