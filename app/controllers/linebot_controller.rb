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
            # originalContentUrl: send_image,
            # previewImageUrl: send_image
            originalContentUrl: "https://lh3.googleusercontent.com/TNfqYHdJzMBtdL5pBBR14qAdA-Ff6VxH2x_CpnNtLSHiE8JAHpnXgNCYqbmzjxSAbYd4cAZERsnHFpxSVf4ai_P3J9ZA6AxAFt2wkBh0iLC7CR4ZLxTvilYHG3DkfhEcZU7cHuKdu1bjqmasKdsxavRpeWp1dasJNgAuosB9hMjuhC-CBCLQsVfix87lvWEUyfU2T0dRG9UV3sGhweY0YDz6-kGwiBhV0cgD2PRT21Vw_n04E7dzSlGjYWiMeSZ3Kvn4R0wau2KTBwR5QgRUhaDmCBqqTdHJCLi7r8vTFhZTbtuZI5dK9NvcJdDyp8H_bVh5hPtaehcOKrcADz3bw4ZKTX_aaP6wfITlyZgHeaCc01ZJBcAuTWnNEt_VNOsGbtkaK4sgXeb7A3PiePSpWgLAzU0jb9H37mCKMOuVbI2bQ860BHae8oPCqMo8-swunxW8H21zPgEZmd04UBBBwTPQE4dXWCSpRnG6nHJLeXbXzkonzKhcY_gOrZJwGkTg4fUQwGJdu81zyiBH8MLbZPpoi_V8q8si56LxnyuaQkJQdcRIWf3hwOsgiFxmhjAZVQbfe1Yf7dHjp3rcd8CIwAIqdIHgctGIkb1Otw=w640-h1136-no",
            previewImageUrl: "https://lh3.googleusercontent.com/TNfqYHdJzMBtdL5pBBR14qAdA-Ff6VxH2x_CpnNtLSHiE8JAHpnXgNCYqbmzjxSAbYd4cAZERsnHFpxSVf4ai_P3J9ZA6AxAFt2wkBh0iLC7CR4ZLxTvilYHG3DkfhEcZU7cHuKdu1bjqmasKdsxavRpeWp1dasJNgAuosB9hMjuhC-CBCLQsVfix87lvWEUyfU2T0dRG9UV3sGhweY0YDz6-kGwiBhV0cgD2PRT21Vw_n04E7dzSlGjYWiMeSZ3Kvn4R0wau2KTBwR5QgRUhaDmCBqqTdHJCLi7r8vTFhZTbtuZI5dK9NvcJdDyp8H_bVh5hPtaehcOKrcADz3bw4ZKTX_aaP6wfITlyZgHeaCc01ZJBcAuTWnNEt_VNOsGbtkaK4sgXeb7A3PiePSpWgLAzU0jb9H37mCKMOuVbI2bQ860BHae8oPCqMo8-swunxW8H21zPgEZmd04UBBBwTPQE4dXWCSpRnG6nHJLeXbXzkonzKhcY_gOrZJwGkTg4fUQwGJdu81zyiBH8MLbZPpoi_V8q8si56LxnyuaQkJQdcRIWf3hwOsgiFxmhjAZVQbfe1Yf7dHjp3rcd8CIwAIqdIHgctGIkb1Otw=w640-h1136-no"
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
