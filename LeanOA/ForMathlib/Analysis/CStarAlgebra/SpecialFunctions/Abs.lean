/-
Copyright (c) 2024 Jon Bannon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jon Bannon, Jireh Loreaux
-/

import LeanOA.ForMathlib.Analysis.SpecialFunctions.ContinuousFunctionalCalculus.Abs
import LeanOA.ForMathlib.Analysis.SpecialFunctions.ContinuousFunctionalCalculus.PosPart
import Mathlib.Analysis.CStarAlgebra.ContinuousFunctionalCalculus.Instances
import Mathlib.Analysis.CStarAlgebra.ContinuousFunctionalCalculus.Order

/-!
# Absolute value of an operator defined via the continuous functional calculus

This file provides API for the absolute value for (CFC) and (CFCₙ), and includes the associated
basic API. THIS NEEDS UPDATING!

## Main declarations

## Implementation notes

None yet

## Notation

Not sure we will need this

## TODO

Not sure yet.

-/

open scoped NNReal

namespace CFC

section NonUnital

variable {A : Type*} [NonUnitalNormedRing A] [StarRing A]
  [Module ℝ A] [SMulCommClass ℝ A A] [IsScalarTower ℝ A A]
  [NonUnitalContinuousFunctionalCalculus ℝ (IsSelfAdjoint : A → Prop)]

