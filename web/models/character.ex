defmodule EdgeBuilder.Models.Character do
  use Ecto.Model

  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Repo

  schema "characters" do
    field :name, :string
    field :species, :string
    field :career, :string
    field :specializations, :string
    field :portrait_url, :string
    field :soak, :integer
    field :wounds_threshold, :integer
    field :wounds_current, :integer
    field :strain_threshold, :integer
    field :strain_current, :integer
    field :defense_ranged, :integer
    field :defense_melee, :integer
    field :characteristic_brawn, :integer
    field :characteristic_agility, :integer
    field :characteristic_intellect, :integer
    field :characteristic_cunning, :integer
    field :characteristic_willpower, :integer
    field :characteristic_presence, :integer
    field :gear, :string
    field :credits, :integer
    field :encumbrance, :string
    field :xp_available, :integer
    field :xp_total, :integer
    field :background, :string
    field :motivation, :string
    field :obligation, :string
    field :obligation_amount, :string
    field :description, :string
    field :other_notes, :string
    field :combined_character_skills, {:array, :any}, virtual: true

    has_many :talents, Talent
    has_many :attacks, Attack
    has_many :character_skills, CharacterSkill
  end

  def full_character(id) do
    character = Repo.one from c in EdgeBuilder.Models.Character, where: c.id == ^id, preload: [:talents, :attacks, [character_skills: :base_skill]]

    character |> populate_combined_character_skills
  end

  defp populate_combined_character_skills(character) do
    %{character | combined_character_skills:
      Repo.all(BaseSkill) |> Enum.map(&(character_skill_or_default(&1,character.character_skills)))
    }
  end

  defp character_skill_or_default(base_skill, character_skills) do
    skill_template = %{
      name: base_skill.name,
      characteristic: base_skill.characteristic,
      base_skill_id: base_skill.id
    }

    character_skill = case Enum.find(character_skills, &(&1.base_skill == base_skill)) do
      nil -> %{rank: 0, is_career: false, id: nil}
      matched_skill -> Map.take(matched_skill, [:rank, :is_career, :id])
    end

    Map.merge(skill_template, character_skill)
  end
end
