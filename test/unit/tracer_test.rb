require "helper"

class TracerTest < Test::Unit::TestCase
  should "find version attribute in simple traceable object" do
    obj = TraceableObject.new
    assert_nil obj.version

    obj.attr1 = 'test'
    assert_equal 1, obj.version

    # don't increment version if attr is not traceable
    obj.attr3 = 'test'
    assert_equal 1, obj.version

    obj.attr2 = 'test'
    assert_equal 2, obj.version
  end

end


