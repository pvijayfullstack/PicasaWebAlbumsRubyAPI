require_relative 'photo_repository.rb'

photo_repository = PhotoRepository.new
my_albums = photo_repository.get_albums
my_albums.each do |album|
  puts album.title
end
