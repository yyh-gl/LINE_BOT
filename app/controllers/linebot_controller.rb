# coding: utf-8

class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
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
          if name_match?(MAI_SHIRAISHI, event)
            send_image = MAI_SHIRAISHI_IMAGE.sample            
          elsif name_match?(ERIKA_IKUTA, event)
            send_image = ERIKA_IKUTA_IMAGE.sample
          elsif name_match?(MINAMI_UMEZAWA, event)
            send_image = MINAMI_UMEZAWA_IMAGE.sample
          elsif name_match?(ASUKA_SAITOU, event)
            send_image = ASUKA_SAITOU_IMAGE.sample
          elsif name_match?(RINA_IKOMA, event)
            send_image = RINA_IKOMA_IMAGE.sample
          else
            # message = {
            #   type: 'text',
            #   text: event.message['text']
            # }
          end
          message = {
            type: 'image',
            originalContentUrl: send_image,
            previewImageUrl: send_image
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
end
