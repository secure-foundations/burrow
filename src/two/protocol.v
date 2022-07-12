From iris.algebra Require Export cmra updates.
From iris.algebra Require Import proofmode_classes.
From iris.algebra Require Import auth.
From iris.algebra Require Import functions.
From iris.algebra Require Import gmap.
From iris.prelude Require Import options.

From iris.base_logic Require Import upred.
From iris.base_logic.lib Require Export own iprop.
From iris.proofmode Require Import base.
From iris.proofmode Require Import ltac_tactics.
From iris.proofmode Require Import tactics.
From iris.proofmode Require Import coq_tactics.

From iris.base_logic.lib Require Export invariants.

From iris.base_logic.lib Require Export fancy_updates.
From iris.base_logic.lib Require Export fancy_updates_from_vs.

From iris.proofmode Require Import coq_tactics reduction.
From iris.proofmode Require Export tactics.
From iris.program_logic Require Import atomic.
From iris.prelude Require Import options.

From iris.base_logic.lib Require Export wsat.

From iris.bi Require Import derived_laws.

Require Import Two.inved.
Require Import Two.guard.
Require Import Two.auth_frag_util.

From iris.base_logic Require Import bi.

(*
Context {Σ: gFunctors}.
Context `{!invGS Σ}.
*)

Record StorageMixin P B
    `{Equiv P, PCore P, Op P, Valid P, PInv P, Unit P}
    {equ: @Equivalence P (≡)}
    `{Equiv B, PCore B, Op B, Valid B, Unit B}
:= {
    protocol_mixin: ProtocolMixin P;
    base_ra_mixin: RAMixin B; (* completely ignore core *)
    
    base_unit_left_id : LeftId equiv (ε : B) op;
    
    interp: P -> B;

    interp_proper: Proper ((≡) ==> (≡)) interp;
    interp_val: ∀ p: P , pinv p -> ✓ interp p;
}. 

Global Instance sm_interp_proper
    {P B: Type}
    `{Equiv P, PCore P, Op P, Valid P, PInv P, Unit P}
    {equ: @Equivalence P (≡)}
    `{Equiv B, PCore B, Op B, Valid B, Unit B}
    {sm: StorageMixin P B}
    : Proper ((≡) ==> (≡)) (interp P B sm).
Proof.
  destruct sm. trivial.
Qed.

Global Instance inved_proper
    {P: Type}
    `{Equiv P}
    : Proper ((≡) ==> (≡)) (@Inved P).
Proof.
  unfold Proper, "==>". intros.
  unfold "≡", inved_protocol_equiv. trivial.
Qed.

Section PropMap.
  Context {Σ: gFunctors}.
  
  Context `{Equiv B, Op B, Valid B, Unit B}.
  
  Definition wf_prop_map (f: B -> iProp Σ) :=
      Proper ((≡) ==> (≡)) f
      /\ f ε ≡ (True)%I
      /\ (∀ a b , ✓(a ⋅ b) -> f (a ⋅ b) ≡ (f a ∗ f b) % I).
      
  
End PropMap.

Section StorageLogic.
  Context `{Equiv B, PCore B, Op B, Valid B, Unit B}.
  Context `{Equiv P, PCore P, Op P, PInv P, Valid P, Unit P}.
  
  Context {equ: Equivalence (≡@{P})}.
  Context {equb: Equivalence (≡@{B})}.
  Context {storage_mixin: StorageMixin P B}.
  
  Definition storage_protocol_guards (p: P) (b: B) :=
      ∀ q , pinv (p ⋅ q) -> b ≼ interp P B storage_mixin (p ⋅ q).
      
  Definition storage_protocol_exchange (p1 p2: P) (b1 b2: B)  :=
      ∀ q , pinv (p1 ⋅ q) -> pinv (p2 ⋅ q)
          /\ ✓(interp P B storage_mixin (p1 ⋅ q) ⋅ b1)
          /\ interp P B storage_mixin (p1 ⋅ q) ⋅ b1 ≡ interp P B storage_mixin (p2 ⋅ q) ⋅ b2.
                   
  Global Instance my_discrete : CmraDiscrete (inved_protocolR (protocol_mixin P B storage_mixin)).
  Proof. apply discrete_cmra_discrete. Qed.

  Context {Σ: gFunctors}.
  Context `{!inG Σ (authUR (inved_protocolUR (protocol_mixin P B storage_mixin)))}.
  Context `{!invGS Σ}.
  
  Definition maps (γ: gname) (f: B -> iProp Σ) : iProp Σ :=
      ⌜ wf_prop_map f /\ (∃ p: P , True) ⌝ ∗
      ownI γ (
        ∃ (state: P) ,
          own γ (● (Inved state))
          ∗ ⌜ pinv state ⌝
          ∗ (f (interp P B storage_mixin state))
      ). 
  
  Definition p_own (γ: gname) (p: P) : iProp Σ := own γ (◯ (Inved p)).
  
  (*
  Lemma next_later (X Y : iProp Σ) :
      ((Next X) ≡ (Next Y) : iProp Σ)%I ⊢ (internal_eq (▷ X) (▷ Y))%I.
  Proof.
    uPred.unseal. split.
    intros.
    
    unfold uPred_holds, uPred_internal_eq_def in H10.
    unfold uPred_later_def. unfold uPred_internal_eq_def, uPred_holds.
    
    Unset Printing Notations.
    unfold dist in H10.
    unfold ofe_dist in H10.
    unfold laterO in H10.
    unfold later_dist in H10.
    unfold dist_later in H10.
    unfold later_car in H10.
    
    unfold dist.
    unfold uPredI.
    unfold ofe_dist.
    trivial.
    uPred_ofe_mixin.
    
    
    
    unfold dist in H10. unfold laterO in H10.
    
    unfold uPred_holds, uPred_later_def.
    unfold dist, ofe_dist.
    
    unfold "≡{n}≡".
    
    unfold uPred_later_def.
    cbv [uPred_internal_eq_def].
    *)
  
  Lemma ownIagree (γ : gname) (X Y : iProp Σ) : ownI γ X ∗ ownI γ Y ⊢ (▷ X ≡ ▷ Y).
  Proof.
    unfold ownI.
    rewrite <- own_op.
    iIntros "x".
    iDestruct (own_valid with "x") as "v".
    rewrite gmap_view_frag_op_validI.
    iDestruct "v" as "[#v iu]".
    unfold invariant_unfold.
    
    iDestruct (later_equivI_1 with "iu") as "iu".
    iDestruct (f_equivI_contractive (λ x , (▷ x)%I) with "iu") as "iu".
    iFrame.
  Qed.
  
  Lemma and_except0_r (X Y : iProp Σ)
      : X ∧ ◇ Y ⊢ ◇ (X ∧ Y).
  Proof.
    iIntros "l". rewrite bi.except_0_and. iSplit.
    { iDestruct "l" as "[l _]". iModIntro. iFrame. }
    { iDestruct "l" as "[_ l]". iFrame. }
  Qed.
  
  (*Lemma logic_guard_conjunct_fact (γ: gname) (p state: P) (f: B -> iProp Σ)
  : own γ (◯ Inved p)
        ∧ ▷ (own γ (● Inved state) ∗ ⌜pinv state⌝ ∗ f (interp P B storage_mixin state))
    ⊢ ⌜ p ≼ state ⌝.
  Proof.
    iIntros "x".
    iDestruct (and_later_r with "x") as "x".
    iMod "x" as "x".*)
  
  (*
  Lemma and_timeless (X Y : iProp Σ) (ti: Timeless Y)
      : ⊢ (X ∧ (▷ Y) -∗ ◇ (X ∧ Y)) % I.
  Proof.
    iIntros "r". unfold Timeless in ti.
    rewrite bi.except_0_and.
    iSplit. { iDestruct "r" as "[r _]". iModIntro. iFrame. }
    iDestruct "r" as "[_ r]".  iDestruct (ti with "r") as "r". iFrame.
  Qed.
  
  Lemma and_timeless2 (X Y : iProp Σ) (ti: Timeless Y)
      : ⊢ (X ∧ (▷ Y) ={∅}=∗ (X ∧ Y)) % I.
  Proof.
    iIntros "x".  iMod (and_timeless with "x") as "x". iModIntro. iFrame.
  Qed.
  *)
  
  Lemma apply_timeless (X Y Z W V : iProp Σ) (ti: Timeless Z) (ti2: Timeless W)
      : X ∧ (Y ∗ ▷ (Z ∗ W ∗ V)) -∗ ◇ (X ∧ (Y ∗ Z ∗ W ∗ ▷ (V))).
  Proof.
      iIntros "l".
      rewrite bi.except_0_and. iSplit.
      { iDestruct "l" as "[l _]". iModIntro. iFrame. }
      iDestruct "l" as "[_ [l [lat0 [lat1 lat2]]]]".
      iMod "lat0" as "lat0".
      iMod "lat1" as "lat1".
      iModIntro. iFrame.
  Qed.
  
  Lemma stuff1 (X Y Z W V : iProp Σ)
      : (X ∧ (Y ∗ Z ∗ W ∗ V)) ⊢ W.
  Proof.
    iIntros "x". iDestruct "x" as "[_ [_ [_ [w _]]]]". iFrame.
  Qed.
  
  Lemma incl_of_inved_incl_assumes_unital (p1 p2 : P)
    (incll :
      @included (InvedProtocol P) (inved_protocol_equiv P) (inved_protocol_op P)
      (Inved p1) (Inved p2)) : p1 ≼ p2.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ inG0 storage_mixin Σ.
    unfold "≼" in incll. destruct incll as [z incll].
    destruct z.
    - unfold "⋅", inved_protocol_op, "≡", inved_protocol_equiv in incll.
      unfold "≼". exists ε.
      setoid_rewrite (@comm P).
      + destruct storage_mixin. destruct protocol_mixin0.
          setoid_rewrite incll.
          unfold LeftId in protocol_unit_left_id.
          symmetry.
          apply protocol_unit_left_id.
      + destruct storage_mixin. destruct protocol_mixin0. destruct protocol_ra_mixin.
          apply ra_comm.
   - unfold "≡", inved_protocol_equiv, "⋅", inved_protocol_op in incll.
      unfold "≼". exists p. trivial.
  Qed.
  
  Lemma stuff2 (γ: gname) (p state: P) (T W: iProp Σ)
      : own γ (◯ Inved p) ∧ (T ∗ own γ (● Inved state) ∗ W) ⊢ ⌜ p ≼ state ⌝. 
  Proof.
    iIntros "x".
    iAssert (((own γ (● Inved state)) ∧ (own γ (◯ Inved p)))%I) with "[x]" as "t".
    { iSplit. 
        { iDestruct "x" as "[_ [_ [x _]]]". iFrame. }
        { iDestruct "x" as "[x _]". iFrame. }
    }
    iDestruct (auth_frag_conjunct with "t") as "%incll".
    iPureIntro.
    apply incl_of_inved_incl_assumes_unital. trivial.
  Qed.
  
  Lemma logic_guard (p: P) (b: B) (γ: gname) (f: B -> iProp Σ)
    (g: storage_protocol_guards p b)
    : maps γ f ⊢ (p_own γ p &&{ {[ γ ]} }&&> ▷ f b).
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 P equ equb inG0 invGS0 storage_mixin Σ.
    unfold guards, guards_with, maps.
    iIntros "[%wf #inv]".
    destruct wf as [wf exists_p].
    iIntros (T) "[po b]".
    rewrite storage_bulk_inv_singleton. unfold storage_inv.
    unfold p_own.
    iAssert ((own γ (◯ Inved p) ∧
        (◇ ∃ state : P, T ∗ ▷
               (own γ (● Inved state) ∗ ⌜pinv state⌝ ∗ f (interp P B storage_mixin state))))%I)
        with "[po b]" as "x".
    { iSplit. { iFrame. } 
      iDestruct ("b" with "po") as "[ex t]".
      iDestruct "ex" as (P0) "[#own lat]".
      iDestruct (ownIagree γ P0 _ with "[inv own]") as "eq".
      { iSplitL. { iFrame "own". } iFrame "inv". }
      iRewrite "eq" in "lat".
      iMod (bi.later_exist_except_0 with "lat") as (state) "lat".
      iExists state. iFrame.
    }
    iMod (and_except0_r with "x") as "x".
    rewrite bi.and_exist_l.
    iDestruct "x" as (state) "x".
    iMod (apply_timeless with "x") as "x".
    iDestruct (stuff1 with "x") as "%pinvs".
    iDestruct (stuff2 with "x") as "%incll".
    iDestruct "x" as "[_ [t [o [p latf]]]]".
    
    unfold storage_protocol_guards in g.
    unfold "≼" in incll. destruct incll as [z incll].
    assert (pinv (p ⋅ z)) as pinv_pz.
        { destruct storage_mixin. destruct protocol_mixin0. setoid_rewrite <- incll. trivial. }
    have gz := g z pinv_pz.
    unfold "≼" in gz. destruct gz as [y gz].
    assert (interp P B storage_mixin state ≡ b ⋅ y) as ieqop.
    { destruct storage_mixin. unfold interp. 
        setoid_rewrite incll. trivial. }
    
    unfold wf_prop_map in wf.
    destruct wf as [fprop [funit fop]].
    
    assert (✓ (b ⋅ y)) as is_val.
    { destruct storage_mixin. destruct base_ra_mixin0.
        setoid_rewrite <- ieqop. apply interp_val0. trivial. }
        
    setoid_rewrite ieqop.
    setoid_rewrite fop; trivial.
    
    rewrite bi.later_sep. 
    iDestruct "latf" as "[fb fy]".
    iModIntro.
    iFrame "fb".
    iIntros "fb".
    iFrame "t".
    iExists ((∃ state0 : P,
              own γ (● Inved state0) ∗ ⌜pinv state0⌝ ∗ f (interp P B storage_mixin state0))%I).
    iFrame "inv".
    iNext. iExists state. iFrame.
    setoid_rewrite ieqop. setoid_rewrite fop; trivial. iFrame.
  Qed.
  

  Lemma own_sep_inv_incll_helper (p1 p2 st : P)
    (cond : ∀ q : P, pinv (p1 ⋅ q) → pinv (p2 ⋅ q))
   : ∀ (z: InvedProtocol P) , ✓ (Inved st) -> Inved p1 ⋅ z ≡ Inved st → ✓ (Inved p2 ⋅ z).
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ inG0 storage_mixin Σ.
    intros z v eq.
    destruct z.
    - unfold "⋅", inved_protocol_op.
      unfold "⋅", inved_protocol_op in eq.
      unfold "≡", inved_protocol_equiv in eq.
      unfold "✓", inved_protocol_valid. 
      
      setoid_rewrite <- eq in v.
      {
        unfold "✓", inved_protocol_valid in v. 
        destruct v as [v pi].
        have c := cond v pi.
        exists v.
        trivial.
      }
      { destruct storage_mixin. trivial. }
    - unfold "⋅", inved_protocol_op in eq.
      unfold "≡", inved_protocol_equiv in eq.
      unfold "⋅", inved_protocol_op.
      
      setoid_rewrite <- eq in v.
      {
        unfold "✓", inved_protocol_valid in v.
        unfold "✓", inved_protocol_valid.
        destruct v as [v pi].
        
        assert (pinv (p1 ⋅ (p ⋅ v))) as pinv1. {
          destruct storage_mixin.
          destruct protocol_mixin0.
          unfold Proper, "==>", impl in inv_proper.
          apply inv_proper with (x := p1 ⋅ p ⋅ v); trivial.
          destruct protocol_ra_mixin.
          symmetry.
          apply ra_assoc.
        }
        have c := cond (p ⋅ v) pinv1.
        exists v.
        
        destruct storage_mixin.
        destruct protocol_mixin0.
        unfold Proper, "==>", impl in inv_proper.
        apply inv_proper with (x := p2 ⋅ (p ⋅ v)); trivial.
        destruct protocol_ra_mixin.
        apply ra_assoc.
      }
      { destruct storage_mixin. trivial. }
  Qed.
        
  Lemma op_nah (p1 state : P)
    : Inved p1 ⋅ Nah ≡ Inved state -> p1 ≡ state.
  Proof. intros. trivial. Qed.
  
  Lemma op_inved_inved (p1 p2 p : P)
    : Inved p1 ⋅ Inved p2 ≡ Inved p -> p1 ⋅ p2 ≡ p.
  Proof. intros. trivial. Qed.
        
  Lemma own_sep_inv_incll γ (p1 p2 state : P)
      (cond: ∀ q , pinv (p1 ⋅ q) -> pinv (p2 ⋅ q))
    : own γ (◯ Inved p1) ∗ own γ (● Inved state) ⊢
      ∃ (z: P) , ⌜ state ≡ p1 ⋅ z ⌝ ∗ own γ (◯ Inved p2) ∗ own γ (● Inved (p2 ⋅ z)).
  Proof.
    iIntros "[x y]".
    iDestruct (own_valid with "y") as "%val".
    iDestruct (own_sep_auth_incll γ (Inved p1) (Inved p2) (Inved state) with "[x y]") as "x".
    {
      intro.
      apply own_sep_inv_incll_helper; trivial.
      generalize val. rewrite auth_auth_valid. trivial.
    }
    { iFrame. }
    iDestruct "x" as (z) "[%eq [frag auth]]".
    destruct z.
    {
      have eq0 := op_nah _ _ eq.
      assert (Inved p2 ⋅ Nah ≡ Inved p2) as eq1 by trivial.
      setoid_rewrite eq1.
      iExists (ε:P).
      assert (p2 ⋅ ε ≡ p2) as eq2.
      { destruct storage_mixin. destruct protocol_mixin0.
          destruct protocol_ra_mixin.
          rewrite ra_comm.
          apply protocol_unit_left_id.
      }
      setoid_rewrite eq2.
      iFrame.
      iPureIntro.
      assert (p1 ⋅ ε ≡ p1) as eq3.
      { destruct storage_mixin. destruct protocol_mixin0.
          destruct protocol_ra_mixin.
          rewrite ra_comm.
          apply protocol_unit_left_id.
      }
      setoid_rewrite eq3. symmetry. trivial.
    }
    {
      iExists p.
      
      assert (Inved p2 ⋅ Inved p ≡ Inved (p2 ⋅ p)) as eq0 by trivial.
      setoid_rewrite eq0.
      iFrame.
      iPureIntro. symmetry. apply op_inved_inved. trivial.
    }
   Qed.
  
  Lemma logic_exchange
    (p1 p2: P) (b1 b2: B) (γ: gname) (f: B -> iProp Σ)
    (exchng: storage_protocol_exchange p1 p2 b1 b2)
    : maps γ f ⊢
        p_own γ p1 ∗ ▷ f b1 ={ {[ γ ]} }=∗ p_own γ p2 ∗ ▷ f b2.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ equb inG0 invGS0 storage_mixin Σ.
    unfold maps.
    iIntros "[%wfm #m] [p f]".
    destruct wfm as [wfm inh]. 
    rewrite uPred_fupd_eq. unfold uPred_fupd_def.
    iIntros "[w oe]".
    iDestruct (ownI_open with "[w m oe]") as "[w [latp od]]".
    { iFrame "w". iFrame "m". iFrame "oe". }
    iMod (bi.later_exist_except_0 with "latp") as (state) "lat".
    iDestruct "lat" as "[ois [ps fi]]".
    iMod "ois" as "ois".
    iMod "ps" as "%ps".
    unfold p_own.
    iDestruct (own_sep_inv_incll γ p1 p2 state with "[p ois]") as (z) "[%incll [p ois]]".
    { unfold storage_protocol_exchange in exchng. intros q pi.
        have exch := exchng q pi. intuition. }
    { iFrame. }
    
    destruct wfm as [f_prop [f_unit f_op]]. (* need f Proper for the next step *)
    
    assert (f (interp P B storage_mixin state)
          ≡ f(interp P B storage_mixin (p1 ⋅ z))) as equiv_interp_state.
      { setoid_rewrite incll. trivial. }
    
    setoid_rewrite equiv_interp_state.
    iDestruct (bi.later_sep with "[fi f]") as "f_op". { iFrame "fi". iFrame "f". }
    
    unfold storage_protocol_exchange in exchng.
    assert (pinv (p1 ⋅ z)) as pinv_p1_z. {
        destruct storage_mixin. destruct protocol_mixin0.
        setoid_rewrite <- incll. trivial.
    }

    have exch := exchng z pinv_p1_z.
    destruct exch as [pinv_p2_z [val_interp1 interp_eq]].
    assert (✓ (interp P B storage_mixin (p2 ⋅ z) ⋅ b2)) as val_interp2.
    {
      destruct storage_mixin. destruct base_ra_mixin0.
      setoid_rewrite <- interp_eq. trivial.
    }
    
    setoid_rewrite <- f_op; trivial.

    setoid_rewrite interp_eq.
    setoid_rewrite f_op; trivial.
    
    iDestruct "f_op" as "[fi fb]".

    iAssert ((▷ ∃ state0 : P,
          own γ (● Inved state0) ∗ ⌜pinv state0⌝ ∗ f (interp P B storage_mixin state0))%I)
          with "[ois fi]"
          as "inv_to_return".
    {
      iModIntro. (* strip later *)
      iExists (p2 ⋅ z). iFrame "ois". iFrame "fi".
      iPureIntro. trivial.
    }
    iDestruct (ownI_close γ _ with "[w m inv_to_return od]") as "[w en]".
    { iFrame "m". iFrame "inv_to_return". iFrame "w". iFrame "od". }
    iModIntro. iModIntro. iFrame.
  Qed.
  
  Lemma inved_op (a b : P) :
      Inved (a ⋅ b) ≡ Inved a ⋅ Inved b.
  Proof using H4 H6 H7 P equ. trivial. Qed.

  Lemma p_own_op a b γ :
      p_own γ (a ⋅ b) ⊣⊢ p_own γ a ∗ p_own γ b.
  Proof.
    unfold p_own.
    setoid_rewrite inved_op.
    rewrite auth_frag_op.
    apply own_op.
  Qed.
  
  Lemma op_unit (p: P) : p ⋅ ε ≡ p.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ inG0 storage_mixin Σ.
    destruct storage_mixin.
    destruct protocol_mixin.
    destruct protocol_ra_mixin.
    setoid_rewrite (@comm P).
    - apply protocol_unit_left_id.
    - trivial.
  Qed.
  
  Lemma op_unit_base (b: B) : b ⋅ ε ≡ b.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ equb inG0 storage_mixin Σ.
    destruct storage_mixin.
    destruct base_ra_mixin0.
    setoid_rewrite (@comm B).
    - apply base_unit_left_id0.
    - trivial.
  Qed.
  
  Lemma auth_inved_conjure_unit γ (state: P)
      : own γ (● Inved state) ==∗ own γ (● Inved state) ∗ own γ (◯ Inved ε).
  Proof.
      apply auth_inved_conjure_frag.
      setoid_rewrite <- inved_op.
      setoid_rewrite op_unit.
      trivial.
  Qed.
  
  Lemma p_own_unit γ f
      : maps γ f ⊢ |={ {[ γ ]} }=> p_own γ ε.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ equb inG0 invGS0 storage_mixin Σ.
    unfold maps.
    iIntros "[%wfm #m]".
    destruct wfm as [wfm inh]. 
      
    rewrite uPred_fupd_eq. unfold uPred_fupd_def.
    iIntros "[w oe]".
    iDestruct (ownI_open with "[w m oe]") as "[w [latp od]]".
    { iFrame "w". iFrame "m". iFrame "oe". }
    iMod (bi.later_exist_except_0 with "latp") as (state) "lat".
    iDestruct "lat" as "[ois [ps fi]]".
    iMod "ois" as "ois".
    iMod "ps" as "%ps".
    unfold p_own.
    iMod (auth_inved_conjure_unit γ state with "ois") as "[ois u]".
    iAssert ((▷ ∃ state0 : P,
          own γ (● Inved state0) ∗ ⌜pinv state0⌝ ∗ f (interp P B storage_mixin state0))%I)
          with "[ois fi]"
          as "inv_to_return".
    {
      iModIntro. (* strip later *)
      iExists state. iFrame "ois". iFrame "fi".
      iPureIntro. trivial.
    }
    iDestruct (ownI_close γ _ with "[w m inv_to_return od]") as "[w en]".
    { iFrame "m". iFrame "inv_to_return". iFrame "w". iFrame "od". }
    iModIntro. iModIntro. iFrame.
   Qed.
    
   Definition storage_protocol_deposit (p1 p2: P) (b1: B)  :=
      ∀ q , pinv (p1 ⋅ q) -> pinv (p2 ⋅ q)
          /\ ✓(interp P B storage_mixin (p1 ⋅ q) ⋅ b1)
          /\ interp P B storage_mixin (p1 ⋅ q) ⋅ b1 ≡ interp P B storage_mixin (p2 ⋅ q).

   Lemma logic_deposit
      (p1 p2: P) (b1: B) (γ: gname) (f: B -> iProp Σ)
      (exchng: storage_protocol_deposit p1 p2 b1)
      : maps γ f ⊢
          p_own γ p1 ∗ ▷ f b1 ={ {[ γ ]} }=∗ p_own γ p2.
   Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ equb inG0 invGS0 storage_mixin Σ.
    iIntros "#m pb".
    iMod (logic_exchange p1 p2 b1 (ε: B) γ f with "m pb") as "[pb u]".
    {
      unfold storage_protocol_exchange.
      unfold storage_protocol_deposit in exchng.
      intros q pi1. have t := exchng q pi1. intuition.
      setoid_rewrite op_unit_base.
      trivial.
    }
    iModIntro. iFrame "pb".
   Qed.
   
  Definition storage_protocol_withdraw (p1 p2: P) (b2: B)  :=
      ∀ q , pinv (p1 ⋅ q) -> pinv (p2 ⋅ q)
          (*/\ ✓(interp P B storage_mixin (p1 ⋅ q))*)
          /\ interp P B storage_mixin (p1 ⋅ q) ≡ interp P B storage_mixin (p2 ⋅ q) ⋅ b2.
          
  Instance valid_proper_base : Proper ((≡) ==> impl) (@valid B _).
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ inG0 storage_mixin Σ.
    destruct storage_mixin.
    destruct base_ra_mixin0.
    apply ra_validN_proper.
  Qed.
  
  Lemma valid_interp (p: P)
      : pinv p -> ✓ (interp P B storage_mixin p).
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ inG0 storage_mixin Σ.
    destruct storage_mixin.
    apply interp_val0.
  Qed.
   
  Lemma logic_withdraw
      (p1 p2: P) (b2: B) (γ: gname) (f: B -> iProp Σ)
      (exchng: storage_protocol_withdraw p1 p2 b2)
      : maps γ f ⊢
          p_own γ p1 ={ {[ γ ]} }=∗ p_own γ p2 ∗ ▷ f b2.
  Proof using B H H0 H1 H2 H3 H4 H5 H6 H7 H8 H9 P equ equb inG0 invGS0 storage_mixin Σ.
    iIntros "#m pb".
    iAssert (▷ f ε)%I as "u".
    {
      iModIntro. 
      unfold maps.
      iDestruct "m" as "[%wf #m]".
      destruct wf as [wf _].
      unfold wf_prop_map in wf.
      destruct wf as [wf_prop [wf_unit _]].
      setoid_rewrite wf_unit. done.
    }
    iMod (logic_exchange p1 p2 (ε: B) b2 γ f with "m [pb u]") as "[pb fb2]".
    {
      unfold storage_protocol_exchange.
      unfold storage_protocol_withdraw in exchng.
      intros q pi1. have t := exchng q pi1. intuition.
      - setoid_rewrite op_unit_base.
        apply valid_interp. trivial.
      - setoid_rewrite op_unit_base. trivial.
    }
    { iFrame "pb". iFrame "u". }
    iModIntro. iFrame.
   Qed.

          

    


 
End Storage.
