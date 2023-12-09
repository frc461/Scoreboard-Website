require 'sinatra'
require 'puma'
require 'http'
require 'json'
require 'base64'

$base = 'https://frc-api.firstinspires.org/v3.0'
$auth_key = Base64.encode64("scarlett:65aff4eb-f687-4b6f-b793-445667d4965d")
$event_key = ''
$season = Time.new.year
$matches = {} #num: [alliance, rp]

helpers do
  def input(type, name, placeholder)
    "<p><input type=\"#{type}\" id=\"#{name}\" placeholder=\"#{placeholder}\"></p>"
  end
end

get '/' do
  erb :settings
end

post "/" do
  puts "\n\n#{params[:name]} #{$event_key}\n\n"
  thread = Thread.new { get_matches }
  @title = params[:name]
  erb :index
  thread.join
end

get '/update' do #update the scores as needed
  $matches.keys.sort.each do |k|
  $matches[k][1] ||= fetch(k)
  end

  $matches.to_json
end

def fetch match_num #helper method to fetch match results and return rp from a match
  request = HTTP.auth("Basic #{$auth_key}")
                .headers('If-Modified-Since': '', 'Content-Type': 'application/json')
                .get("#{$base}/#{$season}/scores/#{$event_key}/tournamentLevel=Qualification&matchNumber=#{match_num}")
  JSON.parse(request.body)['alliances']['rp']
end

def get_matches
  request = HTTP.auth("Basic #{$auth_key}")
                .headers('If-Modified-Since': '', 'Content-Type': 'application/json')
                .get("#{$base}/#{$season}/schedule/#{$event_key}?tournamentLevel=Qualification&teamNum=461")
  JSON.parse(request.body).each do |match|
    $matches[match['matchNumber'].to_i] = [match['station'].match(/\D+/)[0].capitalize, false]
  end
end
