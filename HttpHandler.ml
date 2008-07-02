(* vim: set ts=2 sw=2 et : *)

(* open WikiEngine;; *)

let debug = true
;;

type urlhandler_t =
  | Edit
  | View
;;


let string_from_urlhandler = function
  | Edit -> "edit"
  | View -> "view"
;;


let urlhandler_from_action = function
  | WikiEngine.Get_text -> Edit
  | WikiEngine.Set_text _ -> Edit
  | WikiEngine.Insert_text (_,_) -> Edit (* FIXME *)
  | WikiEngine.Remove_text (_,_) -> Edit (* FIXME *)
  | WikiEngine.Get_tree -> View (* FIXME *)
;;


let urlhandler_from_string = function
  | "view" -> View
  | "edit" -> Edit
  | _ -> urlhandler_from_action WikiEngine.default_action
;;



let get_action_from_urlhandler = function
  | View -> (* htmlview_of_text *) WikiEngine.Get_text
  | Edit -> (* htmledit_of_text *) WikiEngine.Get_text
;;

let post_action_from_urlhandler text = function
  | View -> (* htmlview_of_text *) WikiEngine.Get_text
  | Edit -> WikiEngine.Set_text text
;;


let url_clean location = 
  (* FIXME: fill the url_clean function *)
  (* x//y => /y *)
  (* .. => not allowed (we are not in a classical webserver *)
  (* allowed URL patterns : 
    
    URL := 
      DIRECTORY SLASH METHOD

    DIRECTORY := 
      | SLASH
      | SLASH WIKINAME
      | DIRECTORY SLASH WIKINAME 

    WIKINAME :=
      /[A-Z][a-z0-9]x([A-Z][a-z0-9]x)x/ where x is *

    METHOD :=
      | "view"
      | "post"
      | "edit"

    SLASH :=
      "/"

    *)
  location
  ;;



let page_from_request request =
  Printf.printf "page_from_request( %s )\n" 
    (HttpRequest.string_of_request request );
  let filter_page page = 
    match page with
    | "" -> WikiEngine.default_page
    | _ -> page
  in
  match request.HttpTypes.location with
  | "/" -> WikiEngine.default_page
  | pg -> 
      let len = String.length pg
      in 
      if len > 1 then 
        filter_page ( String.sub pg 1 (len -1) )
      else
        WikiEngine.default_page
;;


let action_from_request request =
  let request_str = HttpRequest.string_of_request request 
  in
  Printf.printf "action_from_request( %s )\n" request_str ;
  (* match the last ~/[a-z]$~ *)
  (*
  match request.HttpTypes.location with
  | [] -> default_action
  | _::pg_tail -> 
      match pg_tail with
      | [] -> default_action
      | uh::_ ->
          match request.HttpTypes.rmethod with
          | HttpTypes.Head -> 
              get_action_from_urlhandler (urlhandler_from_string uh)
          | HttpTypes.Get -> 
              get_action_from_urlhandler (urlhandler_from_string uh)
          | HttpTypes.Post -> 
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
          | HttpTypes.Put ->
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
          | HttpTypes.Delete ->
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
              *)
  ignore request ;
  WikiEngine.default_action
;;


let string_of_wikirequest wikirequest =
 (* Printf.sprintf "link=[%s] page=[%s] action=..." 
    wikirequest.WikiEngine.link 
    wikirequest.page *)
 ignore wikirequest ;
 "(FIXME: string_of_wikirequest...)"
;;

let wikirequest_from_request request = 
  Printf.printf "wikirequest_from_request( ... )\n" ;
  { 
    WikiEngine.link = request ;
    page = page_from_request request ;
    action = action_from_request request ;
  }
;;


(* 
 * is there an action available for this request ?
 *)
let wikicontent_title_from_wikirequest wikirequest =
  Printf.printf "wikicontent_title_from_wikirequest( ... )\n" ;
  let unsupported_action =
    Printf.sprintf "Unsupported action for \"%s\" on page \"%s\"" 
    ( WikiEngine.string_of_action wikirequest.WikiEngine.action )
    wikirequest.WikiEngine.page
  in
  match wikirequest.WikiEngine.action with
  (* | WikiEngine.Get_html -> 
      if not ( WikiEngine.is_empty wikirequest.WikiEngine.page ) then wikirequest.WikiEngine.page
      else "Unknown page " ^ wikirequest.WikiEngine.page *)
  | WikiEngine.Get_text -> Printf.sprintf "%s (editing)" wikirequest.WikiEngine.page
  | WikiEngine.Get_tree -> unsupported_action
  | WikiEngine.Set_text _ -> unsupported_action
  | WikiEngine.Insert_text (_, _) -> unsupported_action
  | WikiEngine.Remove_text (_, _) -> unsupported_action
;;


let wikicontent_header_from_wikirequest wikirequest = 
  Printf.printf "wikicontent_header_from_wikirequest( ... )\n" ;
  "    <title>"^ (wikicontent_title_from_wikirequest wikirequest ) ^ "</title>\n"
;;


let wikicontent_body_from_wikirequest wikirequest =
  Printf.printf "wikicontent_body_from_wikirequest( ... )\n" ;
  let body_view_fmt = (
    "%s\n" ^^ "<a href=\"/%s/edit\">Edit</a>\n" )
  and body_edit_fmt = ( 
    "<form action=\"/%s/edit\" method=\"post\" >\n" ^^
    "<textarea name=\"content\">%s</textarea><br />\n" ^^
    "<input type=\"submit\" value=\"save\" >\n" ^^
    "<input type=\"submit\" value=\"preview\" >\n" ^^
    "<input type=\"button\" value=\"cancel\" >\n" ^^
    "</form>\n" )
  and body_unknown_fmt = ( "Page %s does not exist.\n" ^^ "" )
  in

  let wiki_html () = 
    if not ( WikiEngine.is_empty wikirequest.WikiEngine.page ) then 
      WikiEngine.handle_request wikirequest
    else 
      Printf.sprintf body_unknown_fmt wikirequest.WikiEngine.page
  and wiki_raw () =
    if not ( WikiEngine.is_empty wikirequest.WikiEngine.page ) then 
      WikiEngine.handle_request wikirequest
    else 
      "Write here the content of page " ^ wikirequest.WikiEngine.page
  in

  match wikirequest.WikiEngine.action with
  (* | WikiEngine.Get_html -> Printf.sprintf body_view_fmt ( wiki_html () )
   * wikirequest.WikiEngine.page *)
  | WikiEngine.Get_text -> Printf.sprintf body_edit_fmt wikirequest.WikiEngine.page ( wiki_raw () )
  | WikiEngine.Get_tree -> Printf.sprintf body_edit_fmt wikirequest.WikiEngine.page ( wiki_raw () )
  | WikiEngine.Set_text _ -> Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WikiEngine.page
  | WikiEngine.Insert_text (_, _) -> Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WikiEngine.page
  | WikiEngine.Remove_text (_, _) ->Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WikiEngine.page
;;


let wikicontent_from_wikirequest wikirequest = 
  Printf.printf "wikicontent_from_wikirequest( %s )\n" 
    (string_of_wikirequest wikirequest)
  ;
  "<html>\n" ^ 
  "  <head>\n" ^
  wikicontent_header_from_wikirequest wikirequest ^
  "  </head>\n" ^
  "  <body>\n" ^
  wikicontent_body_from_wikirequest wikirequest ^
  "  </body>\n" ^
  "</html>\n"
;;


(* Handler for HTTP GET requests *)
let get_handler request =
  let request_str = HttpRequest.string_of_request request 
  in 
  Printf.printf "get_handler( %s )\n" request_str ;
  let wikirequest = wikirequest_from_request request
  in
  let wikicontent = wikicontent_from_wikirequest wikirequest
  in
 (* let wikianswer = handle_request wikirequest
  in *)
  (* convert request to wikirequest *)
  (* 
  let ( filtered_page, filtered_action ) =
    pageaction_from_request request
  in *)
  { HttpAnswer.default_answer with
    HttpTypes.status = HttpTypes.Success HttpTypes.Ok ;
    HttpTypes.aprotocol = request.HttpTypes.rprotocol ; 
    HttpTypes.send_content = true ;
    HttpTypes.content = wikicontent ; (* "Wiki got a GET request for " ^
    wikirequest.page ^ ":" ^ 
    ( string_of_action wikirequest.action ) *)
  }
;;


(* Handler for HTTP HEAD requests *)
let head_handler request = 
  Printf.printf "head_handler( ... )\n" ;
  let get_answer = get_handler request
  in
  { get_answer with
    HttpTypes.send_content = false
  }
;;


(* Handler for HTTP POST requests *)
let post_handler request =
  Printf.printf "post_handler( ... )\n" ;
  let post_answer = get_handler request
  in 
  post_answer
;;


