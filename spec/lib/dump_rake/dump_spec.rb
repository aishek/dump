require File.dirname(__FILE__) + '/../../spec_helper'

Dump = DumpRake::Dump
describe Dump do
  describe "versions" do
    def stub_glob
      Dir.stub!(:[]).and_return(%w(123 345 567).map{ |name| File.join(RAILS_ROOT, 'dump', "#{name}.tgz")})
    end

    describe "list" do
      it "should search for files in dump dir when asked for list" do
        Dir.should_receive(:[]).with(File.join(RAILS_ROOT, 'dump', '*.tgz')).and_return([])
        Dump.list
      end

      it "should return selves instances for each found file" do
        stub_glob
        Dump.list.all?{ |dump| dump.should be_a(Dump) }
      end

      it "should return dumps with name containting :like" do
        stub_glob
        Dump.list(:like => '3').should == [Dump.list[0], Dump.list[1]]
      end
    end
  end

  describe "name" do
    it "should return file name" do
      Dump.new(File.join(RAILS_ROOT, 'dump', "123.tgz")).name.should == '123.tgz'
    end
  end

  describe "verify_connection" do
    it "should return result of ActiveRecord::Base.connection.verify!" do
      ActiveRecord::Base.connection.should_receive(:verify!).and_return(:result)
      Dump.new('').send(:verify_connection).should == :result
    end
  end

  describe "quote_table_name" do
    it "should return result of ActiveRecord::Base.connection.quote_table_name" do
      ActiveRecord::Base.connection.should_receive(:quote_table_name).with('first').and_return('`first`')
      Dump.new('').send(:quote_table_name, 'first').should == '`first`'
    end
  end

  describe "with_env" do
    it "should set env to new_value for duration of block" do
      ENV['TESTING'] = 'old_value'
      
      ENV['TESTING'].should == 'old_value'
      Dump.new('').send(:with_env, 'TESTING', 'new_value') do
        ENV['TESTING'].should == 'new_value'
      end
      ENV['TESTING'].should == 'old_value'
    end
  end
end
