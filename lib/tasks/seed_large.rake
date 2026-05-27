# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc "Seed ~1000 users and competitions for UI testing (development only)"
    task large: :environment do
      unless Rails.env.development?
        abort "db:seed:large is only available in development (current: #{Rails.env})"
      end

      load Rails.root.join("db/seeds/large.rb")
    end
  end
end
