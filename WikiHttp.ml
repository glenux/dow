(* vim: set ts=2 sw=2 et : *)

type handler_t =
  | EditPost
  | EditGet
  | View
;;


let read_string sock = 
  let strlen = 1024 in
  let strbuf = String.make strlen '\000' in
  let _ = Unix.recv sock strbuf 0 strlen [] in
  strbuf
;;


let get_handler request =
  ignore request ;
  { HttpAnswer.default_answer with
    HttpTypes.status = HttpTypes.Success HttpTypes.Ok ;
    HttpTypes.aprotocol = request.HttpTypes.rprotocol ; 
    HttpTypes.send_content = true ;
    HttpTypes.content = "Wiki got request!" 
  }
;;


let post_handler request =
  ignore request ;
  HttpAnswer.default_answer
;;


(*
let html_from_request request =
  let page_from_request request =
    try 
      Scanf.sscanf request.HttpTypes.location "/%[a-zA-Z]" 
      (function
       | "" -> WikiEngine.homepage
       | page_str -> page_str )
    with
    | End_of_file ->  
        Printf.printf "<-- HTTP.WIKIDATA2: EOF [%s]\n" request.HttpTypes.location;
        flush stdout ;
        WikiEngine.homepage
    | Scanf.Scan_failure _ -> 
        Printf.printf "<-- WIKI.WIKIDATA2: Invalid page [%s]\n" request.location ;
        flush stdout ;
        WikiEngine.homepage
  in

  let page_handler_from_request request = 
    try 
      Scanf.sscanf request.location "/%[a-zA-Z]/%[a-z]" 
      (fun page_str -> 
        fun handler_str -> 
          ( page_str, handler_str ))
    with
    | End_of_file -> 
        ( page_from_request request, "view" )
    | Scanf.Scan_failure _ -> 
        Printf.printf "<-- WIKI.WIKIDATA1: Invalid page [%s]\n" request.location ;
        flush stdout ;
        ( WikiEngine.homepage, "view" )
  in

  let ( wiki_page, wiki_handler_str ) = 
    page_handler_from_request request
  in

  let wiki_action = 
    match wiki_handler_str with
    | "view" -> WikiEngine.Html
    | "edit" -> 
        if request.xmethod = Get then WikiEngine.Raw
        else WikiEngine.Change "blabla"
    | _ -> WikiEngine.Html

  in

  let wiki_has_page = not ( WikiEngine.is_empty wiki_page )
  in

  let title_html =
    let title_str =
      match wiki_action with
      | WikiEngine.Html -> 
          if wiki_has_page then wiki_page
          else "Unknown page " ^ wiki_page
      | WikiEngine.Raw -> Printf.sprintf "%s (editing)" wiki_page
      | WikiEngine.Change _ -> wiki_page
      | WikiEngine.Insert (_, _) -> wiki_page
    in 
    Printf.sprintf "<h1>%s</h1>" title_str
  in

  let body_html =
    let body_view_fmt = (
      "%s\n" ^^ "<a href=\"/%s/edit\">Edit</a>\n" )
    and body_edit_fmt = ( 
      "<form action=\"/%s/edit\" method=\"post\" >\n" ^^
      "<textarea name=\"content\">%s</textarea>\n" ^^
      "<input type=\"submit\" value=\"save\" >\n" ^^
      "<input type=\"submit\" value=\"preview\" >\n" ^^
      "<input type=\"button\" value=\"cancel\" >\n" ^^
      "</form>\n" )
    and body_unknown_fmt = ( "Page %s does not exist.\n" ^^ "" )
    in

    let wiki_html () = 
      if wiki_has_page then WikiEngine.handle wiki_page wiki_action
      else Printf.sprintf body_unknown_fmt wiki_page
    and wiki_raw () =
      if wiki_has_page then WikiEngine.handle wiki_page wiki_action
      else "Write here the content of page " ^ wiki_page
    in

    match wiki_action with
    | WikiEngine.Html -> Printf.sprintf body_view_fmt ( wiki_html () ) wiki_page
    | WikiEngine.Raw -> Printf.sprintf body_edit_fmt wiki_page ( wiki_raw () )
    | WikiEngine.Change _ -> Printf.sprintf body_view_fmt ( wiki_html () ) wiki_page
    | WikiEngine.Insert (_, _) -> Printf.sprintf body_view_fmt ( wiki_html () ) wiki_page
  in

  (* send_string client_sock  *)
  Printf.sprintf "<html><body>%s%s</body></html>" title_html body_html
;;
*)

