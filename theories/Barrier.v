Require Import Coq.Reals.Reals.
Require Import Coquelicot.Coquelicot.
Require Import Coq.micromega.Psatz.
Require Import Coq.Logic.Classical_Prop.
Require Import Coq.Logic.FunctionalExtensionality.

Section ODE.

  Variable state : NormedModule R_AbsRing.

  (* An ordinary differential inclusions is a predicate over
     derivatives and their variables. *)
  Definition ODI : Type := state -> state -> R -> Prop.

  (* A trajectory of the system is a mapping from time to state.
     We could restrict time to be nonegreal, but this probably makes
     most things messier. *)
  Definition trajectory : Type := R -> state.

  (* States that F is a solution to the ODI f with initial value x0. *)
  (* TODO: restate in terms of cauchy. *)
  Definition solution (f : ODI) (x0 : state) (F : trajectory) : Prop :=
    F 0 = x0 /\
    exists (D : R -> state),
    forall (t : R),
      is_derive F t (D t) /\
      (0 <= t -> f (D t) (F t) t).

  (* A barrier function maps states to scalars. *)
  Definition barrier : Type := state -> R.

  Definition derive_barrier (B : barrier) (dB : state -> state -> R) : Prop :=
    forall (F : trajectory) (D : R -> state) (t : R),
      is_derive F t (D t) ->
      is_derive (fun t => B (F t)) t (dB (D t) (F t)).

  (* If a system of ODEs has a solution, then that solution is continuous. *)
  Lemma solution_continuous :
    forall f x0 F,
      solution f x0 F ->
      forall t, continuous F t.
  Proof.
    intros. apply ex_derive_continuous. unfold solution in *.
    unfold ex_derive. destruct H. destruct H0. specialize (H0 t).
    exists (x t). tauto.
  Qed.

  (* The least upper bound of a closed set is contained in the set. *)
  Lemma lub_closed_in_set :
    forall (S : R -> Prop) (m : R),
      closed S -> is_lub S m -> S m.
  Proof.
    unfold closed, open, is_lub, locally, ball. simpl.
    unfold AbsRing_ball. intros. apply NNPP. intro. specialize (H _ H1).
    destruct H.
    assert (is_upper_bound S (m - x)).
    { unfold is_upper_bound in *. intros. apply Rnot_gt_le. intro.
      destruct (Rle_dec x0 m).
      { assert (~ S x0).
        { apply H. unfold abs, minus, plus, opp. simpl.
          rewrite Rabs_left; [ psatzl R | ]. destruct r.
          { psatzl R. }
          { intuition congruence. } }
        auto. }
      { assert (x0 <= m) by (apply H0; auto). psatzl R. } }
    assert (m <= m - x).
    { apply H0; auto. }
    destruct x. simpl in *. psatzl R.
  Qed.

  Require Import Coq.Classes.RelationClasses.
  Require Import Setoid Relation_Definitions.
  Require Import Coq.Reals.RIneq.
  Global Instance Reflexive_Rge : Reflexive Rge.
  Proof.
    red. intro. apply Req_ge. reflexivity.
  Qed.

  Global Instance Reflexive_Rle : Reflexive Rle.
  Proof.
    red. intro. apply Req_ge. reflexivity.
  Qed.
  Global Instance Transitive_Rge : Transitive Rge.
  Proof.
    red. intros. eapply Rge_trans; eauto.
  Qed.

  Global Instance Transitive_Rle : Transitive Rle.
  Proof.
    red. intros. eapply Rle_trans; eauto.
  Qed.

  Local Open Scope R.

  Add Parametric Relation : R Rle
      reflexivity proved by Rle_refl
      transitivity proved by Rle_trans
        as Rle_setoid_relation.

  Add Parametric Morphism : Rplus with
      signature Rle ++> Rle ++> Rle as Rplus_Rle_mor.
    intros ; apply Rplus_le_compat ; assumption.
  Qed.

  Add Parametric Morphism : Rminus with
      signature Rle ++> Rle --> Rle as Rminus_Rle_mor.
    intros ; unfold Rminus ;
      apply Rplus_le_compat;
      [assumption | apply Ropp_le_contravar ; assumption].
  Qed.

  Lemma exp_integral :
    forall (f df : R -> R) (a : R),
      (forall x, 0 <= x -> continuous df x) ->
      (forall x, is_derive f x (df x)) ->
      (forall x, 0 <= x -> df x <= a * f x) ->
      forall x, 0 <= x -> f x <= f 0 * exp (a * x).
  Proof.
    intros.
    assert (Derive (fun x : R => f x * exp (- a * x)) =
            fun x => df x*exp (-a*x) - (a*f x) * exp (-a*x))
      as HDerive.
    { apply functional_extensionality. intros.
      apply is_derive_unique. auto_derive.
      { unfold ex_derive. eauto. }
      { erewrite is_derive_unique; eauto. field. } }
    assert (forall x0,
               0 <= x0 ->
               continuous
                 (fun x1 : R =>
                    df x1*exp (-a*x1) - a*f x1 * exp (-a*x1)) x0)
      as Hcont.
    { intros. assert (continuous (fun x => exp (-a * x)) x0).
      { unfold continuous.
        rewrite <- (continuity_pt_filterlim
                      (fun x => exp (-a*x))).
        apply derivable_continuous. apply derivable_comp.
        { apply derivable_mult.
          { apply derivable_const. }
          { apply derivable_id. } }
        { apply derivable_exp. } }
      apply (continuous_minus
               (fun x => df x * exp (- a * x))
               (fun x => a * f x * exp (- a * x))).
      { apply (continuous_mult
                 (fun x => df x) (fun x => exp (-a * x))).
        { apply H. auto. }
        { auto. } }
      { apply (continuous_mult
                 (fun x => a * f x) (fun x => exp (-a * x))).
        { apply (continuous_mult (fun _ => a) f).
          { apply continuous_const. }
          { unfold continuous. apply (ex_derive_continuous f).
            unfold ex_derive. eauto. } }
        { auto. } } }
    assert (f x * exp (-a * x) - f 0 <= 0).
    { replace (f 0) with (f 0 * exp (-a * 0)).
      { rewrite <- (RInt_Derive (fun x => f x * exp (- a * x))).
        { replace 0 with (RInt (fun _ => 0) 0 x) at 2.
          { apply RInt_le; auto.
            { eexists. apply is_RInt_derive.
              { intros. apply Derive_correct. auto_derive.
                unfold ex_derive. eauto. }
              { intros. rewrite HDerive. apply Hcont.
                rewrite Rmin_left in *; psatzl R. } }
            { apply ex_RInt_const. }
            { intros. rewrite HDerive.
              apply Rle_minus. apply Rmult_le_compat_r.
              { left. apply exp_pos. }
              { apply H1. psatzl R. } } }
          { rewrite RInt_const. field. } }
        { intros. auto_derive. unfold ex_derive. eauto. }
        { intros. intros. rewrite HDerive. apply Hcont.
          rewrite Rmin_left in *; psatzl R. } }
      { rewrite Rmult_0_r. rewrite exp_0. field. } }
    { rewrite <- Ropp_mult_distr_l in H3. rewrite exp_Ropp in H3.
      apply Rminus_le in H3. apply Rle_div_l in H3.
      { assumption. }
      { apply exp_pos. } }
  Qed.

  Theorem barrier_exp_condition :
    forall (B : barrier) (dB : state -> state -> R),
      derive_barrier B dB ->
      (forall t x' x,
          continuous (fun t : R => dB (x' t) (x t)) t) ->
      forall (f : ODI) (x0 : state),
        B x0 <= 0 ->
        (exists a : R, forall (x' x : state) t,
              f x' x t -> dB x' x <= a * B x) ->
        forall (F : trajectory),
          solution f x0 F ->
          forall (t : R),
            0 <= t -> B (F t) <= 0.
  Proof.
    intros. destruct H2 as [a H2]. destruct H3. destruct H5.
    assert (B (F t) <= B (F 0) * exp (a * t)).
    { apply exp_integral
      with (f:=fun t => B (F t)) (df:=fun t => dB (x t) (F t)).
      { intros. apply H0. }
      { simpl. intros. apply H. apply H5. }
      { intros. eapply H2. eapply H5. assumption. }
      { assumption. } }
    pose proof (exp_pos (a * t)). subst. psatz R.
  Qed.

  Definition solution_sampled_data (f : state -> state -> state -> Prop) (u : state -> state)
             (F : trajectory) (T : R) : Prop :=
    exists (D : R -> state),
    (forall (t : R),
        is_derive F t (D t)) /\
    exists (sample : R -> R),
      (forall x, 0 <= x - sample x <= T) /\
      forall t : R, f (D t) (F t) (u (F (sample t))).

  Theorem barrier_exp_condition_sampled :
    forall (B : barrier) (dB : state -> state -> R),
      derive_barrier B dB ->
      (forall t x' x,
          continuous (fun t : R => dB (x' t) (x t)) t) ->
      forall (f : state -> state -> state -> Prop) (F : trajectory)
             (u : state -> state) (lambda T : R) (rel : state -> state -> Prop),
        solution_sampled_data f u F T ->
        (forall a b, 0 <= b - a <= T -> rel (F a) (F b)) ->
        (forall (x' x xb : state),
              rel xb x -> f x' x (u xb) -> dB x' x <= lambda * B x) ->
          forall (t : R),
            0 <= t -> B (F 0) <= 0 -> B (F t) <= 0.
  Proof.
    intros. unfold solution_sampled_data in *. destruct H1 as [D [? [sample ?]]].
    assert (B (F t) <= B (F 0) * exp (lambda * t)).
    { apply exp_integral
      with (f:=fun t => B (F t)) (df:=fun t => dB (D t) (F t)); auto.
      intros. eapply H3. 2: apply H6. apply H2. apply H6. }
    pose proof (exp_pos (lambda * t)). psatz R.
  Qed.

End ODE.