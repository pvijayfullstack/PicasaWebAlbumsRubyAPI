require 'net/http'
require 'net/https'
require 'rexml/document'
require 'date'
require_relative 'photo.rb'
require_relative 'album.rb'

class PicasaPhotoRepository
  
  def initialize(email, password)
    @email = email
    @authentication_token = get_authentication_token(email, password)
  end

  def get_albums
    xml = get_multiple_album_xml
    albums = []    
    xml.elements.each("//entry") do |entry|
      gallery = Album.new
      gallery.id = entry.elements["gphoto:id"].text
      gallery.title = entry.elements["title"].text
      gallery.date_created = DateTime.parse(entry.elements["published"].text)
      gallery.date_updated = DateTime.parse(entry.elements["updated"].text)
      gallery.slug = entry.elements["gphoto:name"].text
      gallery.cover_photo_url = entry.elements["media:group/media:content"].attributes["url"]
      gallery.description = entry.elements["media:group/media:description"].text
      albums << gallery
    end
    return albums
  end

  def get_album_by_id(id)
    albums = get_albums
    index_of_album_with_id = albums.find_index{|album| album.id == id.to_s}
    album_to_return = albums[index_of_album_with_id]
    return album_to_return
  end

  def get_album_by_title(title)
    albums = get_albums
    index_of_album_with_title = albums.find_index{|album| album.title == title.to_s}
    album_to_return = albums[index_of_album_with_title]
    return album_to_return
  end

  def get_album_by_slug(slug)
    albums = get_albums
    index_of_album_with_slug = albums.find_index{|album| album.slug == slug.to_s}
    album_to_return = albums[index_of_album_with_slug]
    return album_to_return
  end

  def get_photos(album)
    xml = get_single_album_xml(album.id)
    photos = []
    xml.elements.each("//entry") do |entry|
      photo = Photo.new
      photo.id = get_photo_id_from_photo_id_url(entry.elements["id"].text)
      photo.url = entry.elements["media:group/media:content"].attributes["url"]
      photo.width = entry.elements["media:group/media:content"].attributes["width"].to_i
      photo.height = entry.elements["media:group/media:content"].attributes["height"].to_i
      photo.caption = entry.elements["media:group/media:description"].text
      photo.file_name = entry.elements["media:group/media:title"].text
      photos << photo
    end    
    return photos
  end

  def get_photo_by_album_and_id(album, id)
    photos = get_photos(album)
    photo_to_return = Photo.new
    photos.each do |photo|
      if photo.id == id
        photo_to_return = photo
      end
    end
    return photo_to_return
  end

  private

    def get_photo_id_from_photo_id_url(photo_id_url)
      start_index = photo_id_url.index('/photoid/') + 9
      slice_of_id_url_to_end = photo_id_url[start_index..-1]
      end_index = slice_of_id_url_to_end.index(/[?|\/]/)
      id = slice_of_id_url_to_end[0...end_index]
      return id
    end

    def get_authentication_token(email, password)
        http = Net::HTTP.new('www.google.com', 443)
        http.use_ssl = true
        path = "/accounts/ClientLogin"
        data = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=lh2&source=someapp1"
        response, body = http.post(path, data)
        start_index = body.index('Auth=')
        slice_of_auth_to_end = body[start_index..-1]
        end_index = slice_of_auth_to_end.index("\n")
        auth_string = slice_of_auth_to_end[0...end_index]
        auth_token = "GoogleLogin #{auth_string}"
        return auth_token
    end

    def get_multiple_album_xml
      http = Net::HTTP.new('picasaweb.google.com')
      path = "/data/feed/api/user/#{@email}?kind=album&access=all"
      headers = {
        'Authorization' => @authentication_token
      }
      response, body = http.get(path, headers)
      xml = REXML::Document.new(body)
      return xml
    end

    def get_single_album_xml(album_id)
      http = Net::HTTP.new('picasaweb.google.com')
      path = "/data/feed/base/user/#{@email}/albumid/#{album_id}"
      headers = {
        'Authorization' => @authentication_token
      }
      response, body = http.get(path, headers)
      xml = REXML::Document.new(body)
      return xml
    end

end
