variable X : Type -- hide

/-
# Chapter 1 : Sets

## Level 3
-/


/- 
Now prove that for any set $A$, $A ∩ B ⊆ A$.  
After `intros x hx,`, the `hx` hypothesis will be a conjunction.  
Use the `cases` tactic to finish.
-/


/- Lemma
If $A$ and $B$ are sets of any type $X$, then
$$ A \cap B \subseteq A.$$
-/
theorem intersection_subset (A B : set X) : A ∩ B ⊆ A  :=
begin
    intros x hx,
    cases hx with xA xB,
    exact xA, done
end
