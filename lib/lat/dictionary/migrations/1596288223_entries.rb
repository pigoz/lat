# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:entries) do
      primary_key :id
      String :dictionary
      String :dictionary_id
      String :pos
      String :gloss
      String :reading
    end

    alter_table(:entries) do
      add_unique_constraint %i[dictionary dictionary_id]
    end

    create_table(:lemmas) do
      primary_key :id
      foreign_key :entry_id
      String :lemma
    end
  end

  down do
    drop_table(:entries)
    drop_table(:lemmas)
  end
end
