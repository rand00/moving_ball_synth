open Batteries

open Ball

let init () = 
  match SC.Server.run_script () with
  | false -> failwith "Ball: SuperCollider server (scsynth) failed to start."
  | true -> 
    let c = SC.Client.make () in
    let _ = at_exit (fun () -> SC.Client.quit_all c)
    in c 

let test_01 () =
  let freq_base = 
    if Array.length Sys.argv > 1 then 
      Int.of_string(Sys.argv.(1)) 
    else 300 
  in
  let c = init () in
  let s = s_sinew c 
  in
  while true do 
    match_xyz (read_line ()) 
    >>| (fun (x, y, z) -> 
        let x' = bounce_minval freq_base x 
        in S.set s [( "freq", `I x')]
      ) |> ignore
  done

type value = {
  min : float;
  max : float;
  out_min : float;
  out_max : float;
  prev : float;
}

type input_state = {
  x : value;
  y : value;
  z : value;
  i : int;
}

let set_min_max v_wrap v = {
  v_wrap with
  min = if v < v_wrap.min then v else v_wrap.min;
  max = if v > v_wrap.max then v else v_wrap.max
}

let map_range_3 st x y z = 
  let aux v_wrap v = 
    map_range 
      (v_wrap.min, v_wrap.max)
      (v_wrap.out_min, v_wrap.out_max)
      (x) 
  in 
  let x' = aux st.x x
  and y' = aux st.y y
  and z' = aux st.z z
  in (x', y', z')

let print_values st = 
  Printf.printf "X prev %f \t X min %f \t X max %f" st.x.prev st.x.min st.x.max;
  Printf.printf "Y prev %f \t Y min %f \t Y max %f" st.y.prev st.y.min st.y.max;
  Printf.printf "Z prev %f \t Z min %f \t Z max %f" st.z.prev st.z.min st.z.max

let rec loop st s =
  read_line () |> match_xyz
  |> function 
  | None -> loop st s
  | Some (x, y, z) -> 
    let x, y, z = (float x), (float y), (float z) in
    let st = { 
      st with
      x = set_min_max st.x x;
      y = set_min_max st.y y;
      z = set_min_max st.z z;
    } in
    let x', y', z' = map_range_3 st x y z 
    in
    let _ = S.set s [
        ("lfo_freq", `F x'); 
        ("freq", `F y'); 
        ("imp_freq", `F z')
      ] 
    in
    let _ = if st.i mod 40 = 0 then print_values st
    in
    let st = { 
      x = { st.x with prev = x' };
      y = { st.y with prev = y' };
      z = { st.z with prev = z' };
      i = succ st.i;
    } 
    in loop st s

let std_values = {
  min = 0.;
  max = 1.;
  out_min = 0.;
  out_max = 100.;
  prev = 0.;
}

let run_3_mapped_ranges () =
  let c = init () in
  let s = S.synth c "raw_grinder" [] in
  let st = {
    x = { std_values with out_min = 0.01; out_max = 300. };
    y = { std_values with out_min = 30.; out_max = 1100. };
    z = { std_values with out_min = 10.; out_max = 80. };
    i = 0;
  } 
  in loop st s



let () = run_3_mapped_ranges ()


