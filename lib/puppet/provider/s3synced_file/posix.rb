require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'aws-sdk-core' if Puppet.features.aws?

Puppet::Type.type(:s3synced_file).provide(:posix) do
  confine :feature => :aws
  confine :feature => :posix
  include Puppet::Util::POSIX
  include Puppet::Util::Warnings
  require 'etc'
  
  def create
    begin
      s3 = Aws::S3::Client.new(
        access_key_id: @resource[:access_key_id],
        secret_access_key: @resource[:secret_access_key],
        region: @resource[:region]
      )
    
      s3.get_object(
        bucket: @resource[:bucket],
        key:@resource[:key],
        response_target: @resource[:name]
      )
      
      # Make sure the mode is correct
      if @resource[:mode] != nil
        should_mode = @resource.should(:mode)
        unless self.mode == should_mode
            self.mode = should_mode
        end      
      end
      if @resource[:owner] != nil
        should_owner = name2uid(@resource.should(:owner))
        unless self.owner == should_owner
            self.owner = should_owner
        end      
      end
      if @resource[:group] != nil
        should_group = name2gid(@resource.should(:group))
        unless self.group == should_group
            self.group = should_group
        end      
      end
      
    rescue Aws::S3::Errors::ServiceError
      self.fail "Could not download s3 file: #{context}"
    end
  end
  
  def destroy
      File.unlink(@resource[:name])
  end

  def exists?
    if "#{@resource[:ensure]}" == 'present'
      false
    else
      File.exists?(@resource[:name])
    end
  end  
  
  
  #copyed from file resource type from puppet main types
  def mode
    if stat = resource.stat
      return (stat.mode & 007777).to_s(8)
    else
      return :absent
    end
  end

  def mode=(value)
    begin
      File.chmod(value.to_i(8), resource[:name])
    rescue => detail
      error = Puppet::Error.new("failed to set mode #{mode} on #{resource[:name]}: #{detail.message}")
      error.set_backtrace detail.backtrace
      raise error
    end
  end
  
    
  # Determine if the user is valid, and if so, return the UID
  def name2uid(value)
    Integer(value) rescue uid(value) || false
  end

  def name2gid(value)
    Integer(value) rescue gid(value) || false
  end

  def owner
    unless stat = resource.stat
      return :absent
    end
    currentvalue = stat.uid
    # On OS X, files that are owned by -2 get returned as really
    # large UIDs instead of negative ones.  This isn't a Ruby bug,
    # it's an OS X bug, since it shows up in perl, too.
    if currentvalue > Puppet[:maximum_uid].to_i
      self.warning "Apparently using negative UID (#{currentvalue}) on a platform that does not consistently handle them"
      currentvalue = :silly
    end
    currentvalue
  end

  def owner=(should)
    method = :chown
    begin
      File.send(method, should, nil, resource[:name])
    rescue => detail
      raise Puppet::Error, "Failed to set owner to '#{should}': #{detail}"
    end
  end

  def group
    return :absent unless stat = resource.stat
    currentvalue = stat.gid

    # On OS X, files that are owned by -2 get returned as really
    # large GIDs instead of negative ones.  This isn't a Ruby bug,
    # it's an OS X bug, since it shows up in perl, too.
    if currentvalue > Puppet[:maximum_uid].to_i
      self.warning "Apparently using negative GID (#{currentvalue}) on a platform that does not consistently handle them"
      currentvalue = :silly
    end
    currentvalue
  end

  def group=(should)
    method = :chown
    begin
      File.send(method, nil, should, resource[:name])
    rescue => detail
      raise Puppet::Error, "Failed to set group to '#{should}': #{detail}"
    end
  end
        
  
end

