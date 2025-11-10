# frozen_string_literal: true

FactoryBot.define do
  factory :summary do
    original_post { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    status { "pending" }
    summary { nil }

    trait :with_text do
      original_post { Faker::Lorem.paragraph(sentence_count: 10) }
    end

    trait :short_text do
      original_post { Faker::Lorem.sentence(word_count: 5) }
    end

    trait :completed do
      status { "completed" }
      summary { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :failed do
      status { "failed" }
      summary { nil }
    end
  end
end
