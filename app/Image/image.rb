# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Image
  include Rhom::FixedSchema
  
  set :schema_version, '0.1'
  # Uncomment the following line to enable sync with Image.
  # enable :sync

  #add model specifc code here
  property :image_uri,              :blob
end
