class PaymentsApiEnvironment < Environment

  def read
    super
    ensure_expected_collections
  end

  def ensure_expected_collections()
    @basis[:tenants] ||= {}
    @basis[:tenants].each do |name,tenant_config|
      tenant_config[:connections] ||= {}
      tenant_config[:settings] ||= {}
    end
  end
end
