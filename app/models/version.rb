class Version < ActiveRecord::Base
  belongs_to :document, inverse_of: :versions
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  belongs_to :updater, class_name: "User", foreign_key: "updater_id"

  validates_presence_of :content_md, :content_html
  validates_presence_of :name
  validates_presence_of :document
  validates_uniqueness_of :name, scope: :document_id

  # before_save
  before_validation :set_name, :set_md, :set_html

private

  def set_html
    if self.content_md.present? && self.content_html.blank?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      self.content_html = markdown.render(self.content_md)
    end
  end

  def set_md
    if self.content_md.blank? && self.content_html.present?
      self.content_md = ReverseMarkdown.convert(self.content_html)
    end
  end

  def set_name
    if self.name.blank? && self.document.present?
      max = self.document.versions.map{|v| v.name.to_i}.max.presence || 0
      self.name = (max+1).to_s
    end
  end
end
