# coding: utf-8

class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'net/https'
  require 'uri'
  require 'json'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          split_words = event.message['text'].split
          target = split_words[0] # 「かもん」
          keyword = split_words[1..split_words.size-1].join('+')
          if target != "かもん" || keyword.blank?
            head :no_content
            return
          end
          count = 0
          loop do
            @send_image = getImageUrls(keyword)
            break if @send_image.match(/https:/)
            count += 1
            if count == 50
              head :no_content
              return
            end
          end
          message = {
            type: 'image',
            originalContentUrl: @send_image,
            previewImageUrl: @send_image
          }
          client.reply_message(event['replyToken'], message)          
        end
      end
    }

    head :ok
  end

  private

  def getImageUrls(keyword)
    count = '1'
    offset = rand(50).to_s

    if ENV["BING_API_KEY"].length != 32 then
      puts "Invalid Bing Search API subscription key!"
      puts "Please paste yours into the source code."
      abort
    end

    uri = URI(BING_IMAGE_SEARCH_URI + BING_IMAGE_SEARCH_PATH + "?q=" + URI.escape(keyword) + "&count=" + count + "&offset=" + offset)

    request = Net::HTTP::Get.new(uri)
    request['Ocp-Apim-Subscription-Key'] = ENV["BING_API_KEY"]

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    json = JSON.parse(response.body)
    pp json["value"][0]["contentUrl"]
    return json["value"][0]["contentUrl"]
  end
    
end
