require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CloudApp::Client do
  
  before(:each) do
    fake_it_all
    CloudApp.authenticate "testuser@test.com", "password"
    @client = CloudApp::Client.new
  end
  
  it "should be reautheticatable" do
    username = "joe.bloggs@testing.com"
    password = "password"
    auth = @client.authenticate username, password
    auth[:username].should == username
  end
  
  it "should find an item" do
    item = @client.item "2wr4"
    item.should be_a_kind_of CloudApp::Item
  end
  
  it "should list all items" do
    items = @client.items
    items.should be_a_kind_of Array
    items.each do |item|
      item.should be_a_kind_of CloudApp::Item
    end
  end
  
  it "should bookmark an item" do
    name = "CloudApp"
    item = @client.bookmark "http://getcloudapp.com", name
    item.should be_a_kind_of CloudApp::Item
    item.name.should == name
  end
  
  it "should bookmark multiple items" do
    # overwrite the normal fake uri for this spec
    FakeWeb.register_uri :post, 'http://my.cl.ly/items', :response => stub_file(File.join('item', 'index'))
    bookmarks = [
      { :name         => "Authur Dent",       :redirect_url => "http://en.wikipedia.org/wiki/Arthur_Dent" },
      { :name         => "Ford Prefect",      :redirect_url => "http://en.wikipedia.org/wiki/Ford_Prefect_(character)"},
      { :name         => "Zaphod Beeblebrox", :redirect_url => "http://en.wikipedia.org/wiki/Zaphod_Beeblebrox" }
    ]
    items = @client.bookmark bookmarks
    items.should be_a_kind_of Array
    items.each do |item|
      item.should be_a_kind_of CloudApp::Item
    end
  end
  
  it "should upload a file" do
    item = @client.upload "README.md"
    item.should be_a_kind_of CloudApp::Item
    item.item_type.should == "image"
  end
  
  it "should upload a file with specific privacy" do
    # override the upload fakeweb uri
    FakeWeb.register_uri :post, 'http://f.cl.ly', :status => ["303"], :location => "http://my.cl.ly/items/s3?item[private]=true"
    item = @client.upload "README.md", :private => true
    item.should be_a_kind_of CloudApp::Item
    item.private.should == true
  end
  
  it "should rename an item" do
    name = "CloudApp"
    item = @client.rename "2wr4", name
    item.should be_a_kind_of CloudApp::Item
    item.name.should == name
  end
  
  it "should set an items privacy" do
    item = @client.privacy "2wr4", false
    item.should be_a_kind_of CloudApp::Item
    item.private.should == false
  end
  
  it "should delete an item" do
    item = @client.delete "2wr4"
    item.should be_a_kind_of CloudApp::Item
    item.deleted_at.should be_a_kind_of Time
  end
  
  it "should recover an item" do
    item = @client.recover "2wr4"
    item.should be_a_kind_of CloudApp::Item
    item.deleted_at.should == nil
  end
  
end
