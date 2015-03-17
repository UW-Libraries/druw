FactoryGirl.define do
  factory :user do
    password 'password'

    factory :odegaard do
      email 'odegaard@uw.edu'
    end

    factory :suzallo do
      email 'suzallo@uw.edu'
    end

    factory :gerberding do
      email 'gerberding@uw.edu'
    end
  end
end
