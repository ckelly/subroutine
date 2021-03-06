require "subroutine/auth"
require "subroutine/association"

## Models ##

class User
  include ::ActiveModel::Model

  attr_accessor :id
  attr_accessor :email_address
  attr_accessor :password

  validates :email_address, :presence => true
end

class AdminUser < ::User
  validates :email_address, :format => {:with => /@admin\.com/, :message => 'has gotta be @admin.com'}
end


## Ops ##

class SignupOp < ::Subroutine::Op

  string :email, :aka => :email_address
  string :password

  validates :email, :presence => true
  validates :password, :presence => true

  attr_reader :perform_called
  attr_reader :perform_finished

  attr_reader :created_user

  protected

  def perform
    @perform_called = true
    u = build_user

    unless u.valid?
      inherit_errors(u)
      return false
    end

    @perform_finished = true
    @created_user = u

    true
  end

  def build_user
    u = user_class.new
    u.email_address = email
    u.password = password
    u
  end

  def user_class
    ::User
  end
end
class WhateverSignupOp < ::SignupOp
  string :whatever, ignore_errors: true
  validates :whatever, presence: true
end

class AdminSignupOp < ::SignupOp

  field :priveleges, :default => 'min'

  protected

  def user_class
    ::AdminUser
  end

end

class BusinessSignupOp < ::Subroutine::Op

  string :business_name

  inputs_from ::SignupOp
end

class DefaultsOp < ::Subroutine::Op

  field :foo, :default => 'foo'
  field :bar, :default => 'bar'

end

class InheritedDefaultsOp < ::DefaultsOp

  field :bar, :default => 'barstool'

end

class TypeCastOp < ::Subroutine::Op

  integer :integer_input
  number :number_input
  decimal :decimal_input
  string :string_input
  boolean :boolean_input
  date :date_input
  time :time_input, :default => lambda{ Time.now }
  iso_date :iso_date_input
  iso_time :iso_time_input
  object :object_input
  array :array_input, :default => 'foo'

end

class OpWithAuth < ::Subroutine::Op
  include ::Subroutine::Auth
  def perform
    true
  end
end

class MissingAuthOp < OpWithAuth
end

class RequireUserOp < OpWithAuth
  require_user!
end

class RequireNoUserOp < OpWithAuth
  require_no_user!
end

class NoUserRequirementsOp < OpWithAuth
  no_user_requirements!
end

class CustomAuthorizeOp < OpWithAuth

  require_user!
  authorize :authorize_user_is_correct

  protected

  def authorize_user_is_correct
    unless current_user.email_address.to_s =~ /example\.com$/
      unauthorized!
    end
  end
end

class PolicyOp < OpWithAuth

  class FakePolicy
    def user_can_access?
      false
    end
  end

  require_user!
  policy :user_can_access?

  def policy
    @policy ||= FakePolicy.new
  end
end


class OpWithAssociation < ::Subroutine::Op
  include ::Subroutine::Association
end

class SimpleAssociationOp < ::OpWithAssociation

  association :user

end

class UnscopedSimpleAssociationOp < ::OpWithAssociation
  association :user, unscoped: true
end

class PolymorphicAssociationOp < ::OpWithAssociation
  association :admin, polymorphic: true
end

class AssociationWithClassOp < ::OpWithAssociation
  association :admin, class_name: "AdminUser"
end
