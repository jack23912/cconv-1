(*
 * CSexp - interface to Sexplib
 * Copyright (C) 2014 Simon Cruanes
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

type 'a or_error = [ `Ok of 'a | `Error of string ]

type t =
  [ `Atom of string
  | `List of t list
  ]

let source =
  let module D = CConv.Decode in
  let rec src = {D.emit=fun dec s -> match s with
    | `Atom s -> dec.D.accept_string src s
    | `List l -> dec.D.accept_list src l
  } in
  src

let output =
  let module E = CConv.Encode in
  { E.unit = `List [];
    bool = (fun b -> `Atom (string_of_bool b));
    float = (fun f -> `Atom (string_of_float f));
    char = (fun x -> `Atom (String.make 1 x));
    nativeint = (fun i -> `Atom (Nativeint.to_string i));
    int32 = (fun i -> `Atom (Int32.to_string i));
    int64 = (fun i -> `Atom (Int64.to_string i));
    int = (fun i -> `Atom (string_of_int i));
    string = (fun s -> `Atom (String.escaped s));
    option = (function None -> `List[] | Some x -> `List [x]);
    list = (fun l -> `List l);
    record = (fun l -> `List (List.map (fun (a,b) -> `List [`Atom a; b]) l));
    tuple = (fun l -> `List l);
    sum = (fun name l -> match l with
      | [] -> `Atom name
      | _::_ -> `List (`Atom name :: l));
  }

let encode src x = CConv.encode src output x

let decode dec x = CConv.decode source dec x

let decode_exn dec x = CConv.decode_exn source dec x
