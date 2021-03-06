require File.join(File.dirname(__FILE__), "spec_helper")
include CodeObjects

describe YARD::Registry do
  before { Registry.clear }
  it "should have an empty path for root" do
    Registry.root.path.should == ""
  end
  
  it "should #resolve any existing namespace" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ModuleObject.new(o1, :B)
    o3 = ModuleObject.new(o2, :C)
    Registry.resolve(o1, "B::C").should == o3
    Registry.resolve(:root, "A::B::C")
  end
  
  it "should resolve an object in the root namespace when prefixed with ::" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ModuleObject.new(o1, :B)
    o3 = ModuleObject.new(o2, :C)
    Registry.resolve(o3, "::A").should == o1
    
    Registry.resolve(o3, "::String", true).should == P(:String)
  end
  
  it "should resolve instance methods with # prefix" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ModuleObject.new(o1, :B)
    o3 = ModuleObject.new(o2, :C)
    o4 = MethodObject.new(o3, :methname)
    Registry.resolve(o1, "B::C#methname").should == o4
    Registry.resolve(o2, "C#methname").should == o4
    Registry.resolve(o3, "#methname").should == o4
  end
  
  it "should resolve instance methods in the root without # prefix" do
    o = MethodObject.new(:root, :methname)
    Registry.resolve(:root, 'methname').should == o
  end
  
  it "should allow symbols as object type in #all" do
    ModuleObject.new(:root, :A)
    o1 = ClassObject.new(:root, :B)
    o2 = MethodObject.new(:root, :testing)
    r = Registry.all(:method, :class)
    r.should include(o1, o2)
  end
  
  it "should allow code object classes in #all" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ClassObject.new(:root, :B)
    MethodObject.new(:root, :testing)
    r = Registry.all(CodeObjects::NamespaceObject)
    r.should include(o1, o2)
  end
  
  it "should allow #all to omit list" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ClassObject.new(:root, :B)
    r = Registry.all
    r.should include(o1, o2)
  end
  
  it "should respond to #paths" do
    o1 = ModuleObject.new(:root, :A)
    o2 = ClassObject.new(:root, :B)
    Registry.paths.should include('A', 'B')
  end
end