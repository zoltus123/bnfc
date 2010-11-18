{-
    BNF Converter: Generate main/test module for OCaml
    Copyright (C) 2005  Author:  Kristofer Johannisson

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

module CFtoOCamlTest where 

import CF
import Utils
import OCamlUtil

ocamlTestfile :: String -> String -> String -> String -> String -> CF -> String
ocamlTestfile absM lexM parM printM showM cf = 
    let 
        lexerName = lexM ++ ".token"
        parserName = parM ++ ".p" ++ topTypeC
        printerName = printM ++ ".printTree " ++ printM ++ ".prt" ++ topTypeC
        showFun = "(fun x -> " ++ showM ++ ".show (" ++ showM ++ ".show" ++ 
                  topTypeC ++ " x))"
        topTypeC = fixTypeUpper (firstEntry cf)
        topType = absM ++ "." ++ fixType (firstEntry cf)
    in unlines [
        "(* automatically generated by the BNF Converter *)",
        "",
        "open Lexing",
        "",
        "let parse (c : in_channel) : " ++ topType ++ " = ",
        "    " ++ parserName +++ lexerName +++ "(Lexing.from_channel c)",
        ";;",
        "",
        "let showTree (t : " ++ topType ++ ") : string = ",
        "    \"[Abstract syntax]\\n\\n\" ^ " ++ showFun +++ "t" ++ " ^ \"\\n\\n\" ^", 
        "    \"[Linearized tree]\\n\\n\" ^ " ++ printerName +++ "t" ++ " ^ \"\\n\"",
        ";;",
        "",
        "let main () =",
        "    let channel =",
        "      if Array.length Sys.argv > 1 then",
        "        open_in Sys.argv.(1)",
        "      else",
        "        stdin",
        "    in",
        "    try",
        "        print_string (showTree (parse channel));",
        "        flush stdout",
        "    with BNFC_Util.Parse_error (start_pos, end_pos) ->", -- " ++ parM ++ ".
        "        Printf.printf \"Parse error at %d.%d-%d.%d\\n\"",
        "            start_pos.pos_lnum (start_pos.pos_cnum - start_pos.pos_bol)",
        "            end_pos.pos_lnum (end_pos.pos_cnum - end_pos.pos_bol);",
        ";;",
        "",
        "main ();;",
        ""
        ]


