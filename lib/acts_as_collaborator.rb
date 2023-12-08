# frozen_string_literal: true

require_relative "acts_as_collaborator/version"
require 'active_record'

module ActsAsCollaborator
  def acts_as_collaborator(options = {})
    class_attribute :collaborator_configuration

    collaborator_configuration = {
      column: 'collaborator_ids',
      column_type: 'array',
      table_name: self.table_name
    }

    collaborator_configuration.merge!(options) 


    unless %w[array string].include? collaborator_configuration[:column_type]
      raise ArgumentError, "'array' or 'string' expected" \
        " for :column_type option, got #{collaborator_configuration[:column_type]}"
    end

    default_scope lambda {
      if ActsAsTenant.current_tenant && ::Network::UserAccount.current
        where("#{::Network::UserAccount.current.user_contact.id} = ANY(#{collaborator_configuration[:table_name]}.#{collaborator_configuration[:column]})")
      end
    }
  end
end
