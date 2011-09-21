require 'dm-core'
DataMapper.setup(:default, "appengine://auto")

class BlogPage
  include DataMapper::Resource
  property :id, Serial
  property :url, String
  property :title, String
  property :content, Text
  property :private, Boolean, :default  => false

  # belongs_to :directory

  class << self
    def public
      self.all(:private => false)
    end
  end
end

class Settings
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :value, String

  class << self

    # Return admin_api_key, or create it
    def admin_api_key
      self.create(:name => "admin_api_key", :value => self.newpass) unless self.first(:name => "admin_api_key")
      self.first(:name => "admin_api_key").value
    end

    def newpass(len=32)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end

    def generate_config(url)
      {"url" => url, 
        "admin_api_key" => self.admin_api_key
      }
    end

  end

end

# class Directory
#   include DataMapper::Resource
#   property :id, Serial
#   property :name, String

#   has n, :blog_pages
#   is :tree, :order => :name
# end
