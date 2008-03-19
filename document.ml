
type url = string
type text = string

type richtext = 
        | Bold of richtext
        | Italic of richtext
        | Underline of richtext
        | Strike of richtext


type expr = 
        | Link of (url * richtext)
        | Image of url

               
type t = expr list

let create () = 
        []

let delete docname = 
        ()

