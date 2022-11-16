FactoryBot.define do
    factory :task do
        task_name { Faker::Hobby.activity }
        task_description { Faker::String.random(length: 3..12) }

        trait :invalid_date do
            deadline { Faker::Time.backward(days: 100, period: :all, format: :default) }
        end
        trait :valid_date do
            deadline { Faker::Time.forward(days: 100, period: :all, format: :default) }
        
        end
    end
end