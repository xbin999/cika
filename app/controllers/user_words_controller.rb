class UserWordsController < ApplicationController
  def index
    @event = Event.find(params[:event_id])

    @target = Hash.new
    
    @event.user_words.each do |uw|
      @target[uw.word] = uw.sentence
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@event.name}_#{@event.book}_#{@event.id}",
               :template => 'words/translate.html.haml',
               :layout => "pdf.html.haml"
      end
    end
  end

end
