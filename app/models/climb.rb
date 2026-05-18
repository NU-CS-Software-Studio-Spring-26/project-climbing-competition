class Climb < ApplicationRecord
  GRADES = (0..17).map { |n| "V#{n}" }.freeze

  belongs_to :competition, optional: true
  has_many :attempts, dependent: :destroy

  validates :name, :url, presence: true
  validates :name, length: { maximum: 100 }
  validates :url, length: { maximum: 2000 },
                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :grading, allow_blank: true, inclusion: { in: GRADES, message: "must be a V-grade (V0–V17)" }

  before_validation :sanitize_fields

  private

  def sanitize_fields
    self.name = ActionController::Base.helpers.strip_tags(name.to_s).squish if name.present?
    self.url = url.to_s.strip if url.present?
    self.grading = grading.to_s.strip.upcase if grading.present?
  end
end
