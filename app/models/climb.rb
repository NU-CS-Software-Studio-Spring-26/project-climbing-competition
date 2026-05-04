class Climb < ApplicationRecord
  belongs_to :competition, optional: true
  has_many :attempts, dependent: :destroy

  validates :name, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
end
