require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::ClassObject do
  before do 
    Registry.clear 
    @mixin = ModuleObject.new(:root, :SomeMixin)
    @mixin2 = ModuleObject.new(:root, :SomeMixin2)
    @superyard = ClassObject.new(:root, :SuperYard)
    @superyard.superclass = P("String")
    @superyard.mixins << @mixin2
    @yard = ClassObject.new(:root, :YARD)
    @yard.superclass = @superyard
    @yard.mixins << @mixin
  end
  
  it "should show the proper inheritance tree" do
    @yard.inheritance_tree.should == [@yard, @superyard, P(:String)]
  end
  
  it "should show proper inheritance tree when mixins are included" do
    @yard.inheritance_tree(true).should == [@yard, @mixin, @superyard, P(:String)]
  end
end

describe YARD::CodeObjects::ClassObject, "#meths / #inherited_meths" do
  before do 
    Registry.clear 
    
    Parser::SourceParser.parse_string <<-eof
      class SuperYard < String
        def foo; end
        def foo2; end
        def bar; end
        def middle; end
        protected :foo2
        private
        def self.bar; end
      end
      
      class MiddleYard < SuperYard
        def middle; end
      end
      
      class YARD < MiddleYard
        def mymethod; end
        def bar; end
      end
    eof
  end
  
  it "should show inherited methods by default" do
    meths = P(:YARD).meths
    meths.should include(P("YARD#mymethod"))
    meths.should include(P("SuperYard#foo"))
    meths.should include(P("SuperYard#foo2"))
    meths.should include(P("SuperYard::bar"))
  end
  
  it "should allow :inherited to be set to false" do
    meths = P(:YARD).meths(:inherited => false)
    meths.should include(P("YARD#mymethod"))
    meths.should_not include(P("SuperYard#foo"))
    meths.should_not include(P("SuperYard#foo2"))
    meths.should_not include(P("SuperYard::bar"))
  end
  
  it "should not show overridden methods" do 
    meths = P(:YARD).meths
    meths.should include(P("YARD#bar"))
    meths.should_not include(P("SuperYard#bar"))
    
    meths = P(:YARD).inherited_meths
    meths.should_not include(P("YARD#bar"))
    meths.should_not include(P("YARD#mymethod"))
    meths.should include(P("SuperYard#foo"))
    meths.should include(P("SuperYard#foo2"))
    meths.should include(P("SuperYard::bar"))
  end
  
  it "should not show inherited methods overridden by other subclasses" do
    meths = P(:YARD).inherited_meths
    meths.should include(P('MiddleYard#middle'))
    meths.should_not include(P('SuperYard#middle'))
  end
end

describe YARD::CodeObjects::ClassObject, "#constants / #inherited_constants" do
  before do 
    Registry.clear 
    
    Parser::SourceParser.parse_string <<-eof
      class YARD
        CONST1 = 1
        CONST2 = "hello"
        CONST4 = 0
      end
      
      class SUPERYARD < YARD
        CONST4 = 5
      end
      
      class SubYard < SUPERYARD
        CONST2 = "hi"
        CONST3 = "foo"
      end
    eof
  end
  
  it "should list inherited constants by default" do
    consts = P(:SubYard).constants
    consts.should include(P("YARD::CONST1"))
    consts.should include(P("SubYard::CONST3"))
    
    consts = P(:SubYard).inherited_constants
    consts.should include(P("YARD::CONST1"))
    consts.should_not include(P("YARD::CONST2"))
    consts.should_not include(P("SubYard::CONST2"))
    consts.should_not include(P("SubYard::CONST3"))
  end
  
  it "should not list inherited constants if turned off" do
    consts = P(:SubYard).constants(:inherited => false)
    consts.should_not include(P("YARD::CONST1"))
    consts.should include(P("SubYard::CONST3"))
  end
  
  it "should not include an inherited constant if it is overridden by the object" do
    consts = P(:SubYard).constants
    consts.should include(P("SubYard::CONST2"))
    consts.should_not include(P("YARD::CONST2"))
  end
  
  it "should not include an inherited constant if it is overridden by another subclass" do
    consts = P(:SubYard).inherited_constants
    consts.should include(P("SUPERYARD::CONST4"))
    consts.should_not include(P("YARD::CONST4"))
  end
  
  it "should not set a superclass on Object class" do
    o = ClassObject.new(:root, :Object)
    o.superclass.should be_nil
  end
  
  it "should raise ArgumentError if superclass == self" do
    lambda do
      o = ClassObject.new(:root, :Object) do |o|
        o.superclass = :Object
      end
    end.should raise_error(ArgumentError)
  end
  
  it "should tell the world if it is an exception class" do
    o = ClassObject.new(:root, :MyClass) 
    o2 = ClassObject.new(:root, :OtherClass)
    o2.superclass = :SystemCallError
    o3 = ClassObject.new(:root, :StandardError)
    o3.superclass = :Object
    o4 = ClassObject.new(:root, :Object)

    o.superclass = :Object
    o.is_exception?.should == false
    
    o.superclass = :Exception
    o.is_exception?.should == true
    
    o.superclass = :NoMethodError
    o.is_exception?.should == true
    
    o.superclass = o2
    o.is_exception?.should == true
    
    o.superclass = o3
    o.is_exception?.should == true
  end
  
  it "should not raise ArgumentError if superclass is proxy in different namespace" do
    lambda do
      o = ClassObject.new(:root, :X) do |o|
        o.superclass = P('OTHER::X')
      end
    end.should_not raise_error(ArgumentError)
  end
end
  
