# frozen_string_literal: true
class ListingPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    return @user
  end

  def create?
    return @user
  end

  def new?
    create?
  end

  def update?
    return @user && @user.has_role?(:seller)
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def buy?
    return @user
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
