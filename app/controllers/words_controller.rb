require 'nokogiri'
require 'open-uri'
require 'json'
require 'bing_translator'

class WordsController < ApplicationController
  def index
    @events = Event.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def new
    @event = Event.new
    @event.name = cookies[:card_name]
    @event.age = cookies[:card_age]
    @event.book = cookies[:card_book]
  end

  def translate
    @event = Event.new(event_params)
    if @event.valid?
      cookies[:card_name] = {value: @event.name, expires: 1.year.from_now}
      cookies[:card_age]  = {value: @event.age, expires: 1.year.from_now}
      cookies[:card_book] = {value: @event.book, expires: 1.year.from_now}

      @source = @event.words
      logger.debug "translate #{@source}..."
      @target = Hash.new

      n = 0
      if @source.include? "#"
        # not #To be or not to be# follow #Harry potter, follow me# 
        @source.scan(/([[:word:]]+)\ *#(.*?)#/).each do |word, sentence|
          begin
            @target[word] = convert(word, sentence)
            n += 1
          rescue URI::InvalidURIError
            logger.error "Error in translating #{word}, ingnore."
            next
          end
        end
      else
        # hello,world,hurry up,good
        @source.split(",").each do |word|
          begin
            @target[word] = convert(word)
            n += 1
          rescue URI::InvalidURIError
            logger.error "Error in translating #{word}, ingnore."
            next
          end
        end
      end
      @event.count = n
      @event.save 

      #render :json => @target.to_json
      #render 'translate'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{@event.name}_#{@event.book}_#{@event.id}",
                 :template => 'words/translate.html.haml',
                 :layout => "pdf.html.haml"
        end
      end
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

  def event_params
    params.require(:event).permit(:name, :words, :age, :book)
  end

end
