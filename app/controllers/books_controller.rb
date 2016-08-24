class BooksController < ApplicationController
  before_action :find_book, only: [:show, :edit, :update, :destroy]
  def index
    #@books = Book.all.order("created_at DESC")
    @books = Book.all.paginate(page: params[:page], per_page: 20).order("created_at DESC")    
  end

  def show
  end

  def new
    @book = Book.new
    @book.name = params[:book_name]

  end

  def create
    @book = Book.new(book_params)
    #byebug

    logger.debug("=== Saving book #{@book.name}")

    if @book.save
      @event = Event.new
      if user_signed_in?
        @event.name = current_user.name
        @event.user_id = current_user.id
      else
        @event.name = cookies[:card_name]
      end
      @event.book_name = @book.name
      @event.book_id = @book.id
      @event.event_type = Event.event_types["newbook"]
      if @event.save 

      else
        logger.debug("=== Error in saving event...#{@event.errors.full_messages}")
      end
      redirect_to book_path(@book), notice: "Successfully created new book"
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "book was successfully update!"
    else
      render 'edit'
    end
  end

  def destroy
    @book.destroy
    redirect_to root_path
  end

  def search
    @query = params[:search][:name]
    logger.debug "===> search #{@query} ..."
    @books = Book.where("name LIKE ?", "%#{@query}%").paginate(page: params[:page], per_page: 15)
  end

  private
  
  def book_params
    params.require(:book).permit(:name,
      :author,
      :isbn,
      :press,
      :description,
      :grade_level,
      :lexile_level,
      :douban_link,
      :scholastic_link,
      :cover,
      :page_number)
  end

  def find_book
    @book = Book.find(params[:id])
  end
end
