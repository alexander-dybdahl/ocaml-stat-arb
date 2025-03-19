open Csv

(* Read CSV data and extract closing prices *)
let read_csv filename =
  let rows = Csv.load filename in
  List.map (fun row ->
    let date = List.nth row 0 in
    let close_price = float_of_string (List.nth row 4) in
    (date, close_price)
  ) rows

(* Calculate momentum signal for stock prices *)
let calculate_momentum_signal prices n =
  let rec momentum_signal prices n acc =
    match prices with
    | [] | [_] -> List.rev acc  (* End condition for the list *)
    | (date1, price1)::(date2, price2)::tail when List.length acc >= n ->
        let change = (price2 -. price1) /. price1 *. 100.0 in  (* Percentage change *)
        (* Only pass the prices in the recursion; ignore the date *)
        momentum_signal ((date2, price2)::tail) n (change::acc)
    | _::t -> momentum_signal t n acc  (* Skip the first few until we have enough data *)
  in momentum_signal prices n []

(* Backtest the signal by simulating a trading strategy *)
let backtest_signal prices signal =
  let rec aux prices signal balance =
    match prices, signal with
    | [], _ | _, [] -> balance  (* No more data to process *)
    | (_, price)::tail, signal_value::signal_tail ->
        let new_balance = if signal_value > 0.0 then balance +. price else balance -. price in
        aux tail signal_tail new_balance
  in aux prices signal 1000.0  (* Starting balance = 1000 USD *)

(* Main program execution *)
let () =
  let data = read_csv "apple_stock_data.csv" in
  let n = 3 in  (* Look at the last 3 days for momentum *)
  let momentum_signal = calculate_momentum_signal data n in
  let final_balance = backtest_signal data momentum_signal in
  Printf.printf "Final balance: %.2f\n" final_balance
