
open Batteries

module S = SC.Synth

let sleep t = Lwt_main.run (Lwt_unix.sleep t)

(**Functions for reading input*)

(**matching on text-output from 'imu'*)
let match_xyz s = 
  let int = Int.of_string in
  match s with
  | <:re< [" \t"]* 
     "X: " (["0"-"9""-"]+ as x) " " 
     "Y: " (["0"-"9""-"]+ as y) " " 
     "Z: " (["0"-"9""-"]+ as z) 
    >> -> Some (int x, int y, int z)
  | _ -> None

let read_next () =
  let open IO in
  let b = Buffer.create 25 
  and stop = ref false in
  let looking_for = function 
    |'X'..'Z'|':'|' '|'0'..'9'|'-' -> true 
    | _ -> false in
  while not !stop do
    let c_opt = try Some (read stdin) with _ -> None in
    match c_opt with
    | Some c -> 
      if looking_for c then
        Buffer.add_char b c
      else 
        stop := true
    | None -> stop := true
  done;
  Buffer.contents b

(**For handling a potential flow of side-effecting func's*)
let ( >>= ) = Option.bind
and ( >>| ) x f = Option.map f x


(**Functions for handling synths *)

let s_sinew c = S.synth c "sinew" [] 

let set_freq s v = S.set s [("freq", `I v)]

(**Functions for manipulating input-values *)

let apply_x f (x, _, _) = f x

let bounce_minval n x = if x < n then (Int.abs (x-n)) + n else x

(*gomaybe make some more tests (min != max)*)
let map_range (xmin, xmax) (ymin, ymax) x = 
  if x < xmin || x > xmax then
    Printf.printf 
      "Ball: map_range: The input-value, %f, exceeded the \
       input-range from %f to %f.\n" 
      x xmin xmax;
  if xmin +. 0.0001 >= xmax then 
    ymin
  else
    let range_x = xmax -. xmin in
    let x_pct = (x -. xmin) /. range_x 
    in
    let range_y = ymax -. ymin in
    let y = (x_pct *. range_y) +. ymin 
    in y


(**Tests*)

let test_x = function 
    Some v -> Printf.printf "mapped x: %d\n" v
  | None -> print_endline "failed input"

let test = function
  | Some (x, y, z) -> Printf.printf "x = %d, y = %d, z = %d\n" x y z
  | None -> print_endline "No values were found"






