# coding: utf-8

class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'net/https'
  require 'uri'
  require 'json'
  require_relative '../../config/nogi'

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
          loop do
            @send_image = getImageUrls(event.message['text'])
            break if @send_image.match(/https:/)
          end
          message = {
            type: 'image',
            originalContentUrl: @send_image,
            previewImageUrl: @send_image
          }
          if name_match?(HELP, event)
            message = {
              type: 'text',
              text: "今ひまなのは\n#{ALL}たちだよ"
            }
          end
          client.reply_message(event['replyToken'], message)          
        end
      end
    }

    head :ok
  end

  private

  def name_match?(name_list, event)
    name_list.each do |name|
      if event.message['text'].match(/#{name}/) != nil
        return true
      end
    end
    return false
  end

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
