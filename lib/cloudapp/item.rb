module CloudApp
  
  class Item < Base
    
    # Get metadata about a cl.ly URL like name, type, or view count.
    # Finds the item by it's slug id, for example "2wr4"
    # @param [String] cl.ly slug id
    # @return [CloudApp::Item] cl.ly item
    def self.find(id)
      res = get "http://cl.ly/#{id}"
      res.ok? ? Item.new(res) : res
    end
    
    # Page through your items. Optionally pass a hash of parameters.
    #   :page => 1        # Page number starting at 1
    #   :per_page => 5    # Number of items per page
    #   :type => image    # Filter items by type (image, bookmark, text, archive, audio, video, or unknown)
    #   :deleted => true  # Show trashed items
    # Requires authentication.
    # @param [Hash] options parameters
    # @return [Array] of cl.ly items
    def self.all(opts = {})
      res = get "/items?#{opts.to_params}", :digest_auth => @@auth
      res.ok? ? res.collect{|i| Item.new(i)} : res
    end
    
    # Create a new cl.ly item. Can be one of two types
    #   :bookmark         # Bookmark link
    #   :upload           # Upload file
    # Depending on the type of item, a parameter hash is required.
    #   # Bookmark
    #   { :name => "Google", :redirect_url => "http://www.google.com" }
    #   # Upload
    #   { :file => "my_upload.txt" }
    # Requires authentication
    # @param [Symbol] type of cl.ly item
    # @param [Hash] item parameters
    # @return [CloudApp::Item] cl.ly item
    def self.create(kind, opts = {})
      case kind
      when :bookmark
        res = post "/items", {:query => {:item => opts}, :digest_auth => @@auth}
      when :upload
        res = get "/items/new", :digest_auth => @@auth
        return res unless res.ok?
        res = post res['url'], Multipart.new(res['params'].merge!(:file => File.new(opts[:file]))).payload.merge!(:digest_auth => @@auth)
      else
        # TODO raise an error
        return false
      end
      res.ok? ? Item.new(res) : res
    end
    
    # Modify a cl.ly item. Can currently modify it's name or security setting by passing parameters:
    #   # Name
    #   { :name => "Google" }
    #   # Security
    #   { :privacy => true }
    # Requires authentication.
    # @param [String] href of cl.ly item
    # @param [Hash] item parameters
    # @return [CloudApp::Item] cl.ly item
    def self.update(href, opts = {})
      res = put href, {:query => {:item => opts}, :digest_auth => @@auth}
      res.ok? ? Item.new(res) : res
    end
    
    # Send an item to the trash.
    # Requires authentication.
    # @param [String] href of cl.ly item
    # @return [CloudApp::Item] cl.ly item
    def self.delete(href)
      res = Base.delete href, :digest_auth => @@auth
      res.ok? ? Item.new(res) : res
    end
    
    attr_reader :href, :name, :private, :url, :content_url, :item_type, :view_counter,
                :icon, :remote_url, :redirect_url, :created_at, :updated_at, :deleted_at
    
    # Create a new CloudApp::Item object.
    # Only used internally
    # @param [Hash] attributes
    # @param [CloudApp::Item] self
    def initialize(attributes = {})
      load(attributes)
    end
    
    # Modify the cl.ly item. Can currently modify it's name or security setting by passing parameters:
    #   # Name
    #   { :name => "Google" }
    #   # Security
    #   { :privacy => true }
    # Requires authentication.
    # @param [Hash] item parameters
    # @return [CloudApp::Item] cl.ly item
    def update(opts = {})
      self.class.update self.href, opts
    end
    
    # Send the item to the trash.
    # Requires authentication.
    # @return [CloudApp::Item] cl.ly item
    def delete
      self.class.delete self.href
    end
    
    private
    
    # Sets the attributes for Item object
    # @param [Hash] attributes
    def load(attributes = {})
      attributes.each do |key, val|
        self.instance_variable_set("@#{key}", val)
      end
    end
        
  end
  
end