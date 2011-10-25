require_relative 'picasa_photo_repository.rb'

class PhotoRepository
  
  def initialize
    @repository_implementation = PicasaPhotoRepository.new('apitest33@gmail.com', 'kurADR4k')
  end

  def get_albums
    albums = @repository_implementation.get_albums
    return albums
  end

  def get_album_by_id(id)
    album = @repository_implementation.get_album_by_id(id)
    return album
  end

  def get_album_by_title(title)
    album = @repository_implementation.get_album_by_title(title)
    return album
  end

  def get_album_by_slug(slug)
    album = @repository_implementation.get_album_by_slug(slug)
    return album
  end

  def get_photos(album)
    photos = @repository_implementation.get_photos(album)
    return photos
  end

  def get_photo_by_album_and_id(album, id)
    photo = @repository_implementation.get_photo_by_album_and_id(album, id)
    return photo
  end

end
