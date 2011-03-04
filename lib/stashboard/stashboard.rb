require 'rubygems'
require 'oauth'
require 'yajl/json_gem'

module Stashboard
  # Main class for interacting with Stashboard.
  class Stashboard
    
    # Create a new Stashboard instance.
    #
    # @param [String] the url of your stashboard instance (this should use https)
    # @param [String] the oauth_token generated by your Stashboard instance (this is the long one)
    # @param [String] the oauth_secret generated by your Stashboard instance (this is the shorter one)
    def initialize(base_url, oauth_token, oauth_secret)
      @consumer = OAuth::Consumer.new("anonymous", "anonymous", { :site => base_url })
      @client = OAuth::AccessToken.new(@consumer, oauth_token, oauth_secret)
    end
  
    # Gets a list of all services currently managed by the Stashboard instance
    # 
    # @return [Array] an array of service detail hashes
    def services
      response = @client.get("/api/v1/services")
      return JSON.parse(response.body)
    end
  
    # Get the details of an individual service managed by the Stashboard instance.
    #
    # @param [String] the unique id of the service (generated by Stashboard)
    # @return [Hash] hash containing the service details
    def service(service_id)
      response = @client.get("/api/v1/services/#{service_id}")
      return JSON.parse(response.body)
    end
  
    # Create a new service.
    #
    # @param [String] the name of the service
    # @param [String] the description of the service
    # @return [Hash] response containing the complete service details generated by Stashboard
    def create_service(name, description)
      response = @client.post("/api/v1/services", { "name" => name, "description" => description })
      return JSON.parse(response.body)
    end
  
    # Delete a service. This will delete all alerts for this service, so be careful.
    #
    # @param [String] the service id to delete
    # @return [Hash] details of the service we've just deleted
    def delete_service(service_id)
      response = @client.delete("/api/v1/services/#{service_id}")
      return JSON.parse(response.body)
    end
  
    # Updates details of an existing service with a new name or description.
    # You can't change the service_id however.
    #
    # @param [String] the id of the service to update
    # @param [String] the new name
    # @param [String] the new description
    # @return [Hash] the updated service details
    def update_service(service_id, name, description)
      response = @client.post("/api/v1/services/#{service_id}", { "name" => name, "description" => description })
      return JSON.parse(response.body)
    end
  
    # Returns the different levels that new statuses can use.
    # 
    # @return [Array] an array of the level strings
    def levels
      response = @client.get("/api/v1/levels")
      return JSON.parse(response.body)["levels"]
    end
  
    # Get events for the specified service.
    #
    # @param [String] the service id we wer interested in
    # @param [Hash] optional hash that restricts the returned events. Only keys that do anything are "start" and "end" which can be used to constrain the time period from which events will be returned.
    # @return [Array] an array of event hashes describing events for the service
    def events(service_id, options = {})
      response = @client.get("/api/v1/services/#{service_id}/events", options)
      return JSON.parse(response.body)
    end
  
    # Create an event of a service. Events are the main way we
    # indicate problems or resolutions of issues.
    #
    # @param [String] the id of the service
    # @param [String] the id of an already existing status (i.e. "up", "down", "warning")
    # @param [String] a descriptive message
    # @return [Hash] the event details
    def create_event(service_id, status_id, message)
      response = @client.post("/api/v1/services/#{service_id}/events", { "status" => status_id, "message" => message })
      return JSON.parse(response.body)
    end
  
    # Get the current event for the specified service.
    #
    # @param [String] the id of the service
    # @return [Hash] hash containing the current event details
    def current_event(service_id)
      response = @client.get("/api/v1/services/#{service_id}/events/current")
      return JSON.parse(response.body)
    end
  
    # Get details of an individual event
    #
    # @param [String] the id of the service
    # @param [String] the sid of the event. This is a unique key returned in the response when an event is created
    # @return [Hash] hash containing the current event details
    def event(service_id, event_sid)
      response = @client.get("/api/v1/services/#{service_id}/events/#{event_sid}")
      return JSON.parse(response.body)
    end
  
    # Delete an event.
    #
    # (see #event)
    def delete_event(service_id, event_sid)
      response = @client.delete("/api/v1/services/#{service_id}/events/#{event_sid}")
      return JSON.parse(response.body)
    end
  
    # Get all statuses.
    #
    # @return [Array] an array of status hashes, each hash is an individual status
    def statuses
      response = @client.get("/api/v1/statuses")
      return JSON.parse(response.body)
    end
  
    # Get the details of the individual status.
    #
    # @param [String] the id of the status
    # @returns [Hash] hash containing the status details
    def status(status_id)
      response = @client.get("/api/v1/statuses/#{status_id}")
      return JSON.parse(response.body)
    end
  
    # Create a new status. Statuses exist independently of any Service, and are
    # required before creating any events that use this status
    #
    # @param [String] the name of this status
    # @param [String] description of the status
    # @level [String] level string. Must be one of the levels returned from #levels
    # @image [String] name of an image to use for this status. The complete list of images can be retrieved using #status_images, and this value should just be the image name without the directory name or the file extension.
    # @return [Hash] hash containing the created statuses details
    def create_status(name, description, level, image)
      response = @client.post("/api/v1/statuses", { "name" => name, "description" => description, "level" => level, "image" => image })
      return JSON.parse(response.body)
    end
  
    # Return a list of all the status images that the Stashboard server knows about.
    #
    # @return [Array] array of image hashes
    def status_images
      response = @client.get("/api/v1/status-images")
      return JSON.parse(response.body)["images"]
    end
  end
end