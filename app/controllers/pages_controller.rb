class PagesController < ApplicationController
  before_action :get_data
  
  def home
    all_movies
    all_directors
    longest_movie
    first_and_last_wow
    median_wow
  end
  
  def all_movies
    @movies = WowMovie.get_all_movies_name
    sort_param = params[:sort_movies]
    @movies = case sort_param
              when 'release_date'
                @movies.sort_by { |_, data| data['release_date'] }.to_h
              when 'total_wows_in_movie'
                @movies.sort_by { |_, data| data['total_wows_in_movie'] }.reverse .to_h
              when 'name'
                @movies.sort_by { |_, data| _ }.to_h
              else
                @movies
              end
  end
  
  def all_directors
    @directors = WowMovie.get_all_directors
    sort_param = params[:sort_director]
    @directors = case sort_param
                 when 'total_wows'
                   @directors.sort_by { |_, data| data['total_wows'] }.reverse.to_h
                 when 'total_movies'
                   @directors.sort_by { |_, data| data['total_movies'] }.reverse.to_h
                 when 'name'
                   @directors.sort_by { |_, data| _ }.to_h
                 else
                   @directors
                 end
  end

  def longest_movie
    @longest_movie = WowMovie.get_longest_movie
  end

  def first_and_last_wow
    @first_and_last_wow = WowMovie.get_first_and_last_wow
  end

  def median_wow
    @median_wow = WowMovie.get_median_wow
  end


  private 
  def get_data
    WowMovie.get_data
  end
end

