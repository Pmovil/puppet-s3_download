Puppet::Type.newtype(:s3synced_file) do
  @doc = "Download a file from s3"

  ensurable
  
  newparam(:name, :namevar => true) do
    desc "Filename"
    validate do |value|
      fail 'Missing file name' unless value.is_a?(String)
    end    
  end
  
  newparam(:access_key_id) do
    desc "AWS Access Key Identifier"
    validate do |value|
      fail 'Missing AWS Access Key Identifier' unless value.is_a?(String)
    end    
  end
  newparam(:secret_access_key) do
    desc "AWS Access Key Password"
    validate do |value|
      fail 'Missing AWS Access Key Password' unless value.is_a?(String)
    end    
  end
  newparam(:region) do
    desc "S3 Region"
    validate do |value|
      fail 'Missing S3 Region' unless value.is_a?(String)
    end    
  end
  newparam(:bucket) do
    desc "S3 Bucket"
    validate do |value|
      fail 'Missing S3 Bucket' unless value.is_a?(String)
    end    
  end
  newparam(:key) do
    desc "S3 object key"
    validate do |value|
      fail 'Missing S3 object key' unless value.is_a?(String)
    end    
  end
  
  newproperty(:mode) do
      desc "Manage the file's mode."
  end  

  newproperty(:owner) do
      desc "Manage the file's owner."
  end  

  newproperty(:group) do
      desc "Manage the file's group."
  end  
  
  @stat = :needs_stat
  
  validate do
    fail("access_key_id is mandatory.") if self[:access_key_id].nil?
    fail("secret_access_key is mandatory.") if self[:secret_access_key].nil?
    fail("region is mandatory.") if self[:region].nil?
    fail("bucket is mandatory.") if self[:bucket].nil?
    fail("key is mandatory.") if self[:key].nil?
  end  
  
  def stat
    return @stat unless @stat == :needs_stat

    method = :stat
    
    @stat = begin
      ::File.send(method, self[:name])
    rescue Errno::ENOENT => error
      nil
    rescue Errno::EACCES => error
      warning "Could not stat; permission denied"
      nil
    end
  end
  
end
