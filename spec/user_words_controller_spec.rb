require 'rails_helper'

describe UserWordsController, :type => :controller do

  describe "GET #index" do
    before(:each) do
      @event1, @event2 = FactoryGirl.create(:event_with_user_words), FactoryGirl.create(:event_with_user_words)

      #puts @event1.inspect
      #puts @event1.book.inspect
      #puts "=== user words count: #{@event1.user_words.count}"
      #puts @event2.inspect
      #puts @event2.book.inspect
      #puts @event2.user_words.count

    end

    it "render the translate template if event is found" do
      get :index, event_id: @event1.id
      expect(response).to render_template("user_words/index")
    end

    it "redirect_to root_path if event is not found" do
      get :index, event_id: 99999
      expect(response).to redirect_to(root_path)
    end

    it "get event and matched user words" do
      get :index, event_id: @event1.id
      #puts "=== user words count: #{@event1.user_words.count} in it"
      #puts "=== target: #{assigns(:target).inspect} in it"
      expect(assigns(:target).size).to eq(@event1.user_words.count)
    end
  end
end