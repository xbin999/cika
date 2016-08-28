require 'rails_helper'

describe Book do
  describe "#rename_image_file" do

    context "When filename is file.JPG" do

      book = Book.new( :cover_file_name => "file.JPG")
      book.rename_image_file

      it "should ext is downcase" do
        expect(File.extname(book.cover_file_name)).to eq(".jpg")
      end

      it "should basename is hex random 12" do
        expect(File.basename(book.cover_file_name).length).to eq(12*2+4)
      end

    end

  end
end