#import libraries
require 'sinatra'
require 'puma'
require 'http'
require 'json'
require 'pry'

#global variables for querying the api
$base = 'https://frc-api.firstinspires.org/v3.0'
$username = "scarlett"
$password = "65aff4eb-f687-4b6f-b793-445667d4965d"
$event_key = ''
$season = 2023 #Time.new.year
$matches = {} #num: [alliance, rp]

helpers do
  def input(type, name, placeholder)
    "<p><input type=\"#{type}\" name=\"#{name}\" placeholder=\"#{placeholder}\"></p>"
  end
end

get '/' do
  erb :settings
end

post "/" do
  $event_key = params[:key]
  thread = Thread.new { get_matches }
  @title = params[:name]
  erb :index
  thread.join

  # binding.pry
end

get '/update' do #update the scores as needed
  $matches.keys.sort.each do |k|
  $matches[k][1] ||= fetch(k)
  end

  $matches.to_json
end

def color_to_number color
  if color == "Red"
    1
  else
    0
  end
end

def fetch match_num #helper method to fetch match results and return rp from a match
  request = HTTP.basic_auth(user: $username, pass: $password)
                .headers('Content-Type': 'application/json')
                .get("#{$base}/#{$season}/scores/#{$event_key}/qual?matchNumber=#{match_num}")
  JSON.parse(request.body)['MatchScores'][0]['alliances'][color_to_number($matches)]['rp']
end

def get_matches
  request = HTTP.basic_auth(user: $username, pass: $password)
                .headers('Content-Type': 'application/json')
                .get("#{$base}/#{$season}/schedule/#{$event_key}?tournamentLevel=Qualification&teamNumber=461")
  JSON.parse(request.body)["Schedule"].each do |match| #the structure of the response is silly, but this will find the alliance color
    match['teams'].each do |team|
      if team['teamNumber'] == 461
        $matches[match['matchNumber'].to_i] = [team['station'].match(/\D+/)[0].capitalize, false]
        break
      end
    end
  end
end
