import data.real.basic 

/-- ereal : The set $$[-\infty,+\infty]$$ -/
def ereal := with_bot (with_top ℝ)

instance : linear_order ereal := 
by unfold ereal; apply_instance
instance : lattice.has_top ereal := 
by unfold ereal; apply_instance
instance : lattice.has_bot ereal :=
by -- guess what
unfold ereal; apply_instance
instance : has_zero ereal := by unfold ereal; apply_instance instance : lattice.order_bot ereal := by unfold ereal; apply_instance

def ereal.neg : ereal → ereal
| none := ⊤
| (some none) := ⊥
| (some (some x)) := (↑(↑-x : with_top ℝ) : with_bot (with_top ℝ))

instance : has_neg ereal := ⟨ereal.neg⟩
def ereal.neg_le_of (a b : ereal) : -a ≤ b → -b ≤ a :=
begin
  intro h,
  cases a with a,
    cases b with b, 
      change _ ≤ ⊥ at h,
      rw lattice.le_bot_iff at h,
      cases h,
    change ⊤ ≤ _ at h,
    rw lattice.top_le_iff at h,
    cases b with b, cases h, exact le_refl _,
    cases h,
  cases a with a,
    change _ ≤ ⊤,
    exact lattice.le_top,
  cases b with b,
    change _ ≤ ⊥ at h,
    rw lattice.le_bot_iff at h,
    cases h,
  cases b with b,
    change ⊥ ≤ _,
    exact lattice.bot_le,
  change (↑(↑(-a) : with_top ℝ) : with_bot (with_top ℝ)) ≤ _ at h,
  unfold_coes at h,
  replace h : -a ≤ b := by simpa using h,
  change (↑(↑(-b) : with_top ℝ) : with_bot (with_top ℝ)) ≤ _,
  suffices : -b ≤ a,
    unfold_coes,
    simp [this],
  exact neg_le_of_neg_le h,
end

def ereal.neg_neg (a : ereal) : - (- a) = a :=
begin
  cases a with a,
    refl,
  cases a with a,
    refl,
  unfold has_neg.neg,
  dsimp [ereal.neg],
  unfold_coes,
  dsimp [ereal.neg],
  rw neg_neg, refl,
end 

def ereal.neg_le {a b : ereal} : -a ≤ b ↔ -b ≤ a := ⟨ereal.neg_le_of a b, ereal.neg_le_of b a⟩

def ereal.le_neg_of (a b : ereal) : a ≤ -b → b ≤ -a :=
begin
  intro h,
  rw ←ereal.neg_neg b,
  apply ereal.neg_le_of,
  rwa ereal.neg_neg,
end 


def has_Sup (X : set ereal) : Prop := ∃ l : ereal, is_lub X l

local attribute [instance, priority 10] classical.prop_decidable

