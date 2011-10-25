require_relative 'photo.rb'

class Album
	
  attr_accessor :id, :photos, :title, :slug, :date_created, :date_updated, :cover_photo_url, :description

  def initialize
    @photos = []
  end

end
