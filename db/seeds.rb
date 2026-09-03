starter_genres = [
  "Alternative",
  "Blues",
  "Boom Bap",
  "Classical",
  "Country",
  "Dance",
  "Dancehall",
  "Disco",
  "Drill",
  "Drum and Bass",
  "Drumless Hip Hop",
  "Electronic",
  "Emo",
  "Folk",
  "Funk",
  "Gospel",
  "Grime",
  "Hard Rock",
  "Hip-Hop",
  "House",
  "Indie",
  "Jazz",
  "Jazz Rap",
  "Latin",
  "Metal",
  "Neo Soul",
  "Pop",
  "Punk",
  "R&B",
  "Rap",
  "Reggae",
  "Rock",
  "Soul",
  "Techno",
  "Trap"
]

starter_genres.each do |genre_name|
  Genre.find_or_create_by!(name: genre_name) do |genre|
    genre.description = "A music genre available in Crate Digger."
  end
end

puts "Seeded #{Genre.count} genres."
