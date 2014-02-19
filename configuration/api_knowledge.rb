module ApiKnowledge
  include FromEnvironment

  def api_url(api, tenant='uk')
    case
      when production? then for_production(api, tenant)
      when dev? then for_dev(api, tenant)
      else for_non_production(api, tenant)
    end
  end

  private

  def for_dev(api, tenant)
    "http://#{api}"
  end

  def for_production(api, tenant)
    return "http://justpay.#{production_tlz(tenant.to_sym)}/api" if api == 'justpay'
    return "http://#{tenant}-#{api}.#{production_tlz(tenant.to_sym)}"
  end

  def for_non_production(api, tenant)
    qa_domain = from_environment 'domain'
    return "http://justpay-#{name}.#{qa_domain}/api" if api == 'justpay'
    return "http://#{tenant}-#{api}-#{name}.#{qa_domain}"
  end

  def production_tlz(tenant)
    return "just-eat.co.uk" if tenant == :uk
    return "justeat.nl" if tenant == :nl
    "just-eat.#{tenant}"
  end
end
