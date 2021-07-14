require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color::YELLOW
BOTTOM_COLOR = Gosu::Color::BLUE

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']



class Album
	attr_accessor :primary_key, :title, :artist,:artwork, :genre, :tracks
	def initialize (primary_key, title, artist,artwork, genre, tracks)
	  @primary_key = primary_key
	  @title = title
	  @artist = artist
	  @artwork = artwork
	  @genre = genre
	  @tracks = tracks
	 end
  end


  class Track 
	attr_accessor :track_key, :name, :location
    def initialize (track_key, name, location)
      @track_key = track_key
      @name = name
      @location = location
     end
end


class ArtWork 
	attr_accessor :bmp

	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

class Song
	attr_accessor :song
	def initialize (file)
		@song = Gosu::Song.new(file)
	end
end


# Put your record definitions here

class MusicPlayerMain < Gosu::Window

	def initialize
	    super 600, 600
	    self.caption = "GUI Music Player"

		@font = Gosu::Font.new(20)
		@a = 0
		@t = 0
		@albums = nil
		@locs = [60,60]
		# Reads in an array of albums from  file and then prints all the albums in the
		# array to the terminal
	end


	def load_album()
	music_file = File.new("album.txt", "r")

	def read_track (music_file, index)
		track_key = index
		track_name = music_file.gets
		track_location = music_file.gets
		track = Track.new(track_key, track_name, track_location)
		return track
	end


	def read_tracks(music_file)
		count = music_file.gets.to_i
		tracks = Array.new()
		index = 0
		while (index < count)
			track = read_track(music_file, index+1)
			tracks << track
			index += 1
		end
	return tracks
	end

	def read_album(music_file, index)
		album_primary_key = index
		album_title = music_file.gets.chomp
		album_artist = music_file.gets
		album_artwork = music_file.gets.chomp
		album_genre = music_file.gets.to_i
		album_tracks = read_tracks(music_file)
		album = Album.new(album_primary_key, album_title, album_artist,album_artwork, album_genre, album_tracks)
		return album
	end

	def read_albums(music_file)
		count = music_file.gets.to_i
		albums = Array.new()
		index = 0
			while index < count
				album = read_album(music_file, index + 1)
				albums << album
				index += 1
			end

		return albums
	end
	albums = read_albums(music_file)
	return albums
	end




  # Draws the artwork on the screen for all the album
  # Detects if 'mouse sensitive' area has been clicked on
  # i.e either an album or track. returns true or false



  def draw_albums(albums)

	@bmp = Gosu::Image.new(albums[0].artwork)
	@bmp.draw(50, 50 , z = ZOrder::PLAYER)

	@bmp = Gosu::Image.new(albums[1].artwork)
	@bmp.draw(50, 310, z = ZOrder::PLAYER)

  end




 # Draws the album images and the track list for the selected album

 def draw_background()
	draw_quad(0,0, TOP_COLOR, 0, 600, TOP_COLOR, 600, 0, BOTTOM_COLOR, 600, 600, BOTTOM_COLOR, z = ZOrder::BACKGROUND)
	end

	def draw
		albums = load_album()
		# Complete the missing code
		draw_albums(albums)
		x = 250
		y = 0
		index = 0
		draw_background()

		if (!@song)
			while index < albums.length
				@font.draw("#{albums[index].title}", x+100 , y+=50, ZOrder::UI, 1.0, 1.0, Gosu::Color::RED)
				index += 1
			end
		else
			while index < albums[@a-1].tracks.length
				@font.draw("#{albums[@a-1].tracks[index].name}", x , y+=25, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
				if (albums[@a-1].tracks[index].track_key == @t)
					@font.draw("==>", x-20 , y, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
				end
				index += 1
			end
		end
	end


 	def needs_cursor?; true; end


	def playTrack(t, a)

		albums = load_album()
		index = 0
		while index < albums.length
			if (albums[index].primary_key == a)
				tracks = albums[index].tracks
				j = 0
						while j < tracks.length
								if (tracks[j].track_key == t)
									@song = Gosu::Song.new(tracks[j].location)
									@song.play(true)
								end
								j+=1
						end
			end
			index += 1
		end
	end


	def update()
	if (@song)
			if (!@song.playing?)
				@t+=1
			end
		end
 	end


  def area_clicked(mouse_x, mouse_y)

	if ((mouse_x >50 && mouse_x < 201) && (mouse_y > 50 && mouse_y < 201 ))# 1st album
		@a = 1
		@t = 1
		playTrack(@t, @a)
	end

	if ((mouse_x > 50 && mouse_x < 210) && (mouse_y > 310 && mouse_y <470))# 2nd album
		@a = 2
		@t = 1
		playTrack(@t, @a)
	end
  end



	# If the button area (rectangle) has been clicked on change the background color
	# also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
	# you will learn about inheritance in the OOP unit - for now just accept that
	# these are available and filled with the latest x and y locations of the mouse click.


	def button_down(id)
		case id
	    	when Gosu::MsLeft
			@locs = [mouse_x, mouse_y]
			area_clicked(mouse_x, mouse_y)
	    	
		end
	end
end



# Show is method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
