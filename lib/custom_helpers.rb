module CustomHelpers
  def load_json( filename )
    @filename = filename
    JSON.parse( IO.read( @filename ) )
  end



end
