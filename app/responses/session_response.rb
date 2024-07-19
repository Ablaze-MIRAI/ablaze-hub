# frozen_string_literal: true

class AuthenticationMethod
  attr_reader :method, :completed_at, :aal, :organization, :provider

  def initialize(method)
    @method = method["method"]
    @completed_at = method["completed_at"]
    @aal = method["aal"]
    @organization = method["organization"]
    @provider = method["provider"]
  end
end

class Device
  attr_reader :id, :ip_address, :location, :user_agent

  def initialize(device)
    @id = device["id"]
    @ip_address = device["ip_address"]
    @location = device["location"]
    @user_agent = device["user_agent"]
  end
end

class VerifiableAddress
  attr_reader :id, :value, :verified, :verified_at, :via, :status, :created_at, :updated_at

  def initialize(address)
    @id = address["id"]
    @value = address["value"]
    @verified = address["verified"]
    @verified_at = address["verified_at"]
    @via = address["via"]
    @status = address["status"]
    @created_at = address["created_at"]
    @updated_at = address["updated_at"]
  end
end

class SessionResponse
  attr_reader :id, :active, :authenticated_at, :expires_at, :aal, :issued_at, :tokenized, :authentication_methods, :devices, :verifiable_addresses, :identity, :raw

  def initialize(session)
    @raw = session
    @id = session["id"]
    @active = session["active"]
    @authenticated_at = session["authenticated_at"]
    @expires_at = session["expires_at"]
    @aal = session["authenticator_assurance_level"]
    @issued_at = session["issued_at"]
    @tokenized = session["tokenized"]
    @identity = session["identity"]

    @authentication_methods = session["authentication_methods"].map do |method|
      AuthenticationMethod.new(method)
    end
    @devices = session["devices"].map do |device|
      Device.new(device)
    end
    @verifiable_addresses = []
    if session["verifiable_addresses"]
      @verifiable_addresses = session["verifiable_addresses"].map do |address|
        VerifiableAddress.new(address)
      end
    end
  end

  def verified?
    @verifiable_addresses.any? { |address| address.verified }
  end
end
