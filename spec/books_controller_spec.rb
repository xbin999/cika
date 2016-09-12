require 'rails_helper'

describe BooksController, :type => :controller do

  describe "GET #index" do

    it "populates an array of books" do
      book1, book2 = FactoryGirl.create(:book), FactoryGirl.create(:book)
      get :index
      expect(assigns(:books)).to match_array([book1, book2])
    end

    it "render the index template" do
      get :index
      expect(response).to render_template("index")
      #expect(response).to  be_success
    end
  end

  describe "GET #new" do

    describe "before login user - " do

      it "render the login template" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "after login user - " do
      login_user

      it "assigns a new Book with name to @book" do
        title = Faker::Book.title
        get :new, :book_name => title
        expect(assigns(:book).name).to eq(title)
      end
    end

  end
  
  describe "POST #create" do

    context "with valid attributes" do
      it "does save the new book in the database" do
        expect{
          post :create, book: FactoryGirl.attributes_for(:book_with_upload)
        }.to change(Book, :count).by(1)
      end      

      it "redirects to the book page" do
        post :create, book: FactoryGirl.attributes_for(:book_with_upload)
        expect(response).to redirect_to(book_path(assigns[:book]))
      end
    end
    
  end 

  describe "GET #search" do
    context "while finding books" do
      it "display all matched books"
      it "renders the :search template"
    end
    
    context "while not finding books" do
      it "display no books found"
      it "renders the :search template"
    end
  end

  describe "GET #show" do

    it "render the show template" do
      book = FactoryGirl.create(:book)
      get :show, id: book.id

      Rails.logger.debug "==== test in rspec #{response.body}"

      #expect(subject.current_user).to be_nil
      expect(response).to render_template("show")
      #expect(response).to be_success
    end
  end

end