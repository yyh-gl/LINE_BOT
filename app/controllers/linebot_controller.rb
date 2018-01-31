# coding: utf-8

class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

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
          message = {
            # type: 'text',
            # text: event.message['text']
            type: 'image',
            originalContentUrl: "https://cdnx.natalie.mu/media/news/music/2017/1115/20171027NW00120_fixw_730_hq.jpg",
            previewImageUrl: "https://cdnx.natalie.mu/media/news/music/2017/1115/20171027NW00120_fixw_730_hq.jpg"
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
