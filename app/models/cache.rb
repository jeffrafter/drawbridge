class Cache < ActiveRecord::Base
  named_scope :active, lambda { { :conditions => ['created_at > ?', 1.week.ago], :order => 'updated_at DESC' } }    
  
  def self.user(number)
    rec = self.active.first(:conditions => ['number = ? AND name = ?', number, :user])    
    rec ? User.from_xml(Hash.from_xml(rec.data).values.first) : nil
  end
  
  def self.store(name, number, obj)
    rec = self.active.first(:conditions => ['number = ? AND name = ?', number, name])    
    rec ||= Cache.new(:number => number, :name => name)
    rec.data = obj.to_xml
    rec.save!
  end  
end