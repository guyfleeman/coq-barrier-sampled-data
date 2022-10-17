# coq-control-theory
Formalization of some results from control theory in Coq

# Ubuntu Setup

1. `apt install opam libgmp-dev libcairo2-dev libexpat1-dev libgtk2.0-dev libgtksourceview2.0-dev libgtk-3-dev libgtksourceview-3.0-dev`
2. `opam init`
3. `eval $(opam env)
4. `opam repo add coq-released https://coq.inria.fr/opam/released`
5. `eval $(opam env)`
6. `opam install coqide coq-coquelicot coq-charge-core`
7. verify `opam show coqide` reports version 8.9.1
8. verify `opam show coq-smt-check` reports version range 8.5 to 8.6~
9. `opam pin --edit coq-plugin-utils 1.3.0`
10. remove version upper bound
9. `opam pin --edit coq-smt-check 2.0.0`
10. modify `"coq" {>= "8.5" & < "8.6~"}` to `"coq" {>= "8.5" & < "8.10~"}`
11. write the buffer
