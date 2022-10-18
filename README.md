# coq-control-theory
Formalization of some results from control theory in Coq

# Setup Notes

The Coq packages have a very narrow dependency overlap of Coq 8.5.3 to Coq 8.6.0.

The newest stable OCaml compiler supporting 8.5.3 is 4.04.2, which is somewhat old at this point. (It's noted that we tried removing the version upperbound using `opam pin --edit \<pkg\>` and package compilation failed due to backing OCaml/ML mismatch. The version cannot aribtrarily be moved forward without some work)

The following section creates a passable Ubuntu/OCaml/Coq envoirnment to satisfy dependencies. 

# Ubuntu Setup

1. `apt install opam z3 coinor-csdp`
2. `apt install libgmp-dev libcairo2-dev libexpat1-dev libgtk2.0-dev libgtksourceview2.0-dev libgtk-3-dev libgtksourceview-3.0-dev`
3. `opam init`
4. `eval $(opam env)
5. `opam swtich create coq-8.6 4.04.2
6. `opam switch coq-8.6`
7. `eval $(opam env)`
8. `opam repo add coq-released https://coq.inria.fr/opam/released`
9. `eval $(opam env)`
10. `opam install coqide coq-coquelicot coq-charge-core coq-smt-check`
11. `eval $(opam env)`
