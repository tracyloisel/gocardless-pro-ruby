# encoding: utf-8

#
# This client is automatically generated from a template and JSON schema definition.
# See https://github.com/gocardless/gocardless-pro-ruby#contributing before editing.
#

require 'uri'

module GoCardlessPro
  # A module containing classes for each of the resources in the GC Api
  module Resources
    # Represents an instance of a institution resource returned from the API

    # Institutions that are supported when creating [Bank
    # Authorisations](#core-endpoints-bank-authorisations).
    class Institution
      attr_reader :icon_url
      attr_reader :id
      attr_reader :logo_url
      attr_reader :name

      # Initialize a institution resource instance
      # @param object [Hash] an object returned from the API
      def initialize(object, response = nil)
        @object = object

        @icon_url = object['icon_url']
        @id = object['id']
        @logo_url = object['logo_url']
        @name = object['name']
        @response = response
      end

      def api_response
        ApiResponse.new(@response)
      end

      # Provides the institution resource as a hash of all its readable attributes
      def to_h
        @object
      end
    end
  end
end
