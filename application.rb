require 'sinatra'
require 'sinatra/content_for'

require 'haml'
require 'sass'
require 'date'
require 'scripture_lookup'

set :haml, :format => :html5
set :bind, '0.0.0.0'

get '/' do
  haml :inputs
end

post '/' do
  # Get the list of dates
  @from = Date.parse(params["from_date"])
  @to = Date.parse(params["to_date"])

  @notes = params['student_notes']
  @subtitle = params['subtitle']
  @name  = params['name']
  @journal_dates = @from...@to

  @books = params['book_list'].split("\n").compact

  # Chores
  @chores = {
    1 => {
        :visible => !!params['include_monday'],
        :chores  => params['monday_chores'].split("\n").compact,
      },
    2 => {
        :visible => !!params['include_tuesday'],
        :chores  => params['tuesday_chores'].split("\n").compact,
      },
    3 => {
        :visible => !!params['include_wednesday'],
        :chores  => params['wednesday_chores'].split("\n").compact,
      },
    4 => {
        :visible => !!params['include_thursday'],
        :chores  => params['thursday_chores'].split("\n").compact,
      },
    5 => {
        :visible => !!params['include_friday'],
        :chores  => params['friday_chores'].split("\n").compact,
      },
    6 => {
        :visible => !!params['include_saturday'],
        :chores  => params['saturday_chores'].split("\n").compact,
      },
    0 => {
        :visible => !!params['include_sunday'],
        :chores  => params['sunday_chores'].split("\n").compact,
      }
  }
  provider = ScriptureLookup.new

  @verses = params["verse_list"].split("\n").map(&:strip).map do |ref|
    verse = provider.lookup(ref, :NASB).response_data[:content].to_a.first[1][:verse].first
    {:verse => verse, :ref => ref}
  end.sort {rand}

  @pages = []

  haml :journal
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :style
end

helpers do
  def page_number(type, title)
    @pages << [type, title]
    "<div class='page-number'>#{@pages.length}</div>"
  end
end
