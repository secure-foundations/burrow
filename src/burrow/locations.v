From iris.algebra Require Export cmra.
From iris.algebra Require Import proofmode_classes.
From iris.prelude Require Import options.
Require Import Burrow.CpdtTactics.

From stdpp Require Import gmap.
From stdpp Require Import mapset.
From stdpp Require Import sets.
From stdpp Require Import list.
Require Import Burrow.gmap_utils.
Require Import Burrow.rollup.
Require Import Burrow.indexing.

(*Context {M: Type} `{!EqDecision M, !TPCM M}.
Context `{Countable RefinementIndex}.
Context `{EqDecision RefinementIndex}.
Context (ref_map : RefinementIndex -> Refinement M M).*)

Class RefinementIndex (M: Type) `{!EqDecision M} `{!TPCM M} (RI: Type) := {
    refinement_of : RI -> Refinement M M;
    triv_ri : RI;
    left_ri : RI;
    right_ri : RI;
    pair_up : M -> M -> M;
}.
Global Arguments triv_ri {M}%type_scope {EqDecision0 TPCM0} _ {RefinementIndex}.
Global Arguments left_ri {M}%type_scope {EqDecision0 TPCM0} _ {RefinementIndex}.
Global Arguments right_ri {M}%type_scope {EqDecision0 TPCM0} _ {RefinementIndex}.
Global Arguments pair_up {M}%type_scope {EqDecision0 TPCM0} _%type_scope {RefinementIndex} _ _.

Inductive Loc (RI: Type) `{!EqDecision RI, !Countable RI} :=
  | BaseLoc : nat -> Loc RI
  | ExtLoc : nat -> RI -> Loc RI -> Loc RI
  | CrossLoc : Loc RI -> Loc RI -> Loc RI
.
Arguments BaseLoc _%type_scope {EqDecision0 Countable0} _%nat_scope.
Arguments ExtLoc {RI}%type_scope {EqDecision0 Countable0} _%nat_scope _ _.
Arguments CrossLoc {RI}%type_scope {EqDecision0 Countable0} _ _.

Global Instance loc_eqdec RI `{!EqDecision RI} `{!Countable RI} : EqDecision (Loc RI).
Proof. solve_decision. Defined.

Global Instance loc_countable RI `{!EqDecision RI} `{!Countable RI} : Countable (Loc RI). Admitted.

Definition nat_of_extstep {RI} `{!EqDecision RI, !Countable RI} (alpha:nat) (ri: RI) : nat.
Admitted.

Definition nat_of_basestep RI `{!EqDecision RI, !Countable RI} (alpha:nat) : nat.
Admitted.

Definition nat_of_leftstep RI `{!EqDecision RI, !Countable RI} (gamma2: Loc RI) : nat.
Admitted.

Definition nat_of_rightstep RI `{!EqDecision RI, !Countable RI} (gamma1: Loc RI) : nat.
Admitted.

Definition pls_of_loc {RI} `{!EqDecision RI} `{!Countable RI} (loc: Loc RI) : (listset PathLoc). Admitted.

Definition build {RI} `{!EqDecision RI} `{!Countable RI} {M} `{!EqDecision M, !TPCM M}
    (loc: Loc RI) (cell: Cell M) : Branch M. Admitted.
    
Lemma build_spec {RI} `{!EqDecision RI} `{!Countable RI} {M} `{!EqDecision M, !TPCM M}
    (loc: Loc RI) (cell: Cell M)
  : (∀ pl , pl ∈ pls_of_loc loc -> cell_of_pl (build loc cell) pl = cell). Admitted.
  
Lemma build_rest_triv
        {M} `{!EqDecision M, !TPCM M}
        {RI} `{!EqDecision RI, !Countable RI}
    (loc: Loc RI) (cell: Cell M)
  : (∀ pl , ¬(pl ∈ pls_of_loc loc) -> cell_of_pl (build loc cell) pl = triv_cell). Admitted.

Definition ri_of_nat (RI : Type) `{!EqDecision RI, !Countable RI} : nat -> RI. Admitted.

Definition refinement_of_nat
        M `{!EqDecision M, !TPCM M}
        RI `{!EqDecision RI, !Countable RI, !RefinementIndex M RI}
        (idx: nat) : Refinement M M := refinement_of (ri_of_nat RI idx).

Lemma leftproject_le_left
        {M} `{!EqDecision M, !TPCM M}
        {RI} `{!EqDecision RI, !Countable RI, !RefinementIndex M RI}
        (m1 m2 c : M)
  (rdef: rel_defined M M (refinement_of (left_ri RI)) (dot (pair_up RI m1 m2) c))
  : tpcm_le m1 (rel M M (refinement_of (left_ri RI)) (dot (pair_up RI m1 m2) c)). Admitted.
  
Lemma rightproject_le_right
        {M} `{!EqDecision M, !TPCM M}
        {RI} `{!EqDecision RI, !Countable RI, !RefinementIndex M RI}
        (m1 m2 c : M)
  (rdef: rel_defined M M (refinement_of (right_ri RI)) (dot (pair_up RI m1 m2) c))
  : tpcm_le m2 (rel M M (refinement_of (right_ri RI)) (dot (pair_up RI m1 m2) c)). Admitted.
(*
Global Instance loc_eqdec : EqDecision Loc.
Proof. solve_decision. Defined.

Global Instance loc_countable : Countable Loc.
Proof.
  set (enc :=
    fix go l :=
      match l with
      | BaseLoc i => GenLeaf (inl i)
      | ExtLoc i ri linner => GenNode 0 [GenLeaf (inr (i, ri)); go linner]
      | CrossLoc l1 l2 => GenNode 1 [go l1; go l2]
      end
  ).
  set (dec :=
    fix go e :=
      match e with
      | GenLeaf (inl i) => BaseLoc i
      | GenNode 0 [GenLeaf (inr (i, ri)); einner] => ExtLoc i ri (go einner)
      | GenNode 1 [e1; e2] => CrossLoc (go e1) (go e2)
      | _ => BaseLoc 0 (* dummy *)
      end
  ).
  refine (inj_countable' enc dec _).
  refine (fix go (e : Loc) {struct e} := _).
  - destruct e as [| | ]; simpl; f_equal; trivial.
Qed.

Inductive ILoc
*)