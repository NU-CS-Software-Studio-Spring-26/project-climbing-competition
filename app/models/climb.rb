class Climb < ApplicationRecord
  belongs_to :competition, optional: true
  has_many :attempts, dependent: :destroy

  validates :name, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :grading, allow_blank: true, format: { with: /\AV\d{1,2}\z/, message: "must be V-grade format (e.g., V4, V7)" }

  before_validation :sanitize_grading

  private

  def sanitize_grading
    self.grading = grading.to_s.strip.upcase if grading.present?
  end
end
