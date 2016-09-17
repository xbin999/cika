# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'json'
require 'bing_translator'

class WordsController < ApplicationController
  #before_action :show_message, only: [:new]
  before_action :authenticate_user!, only: [:new, :translate]

  def index
    #byebug
    @events = Event.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def cards
    if user_signed_in?
      @mycards = Event.includes(:book).where("user_id=? and event_type=?", current_user.id, Event.event_types["newcard"]).paginate(page: params[:page], per_page: 20).order(created_at: :desc)
    end
    @recentcards = Event.includes(:book).where("event_type=?", Event.event_types["newcard"]).paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def new
    @event = Event.new
    if user_signed_in?
      @event.name = current_user.name
      @event.user_id = current_user.id
    else
      @event.name = cookies[:card_name]
    end
    @event.age = cookies[:card_age]
    #@event.book_name = cookies[:card_book]
    @event.book_id = params[:book_id]
    @event.book_name = params[:book_name]
  end

  def translate
    @event = Event.new(event_params)
    @event.event_type = Event.event_types["newcard"]
    if @event.valid?
      cookies[:card_name] = {value: @event.name, expires: 1.year.from_now}
      cookies[:card_age]  = {value: @event.age, expires: 1.year.from_now}
      cookies[:card_book] = {value: @event.book_name, expires: 1.year.from_now}

      @source = @event.words
      logger.debug "translate #{@source}..."
      @target = Hash.new
      @error_words = Array.new
      n = 0
      sep = get_sep(@source)

      if sep == "#"
        # not #To be or not to be# follow #Harry potter, follow me#
        @source.scan(/([[:word:]]+)\ *#(.*?)#/).each do |word, sentence|
          if saveto_targets(word, sentence)
            n += 1
          end
        end
      else
        # hello,world,hurry up,good
        # or hello word
        @source.split(sep).each do |word|
          if saveto_targets(word)
            n += 1
          end
        end
      end
      @event.count = n

      @target.each do |word, value|
        @event.user_words.build(:word => word, :sentence => value, :book_id => @event.book_id, :user_id => @event.user_id)
      end
      if @event.save
        logger.info("=== Success in saving event: #{@event.id}")
        if @error_words.empty?
          redirect_to event_user_words_path(@event), notice: "成功创建词卡。"
        else
          redirect_to event_user_words_path(@event), notice: "成功创建词卡，剩余错误单词: #{@error_words.join(',')}"
        end
      else
        logger.error("=== Error in saving event...#{@event.errors.full_messages}")
        flash[:error] = @event.errors.full_messages.to_sentence
        render "words/new.html.haml"
      end

      #render :json => @target.to_json
      #render 'translate'
=begin
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{@event.name}_#{@event.book}_#{@event.id}",
                 :template => 'words/translate.html.haml',
                 :layout => "pdf.html.haml"
        end
      end
=end
    else
      flash[:error] = @event.errors.full_messages.to_sentence
      render "words/new.html.haml"
      #redirect_to translate_path
    end

  end

private
  def convert(source, sentence=nil)
    target ||= []
    # http://fanyi.youdao.com/openapi.do?keyfrom=XXXXXX&key=XXXXXXXX&type=data&doctype=json&version=1.1&q=hello
    logger.debug "http://fanyi.youdao.com/openapi.do?keyfrom=#{Rails.configuration.mysecrets['keyfrom']}&key=#{Rails.configuration.mysecrets['key']}&type=data&doctype=json&version=1.1&q=#{source}"
    doc = JSON.parse(open(URI.escape("http://fanyi.youdao.com/openapi.do?keyfrom=#{Rails.configuration.mysecrets['keyfrom']}&key=#{Rails.configuration.mysecrets['key']}&type=data&doctype=json&version=1.1&q=#{source}")).read)
    if doc.fetch('basic',{}).fetch('explains',nil) != nil
      if doc.fetch('basic',{}).fetch('us-phonetic',nil) != nil
        target << "us: [#{doc['basic']['us-phonetic']}]  uk: [#{doc['basic']['uk-phonetic']}]"
      else
        if doc.fetch('basic',{}).fetch('phonetic',nil) != nil
          target << "[#{doc['basic']['phonetic']}]"
        end
      end
      doc['basic']['explains'].each do |link|
        logger.debug "---> translate to #{link}"
        target << link
      end
      if sentence != nil
        target << sentence
      end
    end

    return target
  end

  def convert2object(source)
    source = source.strip
    word = Word.find_by name: source
    if word == nil
      begin
        # http://fanyi.youdao.com/openapi.do?keyfrom=XXXXXX&key=XXXXXXXX&type=data&doctype=json&version=1.1&q=hello
        logger.debug "http://fanyi.youdao.com/openapi.do?keyfrom=#{Rails.configuration.mysecrets['keyfrom']}&key=#{Rails.configuration.mysecrets['key']}&type=data&doctype=json&version=1.1&q=#{source}"
        doc = JSON.parse(open(URI.escape("http://fanyi.youdao.com/openapi.do?keyfrom=#{Rails.configuration.mysecrets['keyfrom']}&key=#{Rails.configuration.mysecrets['key']}&type=data&doctype=json&version=1.1&q=#{source}")).read)
      rescue URI::InvalidURIError
        logger.error "Error in translating #{word}, ingnore."
        return nil
      end

      word = Word.new
      word.name = source
      word.translate_tool = "youdao"

      if doc.fetch('basic',{}).fetch('explains',nil) != nil
        if doc.fetch('basic',{}).fetch('us-phonetic',nil) != nil
          word.us_phonetic = doc['basic']['us-phonetic']
          word.uk_phonetic = doc['basic']['uk-phonetic']
          word.translate_type = "英译中"
        else
          if doc.fetch('basic',{}).fetch('phonetic',nil) != nil
            word.phonetic = doc['basic']['phonetic']
            word.translate_type = "中译英"
          end
        end
        word.explains = ""
        doc['basic']['explains'].each do |link|
          word.explains << link << "\n"
        end
      end
      if word.save
        logger.info("=== Success in saving word: #{word.id}:#{word.name}")
      else
        logger.error("=== Error in saving word...#{word.errors.full_messages}")
        return nil
      end
    end

    return word
  end

  def saveto_targets(word, sentence=nil)
    rv = false

    if !word.strip.blank?
      w = convert2object(word)
      if w != nil
        @target[w] = sentence
        rv = true
      else
        @error_words << word
      end
    end
    return rv
  end

  def get_sep(source)
    if source.include? "#"
      sep = "#"
    else
      if @source.include? ","
        sep = ","
      else
        sep = " "
      end
    end
    return sep
  end

  def event_params
    params.require(:event).permit(:name, :words, :age, :book_name, :book_id, :user_id)
  end

  def show_message
    if !user_signed_in?
      flash[:notice] = "建议先登录，选择对应的书再制卡。"
    end
  end

  def save_words(wordsMap)
  end

end