def Sup_exists (X : set ereal) : has_Sup X :=
begin
  let Xoc : set (with_top ℝ) := λ x, X (↑x : with_bot _),
  exact dite (Xoc = ∅) (λ h, begin
    use ⊥,
    split,
    { intros x hx,
      cases x, exact le_refl none,
      exfalso,
      apply set.not_mem_empty x,
      rw ←h,
      exact hx,
    },
    intros u hu,
    exact lattice.bot_le,
  end) (λ h, dite (⊤ ∈ Xoc) (λ h2, ⟨⊤, begin
    split, intros x hx, exact lattice.le_top,
    intros x hx,
    apply hx,
    exact h2,
  end⟩) begin
    intro htop,
    let Xoo : set ℝ := λ (x : ℝ), Xoc (↑ x),
    by_cases h2 : nonempty (upper_bounds Xoo),
    { rcases h2 with ⟨b, hb⟩,
      use (↑(↑(real.Sup Xoo : real) : with_top ℝ) : with_bot (with_top ℝ)),
      split,
      { intros x hx,
        cases x, exact lattice.bot_le,
        change (↑x : with_bot (with_top ℝ)) ≤ _,
        change x ∈ Xoc at hx,
        cases x with x, exact false.elim (htop hx),
        change (↑(↑x : with_top ℝ) : with_bot (with_top ℝ)) ≤ _,
        change x ∈ Xoo at hx,
        have h3 : x ≤ real.Sup Xoo,
          apply real.le_Sup,
          { use b,
            exact hb,
          },
        { exact hx},
          simp [h3],
        },
      { intros c hc,
        cases c with c,
          exfalso,
          replace h : ∃ x : with_top ℝ, x ∈ Xoc,
            apply classical.by_contradiction,
            intro h4, apply h,
            ext x,
            split, swap, intro h, cases h,
            intro hx,
            exfalso, apply h4,
            use x, assumption,
          cases h with x hx,
          replace hc := hc (↑x : with_bot _) hx,
          replace hc := lattice.le_bot_iff.1 hc,
          cases hc,
        change (↑c : with_bot _) ∈ _ at hc,
        cases c with c,
          unfold_coes, simp,
          suffices : real.Sup Xoo ≤ c,
            unfold_coes, simp [this],
          refine (real.Sup_le Xoo _ _).2 _,
          apply classical.by_contradiction,
            intro h2,
            apply h,
            ext x,
            split, swap, rintro ⟨⟩,
            intro h3,
            cases x with x, exfalso, apply htop, exact h3,
            exfalso, apply h2, use x, exact h3,
          use b,
          exact hb,
        intros x hx,
        replace hc := hc (↑(↑x : with_top ℝ) : with_bot (with_top ℝ)) hx,
        unfold_coes at hc,
        simpa using hc,
      }
    },
    { use ⊤,
      split, intros x hx, exact lattice.le_top,
      intros b hb,
      rw lattice.top_le_iff,
      cases b with b,
        exfalso,
        apply h,
        ext x,
        split, swap, rintro ⟨⟩,
        intro hx,
        exfalso,
        replace hb : ↑x ≤ ⊥ := hb (↑x : with_bot _) hx,
        rw lattice.le_bot_iff at hb,
        cases hb,
      cases b with b, refl,
      exfalso,
      apply h2,
      use b,
      intros x hx,
      replace hb := hb (↑(↑x : with_top ℝ) : with_bot (with_top ℝ)) hx,
      unfold_coes at hb,
      simpa using hb,
    }
  end) 
end

noncomputable def ereal.Sup := λ X, classical.some (Sup_exists X)

noncomputable instance : lattice.has_Sup ereal := ⟨ereal.Sup⟩

/-- The set $$[-\infty,+\infty]$$ is a
<a href="https://en.wikipedia.org/wiki/Complete_lattice">complete lattice.</a> -/
noncomputable instance : lattice.complete_lattice (ereal) :=
{ top := ⊤,
  le_top := λ _, lattice.le_top,
  bot := ⊥,
  bot_le := @lattice.bot_le _ _,
  Sup := ereal.Sup,
  Inf := λ X, -classical.some (Sup_exists ({mx | ∃ x ∈ X, mx = -x})),
  le_Sup := begin
    intros X x hx,
    have h := classical.some_spec (Sup_exists X),
    exact h.1 _ hx,
  end,
  Sup_le := begin
    intros X b hb,
    have h := classical.some_spec (Sup_exists X),
    cases h with h1 h2,
    change ereal.Sup X ∈ _ at h2,
    apply h2,
    exact hb,
  end,
  Inf_le := begin
    intros X x hx,
    have h := classical.some_spec (Sup_exists ({mx | ∃ x ∈ X, mx = -x})),
    rw ←ereal.neg_le,
    apply h.1,
    use x, use hx,
  end,
  le_Inf := begin
    intros X b hb,
    have h := classical.some_spec (Sup_exists ({mx | ∃ x ∈ X, mx = -x})),
    cases h with h1 h2,
    change ereal.Sup {mx | ∃ x ∈ X, mx = -x} ∈ _ at h2,
    apply ereal.le_neg_of,
    apply h2,
    intros mx hmx,
    apply ereal.le_neg_of,
    apply hb,
    rcases hmx with ⟨x, hx, hmx⟩,
    rw hmx,
    rwa ereal.neg_neg,
  end,
  ..with_bot.lattice }
  