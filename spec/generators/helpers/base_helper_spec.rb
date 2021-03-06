describe YARD::Generators::Helpers::BaseHelper, "#linkify" do
  include YARD::Generators::Helpers::BaseHelper

  it "should pass off to #link_object if argument is an object" do
    obj = CodeObjects::NamespaceObject.new(nil, :YARD)
    should_receive(:link_object).with(obj)
    linkify obj
  end
  
  it "should pass off to #link_url if argument is recognized as a URL" do
    url = "http://yard.soen.ca/"
    should_receive(:link_url).with(url)
    linkify url
  end
end