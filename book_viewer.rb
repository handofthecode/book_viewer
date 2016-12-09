require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do ## defines methods to help process or format text
  def chapter_to_array(chapter)
    chapter.split("\n\n").map.with_index do |paragraph, index| 
      "<p id=\"#{index}\">#{paragraph}</p>"
    end
  end
  def find_paragraphs_and_bold_query(chap, q)
    chap.each do |c| 
      c.select! { |p| p.include? q }.map! { |p| p.gsub(q, "<strong>#{q}</strong>") }
    end
  end
end

before do ## instantiates variables that can be seen by get methods
  @chapters = File.readlines("data/toc.txt")
  @book_hash = @chapters.each_with_index.with_object({}) do |(chapter, num), hash|
    hash[chapter] = chapter_to_array File.read("data/chp#{num + 1}.txt")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapter/:number" do
  number = params[:number]
  @title = "Chapter #{number}: #{@chapters[number.to_i - 1]}"
  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  if params[:query]
    @found = @book_hash.dup
    find_paragraphs_and_bold_query(@found.values, params[:query])
  end
  erb :search
end

not_found do
  redirect "/"
end