require File.join(File.dirname(__FILE__), '..', 'test_helper')

class CachesTest < Test::Unit::TestCase
  context "Empty cache" do
    setup do      
      Cache.all.map(&:destroy)
      @cache = nil
    end
  
    should "not find a user in the cache" do
      assert_nil Cache.user('+123456789')    
    end
    
    should "store a new user in the cache" do
      Cache.store(:user, '+123456789', {:name => 'Cookie Monster'})
      assert_not_nil Cache.user('+123456789')    
    end
  end  
  
  context "Cache with existing user" do
    setup do      
      Cache.all.map(&:destroy)
      @cache = Factory(:cache)
    end
  
    should "find a user in the cache" do
      assert_not_nil Cache.user('+123456789')    
    end
    
    should "update a stored user in the cache" do
      @user = Cache.user('+123456789')    
      Cache.store(:user, '+123456789', @user.attributes)
      assert_equal 1, Cache.count
    end
  end  

  context "Cache with expired user" do
    setup do      
      Cache.all.map(&:destroy)
      Cache.record_timestamps = false
      @cache = Factory(:cache, :updated_at => 16.minutes.ago)
      Cache.record_timestamps = true
    end
  
    should "not find a user in the cache" do
      assert_nil Cache.user('+123456789')    
    end
    
    should "store a new user in the cache" do
      Cache.store(:user, '+123456789', {:muppets => 'Take Manhattan'})
      assert_equal 2, Cache.count
    end
  end  

end    
