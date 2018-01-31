# coding: utf-8

class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'nogi'

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
          if name_match?(MAI_SHIRAISHI, event)
            message = {
              type: 'image',
              originalContentUrl: MAI_SHIRAISHI_IMAGE,
              previewImageUrl: MAI_SHIRAISHI_IMAGE
            }
          elsif name_match?(ERIKA_IKUTA, event)
            message = {
              type: 'image',
              originalContentUrl: ERIKA_IKUTA_IMAGE,
              previewImageUrl: ERIKA_IKUTA_IMAGE
            }
          elsif name_match?(MINAMI_UMEZAWA, event)
            message = {
              type: 'image',
              originalContentUrl: MINAMI_UMEZAWA_IMAGE,
              previewImageUrl: MINAMI_UMEZAWA_IMAGE
            }
          elsif name_match?(ASUKA_SAITOU, event)
            message = {
              type: 'image',
              originalContentUrl: ASUKA_SAITOU_IMAGE,
              previewImageUrl: ASUKA_SAITOU_IMAGE
            }
          else
            # message = {
            #   type: 'text',
            #   text: event.message['text']
            # }
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
end
