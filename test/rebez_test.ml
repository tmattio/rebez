let id x = x;;

Random.self_init ()

let assert_message cond message =
  assert (
    if not cond then print_endline message;
    cond)

let assert_raises f =
  let res =
    try
      ignore (f ());
      false
    with _ -> true
  in
  assert res

let assert_close precision a b message =
  assert_message (abs_float (a -. b) < precision) message

let all_equals ?(assertion = assert_close 0.000001) be1 be2 samples =
  for i = 0 to samples do
    let x = float_of_int i /. float_of_int samples in
    assertion (be1 x) (be2 x) ("comparing " ^ " for value " ^ string_of_float x)
  done

let repeat n f =
  for i = 0 to n - 1 do
    f i
  done
;;

assert_raises (fun () -> Rebez.make 0.5 0.5 (-5.) 0.5);;

assert_raises (fun () -> Rebez.make 0.5 0.5 5. 0.5);;

assert_raises (fun () -> Rebez.make (-2.) 0.5 0.5 0.5);;

assert_raises (fun () -> Rebez.make 2. 0.5 0.5 0.5);;

all_equals (Rebez.make 0. 0. 1. 1.) (Rebez.make 1. 1. 0. 0.) 100;;

all_equals (Rebez.make 0. 0. 1. 1.) id 100;;

repeat 1000 (fun _ ->
    let a = Random.float 1.0 in
    let b = (2. *. Random.float 1.0) -. 0.5 in
    let c = Random.float 1.0 in
    let d = (2. *. Random.float 1.0) -. 0.5 in
    let easing = Rebez.make a b c d in
    assert_message
      (easing 0. = 0.)
      ("(0) should be 0." [@reason.raw_literal "(0) should be 0."]);
    assert_message
      (easing 1. = 1.)
      ("(1) should be 1." [@reason.raw_literal "(1) should be 1."]))
;;

repeat 1000 (fun _ ->
    let a = Random.float 1.0 in
    let b = Random.float 1.0 in
    let c = Random.float 1.0 in
    let d = Random.float 1.0 in
    let easing = Rebez.make a b c d in
    let projected = Rebez.make b a d c in
    let composed x = projected (easing x) in
    all_equals ~assertion:(assert_close 0.05) id composed 100)
;;

repeat 100 (fun _ ->
    let a = Random.float 1.0 in
    let b = (2. *. Random.float 1.0) -. 0.5 in
    let c = Random.float 1.0 in
    let d = (2. *. Random.float 1.0) -. 0.5 in
    all_equals (Rebez.make a b c d) (Rebez.make a b c d) 100)
;;

repeat 100 (fun _ ->
    let a = Random.float 1.0 in
    let b = (2. *. Random.float 1.0) -. 0.5 in
    let c = 1. -. a in
    let d = 1. -. b in
    let easing = Rebez.make a b c d in
    let easing_zero_point_five = easing 0.5 in
    assert_close 0.01 easing_zero_point_five 0.5
      ("(0.5) should be 0.5, was "
      ^ string_of_float easing_zero_point_five
      ^ ", with a: " ^ string_of_float a ^ ", b: " ^ string_of_float b ^ ", c: "
      ^ string_of_float c ^ ", d: " ^ string_of_float d))
;;

repeat 100 (fun _ ->
    let a = Random.float 1.0 in
    let b = (2. *. Random.float 1.0) -. 0.5 in
    let c = 1. -. a in
    let d = 1. -. b in
    let easing = Rebez.make a b c d in
    let sym x = 1. -. easing (1. -. x) in
    all_equals ~assertion:(assert_close 0.01) easing sym 100)

let easing = Rebez.make 0. 0.99 0. 0.99

let x = 0.01;;

assert_close 0.000001 (easing 0.01) 0.512011914581
  "Rebez.make(0., 0.99, 0., 0.99, 0.01) should be roughly 0.512011914581"
