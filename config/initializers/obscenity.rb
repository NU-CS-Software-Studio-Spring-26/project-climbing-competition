require "obscenity/active_model"

Obscenity.configure do |config|
  config.blacklist = Pathname.new(Gem.loaded_specs["obscenity"].full_gem_path).join("config/blacklist.yml")
  config.replacement = :stars
end
