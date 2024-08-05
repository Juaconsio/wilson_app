class WowMovie < ApplicationRecord
  BASE_URL ='https://owen-wilson-wow-api.onrender.com/'
  TOTAL_WOWS = 91
  def self.conn 
    Faraday.new(url: BASE_URL)
  end

  def self.get_data
    self.get_wows
    self.set_data
  end

  def self.get_wows
    response = self.conn.get do |req|
      req.url "wows/random?results=#{TOTAL_WOWS}"
    end

    @wows = JSON.parse(response.body).sort_by {|wow| wow['release_date']}
  end


  def self.set_data
    @movies = Hash.new
    @directors = Hash.new
    @wows.each do |wow|
      if not @movies.has_key?(wow['movie'])        
        @movies[wow['movie']] = {
          'total_wows_in_movie' => wow['total_wows_in_movie'],
          'poster' => wow['poster'],
          'release_date' => wow['release_date'],
          'movie_duration' => wow['movie_duration'],
          'director' => wow['director']
        }
      end
      if @directors.has_key?(wow['director'])
        if not @directors[wow['director']]['movies'].any? { |movie| movie['name'] == wow['movie'] }
            @directors[wow['director']]['movies'].push(
              {
                'name' => wow['movie'],
                'total_wows_in_movie' => wow['total_wows_in_movie'],
                'poster' => wow['poster'],
                'release_date' => wow['release_date']
              }
            )
            @directors[wow['director']]['total_wows'] += wow['total_wows_in_movie']
            @directors[wow['director']]['total_movies'] += 1
          end
      else
        @directors[wow['director']] = {
          'movies' => [{
            'name' => wow['movie'],
            'total_wows_in_movie' => wow['total_wows_in_movie'],
            'poster' => wow['poster'],
            'release_date' => wow['release_date']
          }],
          'total_wows' => wow['total_wows_in_movie'],
          'total_movies' => 1
        }
      end
    end
  end


  def self.get_all_movies_name
    @movies
  end

  def self.get_all_directors
    @directors
  end

  def self.get_longest_movie
    @movies.max_by { |_, data| self.duration_to_seconds(data['movie_duration']) }
  end

  def self.duration_to_seconds(duration)
    hours, minutes, seconds = duration.split(':').map(&:to_i)
    (hours * 3600) + (minutes * 60) + seconds
  end
  

  def self.get_first_and_last_wow
    order_by_time_wows = @wows.sort_by { |wow| wow['timestamps'] }.reverse
    first_wow = order_by_time_wows.first
    last_wow = order_by_time_wows.last
    {'first_wow' => first_wow, 'last_wow' => last_wow}
  end

  def self.get_median_wow
    order_wows = @wows.sort_by { |wow| [wow['release_date'], wow['timestamps']] }
    puts "order_wows: #{order_wows.length}"
    if order_wows.length.odd?
      puts "order_wows: #{order_wows.length / 2 + 1 }"
      [order_wows[order_wows.length / 2 + 1]]
    else
      puts "order_wows: #{order_wows.length / 2 - 1} #{order_wows.length / 2 + 1}"
      [order_wows[order_wows.length / 2 ], order_wows[order_wows.length / 2 + 1] ]
    end
  end

end
