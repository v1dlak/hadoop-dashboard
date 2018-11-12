require 'twitter'
require 'json'

class SearchTwitter

  def initialize(search, name)
    @twitter = Twitter::REST::Client.new({
      consumer_key: "{{ pillar['pass.twitter.consumer_key'] }}",
      consumer_secret: '{{ pillar['pass.twitter.consumer_secret'] }}',
      access_token: '{{ pillar['pass.twitter.access_token'] }}',
      access_token_secret: '{{ pillar['pass.twitter.access_token_secret'] }}',
      proxy: {
        uri: Addressable::URI.parse("http://proxy:3128"),
      }
    })
    @search_term = URI::encode(search)
    @name = name
  end

  def getTweets()
    begin
      tweets = @twitter.search("#{@search_term}")
      puts tweets

      if tweets
        tweets = tweets.map do |tweet|
          { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https.to_s }
        end
        send_event("twitter_mentions_#{@name}", comments: tweets)
      end
    rescue Twitter::Error => error
      puts "\e[33mThere was an error with Twitter\e[0m"
      puts error
    end
  end
end

ftx = SearchTwitter.new('@hledani_seznam OR #seznambot', 'ftx')
skl = SearchTwitter.new('@Sklik', 'skl')
cld = SearchTwitter.new('@Cloudera', 'cld')
bla = SearchTwitter.new('@tondablanik', 'bla')
zai = SearchTwitter.new('@PeterZaitsev', 'zai')
szn = SearchTwitter.new('@seznam_cz', 'szn')

SCHEDULER.every '5m', :first_in => 0 do |job|
  ftx.getTweets()
  skl.getTweets()
  cld.getTweets()
  bla.getTweets()
  zai.getTweets()
  szn.getTweets()
end
