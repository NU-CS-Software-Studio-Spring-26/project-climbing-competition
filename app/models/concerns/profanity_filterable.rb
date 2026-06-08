module ProfanityFilterable
  extend ActiveSupport::Concern

  PROFANITY_MESSAGE = "contains inappropriate language"

  class_methods do
    def filters_profanity_in(*attributes, allow_blank: false)
      options = { obscenity: { message: PROFANITY_MESSAGE } }
      options[:allow_blank] = true if allow_blank

      attributes.each do |attribute|
        validates attribute, **options
      end
    end
  end
end
