From iris.bi Require Export derived_connectives extensions updates internal_eq plainly.
From iris.base_logic Require Export upred.
From iris.prelude Require Import options.
Import uPred_primitive.

(** BI instances for [uPred], and re-stating the remaining primitive laws in
terms of the BI interface. This file does *not* unseal. *)

Definition uPred_emp {M} : uPred M := uPred_pure True.

Local Existing Instance entails_po.

Lemma uPred_bi_mixin (M : ucmra) :
  BiMixin
    uPred_entails uPred_emp uPred_pure uPred_and uPred_or uPred_impl
    (@uPred_forall M) (@uPred_exist M) uPred_sep uPred_wand
    uPred_persistently.
Proof.
  split.
  - exact: entails_po.
  - exact: equiv_entails.
  - exact: pure_ne.
  - exact: and_ne.
  - exact: or_ne.
  - exact: impl_ne.
  - exact: forall_ne.
  - exact: exist_ne.
  - exact: sep_ne.
  - exact: wand_ne.
  - exact: persistently_ne.
  - exact: pure_intro.
  - exact: pure_elim'.
  - exact: and_elim_l.
  - exact: and_elim_r.
  - exact: and_intro.
  - exact: or_intro_l.
  - exact: or_intro_r.
  - exact: or_elim.
  - exact: impl_intro_r.
  - exact: impl_elim_l'.
  - exact: @forall_intro.
  - exact: @forall_elim.
  - exact: @exist_intro.
  - exact: @exist_elim.
  - exact: sep_mono.
  - exact: True_sep_1.
  - exact: True_sep_2.
  - exact: sep_comm'.
  - exact: sep_assoc'.
  - exact: wand_intro_r.
  - exact: wand_elim_l'.
  - exact: persistently_mono.
  - exact: persistently_idemp_2.
  - (* emp ⊢ <pers> emp (ADMISSIBLE) *)
    trans (uPred_forall (M:=M) (λ _ : False, uPred_persistently uPred_emp)).
    + apply forall_intro=>[[]].
    + etrans; first exact: persistently_forall_2.
      apply persistently_mono. exact: pure_intro.
  - exact: @persistently_forall_2.
  - exact: @persistently_exist_1.
  - (* <pers> P ∗ Q ⊢ <pers> P (ADMISSIBLE) *)
    intros. etrans; first exact: sep_comm'.
    etrans; last exact: True_sep_2.
    apply sep_mono; last done.
    exact: pure_intro.
  - exact: persistently_and_sep_l_1.
Qed.

Lemma uPred_bi_later_mixin (M : ucmra) :
  BiLaterMixin
    uPred_entails uPred_pure uPred_or uPred_impl
    (@uPred_forall M) (@uPred_exist M) uPred_sep uPred_persistently uPred_later.
Proof.
  split.
  - apply contractive_ne, later_contractive.
  - exact: later_mono.
  - exact: later_intro.
  - exact: @later_forall_2.
  - exact: @later_exist_false.
  - exact: later_sep_1.
  - exact: later_sep_2.
  - exact: later_persistently_1.
  - exact: later_persistently_2.
  - exact: later_false_em.
Qed.

Canonical Structure uPredI (M : ucmra) : bi :=
  {| bi_ofe_mixin := ofe_mixin_of (uPred M);
     bi_bi_mixin := uPred_bi_mixin M;
     bi_bi_later_mixin := uPred_bi_later_mixin M |}.

Global Instance uPred_pure_forall M : BiPureForall (uPredI M).
Proof. exact: @pure_forall_2. Qed.

Global Instance uPred_later_contractive {M} : BiLaterContractive (uPredI M).
Proof. apply later_contractive. Qed.

Lemma uPred_internal_eq_mixin M : BiInternalEqMixin (uPredI M) (@uPred_internal_eq M).
Proof.
  split.
  - exact: internal_eq_ne.
  - exact: @internal_eq_refl.
  - exact: @internal_eq_rewrite.
  - exact: @fun_ext.
  - exact: @sig_eq.
  - exact: @discrete_eq_1.
  - exact: @later_eq_1.
  - exact: @later_eq_2.
