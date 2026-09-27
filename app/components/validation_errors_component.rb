# frozen_string_literal: true

class ValidationErrorsComponent < ViewComponent::Base
  def initialize(resource:)
    @resource = resource
  end

  def errors?
    @resource.errors.any?
  end
end
