(* (C) Pierre Cast�ran 

   A trace monoid (a.k.a. partial commutation monoid) is defined
   by a finite  alphabet and  a partial commutation relation on letters.

   In the following example, the alphabet is {a,b,c}, and we declare that
   the letters a and b commute.
   
   We consider the  equivalence on the set of words, generated by
   by the permutation of two adjacent letters that commute, i.e.
   we say that for any words u and v, uabv is equivalent to ubav.

   This structure is often used as a model for parallelism.
*)
  


Set Implicit Arguments.



(*** Trace Monoid *)

Require Import List  Relation_Operators  Operators_Properties.
Require Import Morphisms Setoid.
Require Import EMonoid.

Section Partial_Com.

 Inductive Act : Set := a | b | c.

 Example Diff: a::b::nil  <> b::a::nil. 
 Proof. discriminate.  Qed.

(** prtail commutation relationship *)

Inductive transpose : list Act -> list Act -> Prop :=
| transpose_hd : forall w, transpose(a::b::w) (b::a::w)
| transpose_tl : forall x w u, transpose  w u -> transpose (x::w) (x::u).

Definition commute := clos_refl_sym_trans _ transpose.

Instance Commute_E : Equivalence  commute.
Proof.
split.
- constructor 2.
- constructor 3;auto.
- econstructor 4;eauto.
Qed.

Infix "==" := commute (at level 70):type_scope.


Example ex0 : b::a::nil == a::b::nil.
Proof. 
 symmetry.
 repeat constructor.
Qed.

Example ex1 :  (a::b::b::nil) == (b::b::a::nil).
Proof.
  transitivity (b::a::b::nil).
  - repeat constructor.
  - repeat constructor.
Qed. 

Lemma cons_transpose_Proper (x:Act): Proper (transpose ==> transpose)
                                            (cons x).
Proof.
 intros  l l' H; now constructor.
Qed.

Instance cons_commute_Proper (x:Act): Proper (commute ==> commute)
                                         (cons x).
Proof. 
 intros  l l' H; induction H.
 - constructor 1; apply cons_transpose_Proper;auto.
 - reflexivity.
 - rewrite IHclos_refl_sym_trans; reflexivity. 
 - rewrite IHclos_refl_sym_trans1;auto.
Qed.

Example Ex1 : forall u v, u == v -> (a::b::u) == (b::a::v).
Proof.
 intros u v H;rewrite H; repeat constructor.
Qed.

Example Ex2 : forall w, w++(a::b::nil) == w++(b::a::nil).
Proof.
 induction w;simpl.
 - repeat constructor. 
 - now rewrite IHw.
Qed.

(* Lemmas about commute , cons and app *)

Instance append_transpose_Proper (l:list Act): Proper (transpose ==> transpose)
                                         (app l).
Proof.
 induction l.
 -  intros z t Ht;simpl;auto.
 -  intros z t Ht;simpl;constructor;auto.
Qed.

Lemma append_transpose_Proper_1  : Proper (transpose ==> Logic.eq  ==> transpose)
                                         (@app Act).
Proof.
 intros x y H;induction H;intros z t e;subst t. 
 -  simpl;constructor. 
 - generalize (IHtranspose z z (refl_equal z)); simpl;constructor;auto.
Qed.

Instance append_commute_Proper_1 : 
Proper (Logic.eq ==> commute  ==> commute) (@app Act).
Proof.
intros x y e;subst y;intros z t H;elim H.
- constructor 1.
  apply append_transpose_Proper;auto.
- reflexivity.
- intros;  constructor 3;auto.
-  intros; constructor 4 with (x++y);auto.
Qed.

Instance append_commute_Proper_2 : 
Proper (commute ==> Logic.eq   ==> commute)
                                         (@app Act).
Proof.
  intros x y H; elim H. 
  -  intros x0 y0 H0  z t e.
     subst t; constructor 1.
     apply append_transpose_Proper_1;auto.
  -  intros x0 z t e; subst t;constructor 2;auto.
  -  intros x0 y0 H0 H1 z t e;subst t.
     constructor 3.
     apply H1;auto.
  -  intros x0 y0 z0 H1 H2 H3 H4 z t e;subst t.
     transitivity (y0 ++ z).
     apply H2;reflexivity.
     apply H4;reflexivity.
Qed.



Instance append_Proper : Proper (commute ==> commute ==> commute) (@app Act).
Proof.
intros x y H z t H0;transitivity (y++z).
- rewrite H;reflexivity.
- rewrite H0;reflexivity.
Qed.



Instance PCom  : EMonoid   commute (@List.app Act)nil.
Proof.
  split.
  - apply Commute_E.
  - apply append_Proper.
  - intros;rewrite <- app_assoc;reflexivity.
  - simpl;reflexivity.
  - intros;rewrite app_nil_r;reflexivity.
Qed.

Fixpoint repeat (w:list Act)(n:nat)  : list Act :=
 match n with 0%nat => nil
            | S p => w ++ repeat w p 
 end.

Instance repeat_Proper : Proper (commute ==> Logic.eq ==> commute) repeat.
Proof. 
  intros u v H n p H0;subst p;induction n;simpl. 
  -  reflexivity.
  - rewrite IHn, H; reflexivity.
Qed.

Lemma ab_ba: forall n, repeat (a::b::nil) n == repeat (b::a::nil) n.
Proof.
intros; setoid_replace (a :: b :: nil) with  (b :: a :: nil).
- reflexivity.
- repeat constructor.
Qed.


Lemma abn : forall n, a::repeat (b::nil) n == repeat (b::nil) n ++ (a::nil).
Proof.
induction n.
-  reflexivity.
- simpl; transitivity (b :: a :: repeat (b :: nil) n).
 + repeat  constructor.
 + now  rewrite IHn.
Qed.


Example bn_an : forall n, repeat (b::a::nil) n ==
                          repeat (b::nil) n ++ repeat (a::nil) n.
Proof.
  induction n.
  - reflexivity.
  - simpl; rewrite IHn.
    apply cons_commute_Proper.
    transitivity ((a :: repeat (b :: nil) n) ++ repeat (a :: nil) n).
    + reflexivity.
    +  rewrite abn; simpl; rewrite <- app_assoc; reflexivity.
Qed.

 




End Partial_Com.