Qed.
Global Instance uPred_internal_eq M : BiInternalEq (uPredI M) :=
  {| bi_internal_eq_mixin := uPred_internal_eq_mixin M |}.

Lemma uPred_plainly_mixin M : BiPlainlyMixin (uPredI M) uPred_plainly.
Proof.
  split.
  - exact: plainly_ne.
  - exact: plainly_mono.
  - exact: plainly_elim_persistently.
  - exact: plainly_idemp_2.
  - exact: @plainly_forall_2.
  - exact: persistently_impl_plainly.
  - exact: plainly_impl_plainly.
  - (* P ⊢ ■ emp (ADMISSIBLE) *)
    intros P.
    trans (uPred_forall (M:=M) (λ _ : False , uPred_plainly uPred_emp)).
    + apply forall_intro=>[[]].
    + etrans; first exact: plainly_forall_2.
      apply plainly_mono. exact: pure_intro.
  - (* ■ P ∗ Q ⊢ ■ P (ADMISSIBLE) *)
    intros P Q. etrans; last exact: True_sep_2.
    etrans; first exact: sep_comm'.
    apply sep_mono; last done.
    exact: pure_intro.
  - exact: later_plainly_1.
  - exact: later_plainly_2.
Qed.
Global Instance uPred_plainly M : BiPlainly (uPredI M) :=
  {| bi_plainly_mixin := uPred_plainly_mixin M |}.

Global Instance uPred_prop_ext M : BiPropExt (uPredI M).
Proof. exact: prop_ext_2. Qed.

Lemma uPred_bupd_mixin M : BiBUpdMixin (uPredI M) uPred_bupd.
Proof.
  split.
  - exact: bupd_ne.
  - exact: bupd_intro.
  - exact: bupd_mono.
  - exact: bupd_trans.
  - exact: bupd_frame_r.
Qed.
Global Instance uPred_bi_bupd M : BiBUpd (uPredI M) := {| bi_bupd_mixin := uPred_bupd_mixin M |}.

Global Instance uPred_bi_bupd_plainly M : BiBUpdPlainly (uPredI M).
Proof. exact: bupd_plainly. Qed.

(** extra BI instances *)

Global Instance uPred_affine M : BiAffine (uPredI M) | 0.
Proof. intros P. exact: pure_intro. Qed.
(* Also add this to the global hint database, otherwise [eauto] won't work for
many lemmas that have [BiAffine] as a premise. *)
Global Hint Immediate uPred_affine : core.

Global Instance uPred_plainly_exist_1 M : BiPlainlyExist (uPredI M).
Proof. exact: @plainly_exist_1. Qed.

(** Re-state/export lemmas about Iris-specific primitive connectives (own, valid) *)

Module uPred.

Section restate.
Context {M : ucmra}.
Implicit Types φ : Prop.
Implicit Types P Q : uPred M.
Implicit Types A : Type.

(* Force implicit argument M *)
Notation "P ⊢ Q" := (bi_entails (PROP:=uPredI M) P%I Q%I).
Notation "P ⊣⊢ Q" := (equiv (A:=uPredI M) P%I Q%I).

Global Instance ownM_ne : NonExpansive (@uPred_ownM M) := uPred_primitive.ownM_ne.
Global Instance cmra_valid_ne {A : cmra} : NonExpansive (@uPred_cmra_valid M A)
  := uPred_primitive.cmra_valid_ne.

(** Re-exporting primitive lemmas that are not in any interface *)
Lemma ownM_op (a1 a2 : M) :
  uPred_ownM (a1 ⋅ a2) ⊣⊢ uPred_ownM a1 ∗ uPred_ownM a2.