lemma mul_self_eq_mul_self {a : A} (ha : IsSelfAdjoint a) : a * a =
    cfcₙ (fun (x : ℝ) ↦ x * x) a := by
  conv_lhs => rw [← cfcₙ_id' ℝ a, ← cfcₙ_mul ..]

variable [UniqueNonUnitalContinuousFunctionalCalculus ℝ A]

/-- Needs a new name. -/
lemma sqrt_mul_self_rfl {a : A} (ha : IsSelfAdjoint a) :
    cfcₙ Real.sqrt (a * a) = cfcₙ (fun x ↦ √(x * x)) a := by
  rw [mul_self_eq_mul_self ha, ← cfcₙ_comp a (f := fun x ↦ x * x) (g := fun x ↦ √x),
     Function.comp_def]

variable {A : Type*} [PartialOrder A] [NonUnitalNormedRing A] [StarRing A]
   [Module ℝ A] [SMulCommClass ℝ A A] [IsScalarTower ℝ A A]
   [NonUnitalContinuousFunctionalCalculus ℝ (IsSelfAdjoint : A → Prop)]
   [UniqueNonUnitalContinuousFunctionalCalculus ℝ≥0 A]
   [StarOrderedRing A] [NonnegSpectrumClass ℝ A]

lemma sqrt_eq_cfcₙ_real_sqrt {a : A} (ha : 0 ≤ a := by cfc_tac) :
    CFC.sqrt a = cfcₙ Real.sqrt a := by
  rw [sqrt_eq_iff _ (hb := cfcₙ_nonneg (A := A) (fun x _ ↦ Real.sqrt_nonneg x)),
    ← cfcₙ_mul ..]
  conv_rhs => rw [← cfcₙ_id (R := ℝ) a]
  refine cfcₙ_congr fun x hx ↦ ?_
  refine Real.mul_self_sqrt ?_
  exact quasispectrum_nonneg_of_nonneg a ha x hx

variable {A : Type*} [NonUnitalCStarAlgebra A] [PartialOrder A] [StarOrderedRing A]

lemma abs_eq_cfcₙ_norm {a : A} (ha : IsSelfAdjoint a) :
    abs a = cfcₙ (‖·‖) a := by
   simp only [abs, Real.norm_eq_abs, ← Real.sqrt_sq_eq_abs, sq]
   rw [sqrt_eq_cfcₙ_real_sqrt (star_mul_self_nonneg a), ha.star_eq, sqrt_mul_self_rfl ha]

lemma abs_eq_zero_iff {a : A} : abs a = 0 ↔ a = 0 := by
  rw [abs, sqrt_eq_zero_iff _, CStarRing.star_mul_self_eq_zero_iff]

@[aesop safe apply (rule_sets := [CStarAlgebra])]
theorem IsSelfAdjoint.mul_self_nonneg {a : A} (ha : IsSelfAdjoint a) : 0 ≤ a * a := by
  simpa [ha.star_eq] using star_mul_self_nonneg a

open ComplexOrder in
lemma cfcₙ_norm_sq_nonneg {f : ℂ → ℂ} {a : A} : 0 ≤ cfcₙ (fun z ↦ star (f z) * (f z)) a :=
  cfcₙ_nonneg fun _ _ ↦ star_mul_self_nonneg _

open ComplexConjugate in
lemma abs_sq_eq_cfcₙ_norm_sq_complex {a : A} (ha : IsStarNormal a) :
    (abs a) ^ (2 : NNReal) = cfcₙ (fun z : ℂ ↦ (‖z‖ ^ 2 : ℂ)) a := by
  conv_rhs => lhs; ext; rw [← Complex.conj_mul', ← Complex.star_def]
  rw [cfcₙ_mul .., cfcₙ_star .., cfcₙ_id' .., abs_sq_eq_star_mul_self ..]

open ComplexConjugate in
lemma abs_eq_cfcₙ_norm_complex {a : A} [ha : IsStarNormal a] :
    abs a = cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a := by
  calc
   abs a = sqrt ((abs a) ^ (2 : NNReal)) := by rw [CFC.sqrt_nnrpow_two ..]
       _ = sqrt (cfcₙ (fun z : ℂ ↦ (‖z‖ ^ 2 : ℂ)) a) := by
         conv => enter [1,1]; rw [abs_sq_eq_cfcₙ_norm_sq_complex ha]
       _ = sqrt ((cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) * (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a)) := by
         conv => enter [2,1]; rw [← cfcₙ_mul ..]
         congr!
         rw [sq]
       _ = (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) := by
         rw [← CFC.nnrpow_two (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) _,CFC.sqrt_nnrpow_two (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) _]
         sorry --it seems we need a norm_nonneg lemma...
         sorry

  --have H : cfcₙ (fun z : ℂ ↦ (‖z‖ ^ 2 : ℂ)) a = (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) * (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) := by
  --  rw [← cfcₙ_mul ..]
  --  conv_rhs => lhs; ext; rw [← sq]


  sorry

/-
  have J : (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) ^ (2 : NNReal) = (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) * (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) := by
    sorry
  have K : cfcₙ (fun z : ℂ ↦ (‖z‖ ^ 2 : ℂ)) a = (cfcₙ (fun z : ℂ ↦ (‖z‖ : ℂ)) a) ^ (2 : NNReal) := by
    conv_lhs =>
      lhs
      ext
      rw [sq]
    rw [cfcₙ_mul .., J]
  have L := abs_sq_eq_cfcₙ_norm_sq_complex ha
  rw [K] at L
  sorry
-/
#exit

lemma abs_of_nonneg {a : A} (ha : 0 ≤ a) : abs a = a := by
  rw [abs, ha.star_eq, sqrt_mul_self a ha]

--The following results seem to amount to translating over to functions.

lemma abs_eq_posPart_add_negPart (a : A) (ha : IsSelfAdjoint a) : abs a = a⁺ + a⁻ := sorry

lemma abs_sub_self (a : A) (ha : IsSelfAdjoint a) : abs a - a = 2 • a⁻ := sorry

lemma abs_add_self (a : A) (ha : IsSelfAdjoint a) : abs a + a = 2 • a⁺ := sorry

-- `r` of the appropriate kinds, so this is actually multiple lemmas
lemma abs_smul : abs (r • a) = |r| • abs a := sorry

end NonUnital

section Unital

variable {A : Type*} [CStarAlgebra A] [PartialOrder A] [StarOrderedRing A]

-- for these you need the algebra to be unital
lemma abs_algebraMap_complex (z : ℂ) : abs (algebraMap ℂ A z) = algebraMap ℝ A |z| := sorry
lemma abs_algebraMap_real (x : ℝ) : abs (algebraMap ℝ A x) = algebraMap ℝ A |x| := sorry
lemma abs_algebraMap_nnreal (x : ℝ≥0) : abs (algebraMap ℝ≥0 A x) = algebraMap ℝ≥0 A x := sorry
lemma abs_natCast (n : ℕ) : abs (n : A) = n := sorry

end Unital

end CFC
