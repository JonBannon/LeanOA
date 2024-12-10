/-
Copyright (c) 2024 Jon Bannon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jon Bannon, Jireh Loreaux
-/

import Mathlib.Analysis.SpecialFunctions.ContinuousFunctionalCalculus.Rpow

/-!
# Absolute value of an operator defined via the continuous functional calculus

This file defines the absolute value via the (unital and non unital) continuous functional calculus
(CFC) and (CFCₙ), and includes foundational API.

## Main declarations

+ `CFC.abs`: The absolute value declaration as `abs a := sqrt (star a) * a`.

-/

open scoped NNReal

namespace CFC

section Nonunital

variable {A : Type*} [PartialOrder A] [NonUnitalNormedRing A] [StarRing A]
  [Module ℝ≥0 A] [SMulCommClass ℝ≥0 A A] [IsScalarTower ℝ≥0 A A]
  [NonUnitalContinuousFunctionalCalculus ℝ≥0 (fun (a : A) => 0 ≤ a)]

-- Do we *really* want an `abs` section, here?
section abs

/-- The absolute value of an operator, using the nonunital continuous functional calculus. -/
noncomputable def abs (a : A) := sqrt (star a * a)

@[simp]
lemma abs_nonneg {a : A} : 0 ≤ abs a := sqrt_nonneg

@[simp]
lemma abs_zero : abs (0 : A) = 0 := by
  rw [abs, star_zero, mul_zero, sqrt_zero]

-- It's likely that using these variables warrants a different section

variable [StarOrderedRing A] [UniqueNonUnitalContinuousFunctionalCalculus ℝ≥0 A]

lemma abs_mul_self_eq_star_mul_self (a : A) : (abs a) * (abs a) = star a * a := by
  refine sqrt_mul_sqrt_self _ <| star_mul_self_nonneg _

lemma abs_sq_eq_star_mul_self (a : A) : (abs a) ^ (2 : NNReal) = star a * a := by
  simp only [abs_nonneg, nnrpow_two]
  apply abs_mul_self_eq_star_mul_self

lemma abs_pow_eq_star_mul_self_pow (a : A) (x : ℝ≥0) :
    (abs a) ^ (2 * x) = (star a * a) ^ x := by rw [← nnrpow_nnrpow, abs_sq_eq_star_mul_self]

/-- This and the previous need new names. -/
lemma abs_pow_eq_star_mul_self_pow_by_two (a : A) (x : ℝ≥0) :
    (abs a) ^ x = (star a * a) ^ (x / 2) := by
  simp only [← abs_pow_eq_star_mul_self_pow, mul_div_left_comm, ne_eq, OfNat.ofNat_ne_zero,
    not_false_eq_true, div_self, mul_one]

end abs

end Nonunital

end CFC