Proof. exact: uPred_primitive.ownM_op. Qed.
Lemma persistently_ownM_core (a : M) : uPred_ownM a ⊢ <pers> uPred_ownM (core a).
Proof. exact: uPred_primitive.persistently_ownM_core. Qed.
Lemma ownM_unit P : P ⊢ (uPred_ownM ε).
Proof. exact: uPred_primitive.ownM_unit. Qed.
Lemma later_ownM a : ▷ uPred_ownM a ⊢ ∃ b, uPred_ownM b ∧ ▷ (a ≡ b).
Proof. exact: uPred_primitive.later_ownM. Qed.
Lemma bupd_ownM_updateP x (Φ : M → Prop) :
  x ~~>: Φ → uPred_ownM x ⊢ |==> ∃ y, ⌜Φ y⌝ ∧ uPred_ownM y.
Proof. exact: uPred_primitive.bupd_ownM_updateP. Qed.

(** This is really just a special case of an entailment
between two [siProp], but we do not have the infrastructure
to express the more general case. This temporary proof rule will
be replaced by the proper one eventually. *)
Lemma internal_eq_entails {A B : ofe} (a1 a2 : A) (b1 b2 : B) :
  (∀ n, a1 ≡{n}≡ a2 → b1 ≡{n}≡ b2) → a1 ≡ a2 ⊢ b1 ≡ b2.
Proof. exact: uPred_primitive.internal_eq_entails. Qed.

Lemma ownM_valid (a : M) : uPred_ownM a ⊢ ✓ a.
Proof. exact: uPred_primitive.ownM_valid. Qed.
Lemma cmra_valid_intro {A : cmra} P (a : A) : ✓ a → P ⊢ (✓ a).
Proof. exact: uPred_primitive.cmra_valid_intro. Qed.
Lemma cmra_valid_elim {A : cmra} (a : A) : ¬ ✓{0} a → ✓ a ⊢ False.
Proof. exact: uPred_primitive.cmra_valid_elim. Qed.
Lemma plainly_cmra_valid_1 {A : cmra} (a : A) : ✓ a ⊢ ■ ✓ a.
Proof. exact: uPred_primitive.plainly_cmra_valid_1. Qed.
Lemma cmra_valid_weaken {A : cmra} (a b : A) : ✓ (a ⋅ b) ⊢ ✓ a.
Proof. exact: uPred_primitive.cmra_valid_weaken. Qed.
Lemma discrete_valid {A : cmra} `{!CmraDiscrete A} (a : A) : ✓ a ⊣⊢ ⌜✓ a⌝.
Proof. exact: uPred_primitive.discrete_valid. Qed.

(** This is really just a special case of an entailment
between two [siProp], but we do not have the infrastructure
to express the more general case. This temporary proof rule will
be replaced by the proper one eventually. *)
Lemma valid_entails {A B : cmra} (a : A) (b : B) :
  (∀ n, ✓{n} a → ✓{n} b) → ✓ a ⊢ ✓ b.
Proof. exact: uPred_primitive.valid_entails. Qed.

(** Consistency/soundness statement *)
Lemma pure_soundness φ : (⊢@{uPredI M} ⌜ φ ⌝) → φ.
Proof. apply pure_soundness. Qed.

Lemma internal_eq_soundness {A : ofe} (x y : A) : (⊢@{uPredI M} x ≡ y) → x ≡ y.
Proof. apply internal_eq_soundness. Qed.

Lemma later_soundness P : (⊢ ▷ P) → ⊢ P.
Proof. apply later_soundness. Qed.
(** See [derived.v] for a similar soundness result for basic updates. *)
End restate.


(** New unseal tactic that also unfolds the BI layer.
    This is used by [base_logic.algebra] and [base_logic.bupd_alt].
    TODO: Can we get rid of this? *)
Ltac unseal := (* Coq unfold is used to circumvent bug #5699 in rewrite /foo *)
  unfold bi_emp; simpl;
  unfold uPred_emp, bupd, bi_bupd_bupd, bi_pure,
    bi_and, bi_or, bi_impl, bi_forall, bi_exist,
    bi_sep, bi_wand, bi_persistently, bi_later; simpl;
  unfold internal_eq, bi_internal_eq_internal_eq,
    plainly, bi_plainly_plainly; simpl;
  uPred_primitive.unseal.

End uPred.
