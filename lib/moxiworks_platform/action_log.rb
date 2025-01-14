module  MoxiworksPlatform
  class ActionLog < MoxiworksPlatform::Resource
    # @!attribute agent_uuid
    #   agent_uuid is the Moxi Works Platform ID of the agent which an ActionLog entry is
    #   or is to be associated with. This will be an RFC 4122 compliant UUID.
    #
    #   this or moxi_works_agent_id must be set for any Moxi Works Platform transaction
    #
    #   @return [String] the Moxi Works Platform ID of the agent
    attr_accessor :agent_uuid

    # @!attribute moxi_works_agent_id
    #   moxi_works_agent_id is the Moxi Works Platform ID of the agent which an ActionLog entry is
    #   or is to be associated with.
    #
    #   this or agent_uuid must be set for any Moxi Works Platform transaction
    #
    #   @return [String] the Moxi Works Platform ID of the agent
    attr_accessor :moxi_works_agent_id

    # @!attribute moxi_works_contact_id
    #   This is the Moxi Works Platform ID of this Contact that this ActionLog entry is about.
    #   This will be an RFC 4122 compliant UUID
    #
    #   this or partner_contact_id must be set for any Moxi Works Platform transaction
    #
    #   @return [String] your system's unique ID for the contact
    attr_accessor :moxi_works_contact_id

    # @!attribute partner_contact_id
    #   *your system's* unique ID for the Contact
    #
    #   this or moxi_works_contact_id must be set for any Moxi Works Platform transaction
    #
    #   @return [String] your system's unique ID for the contact
    attr_accessor :partner_contact_id

    # @!attribute title
    #   the title to be displayed for this ActionLog Entry
    #
    #   @return [String]
    attr_accessor :title

    # @!attribute body
    #   the body of the log entry to be displayed for this ActionLog Entry
    #
    #   @return [String]
    attr_accessor :body

    # @!attribute actions
    #
    # @return [Array] array containing any ActionLog entries found by search request
    #  {
    #     moxi_works_action_log_id: [String] unique identifier for the Moxi Works Platform ActionLog entry,
    #     type: [String] the type of ActionLog entry this is. The string should be formatted in lowercase with an underscore between each word,
    #     timestamp: [Integer] Unix timestamp for the creation time of the ActionLog entry,
    #     log_data: [Dictionary] the payload data of the ActionLog entry. The structure returned is dependent on the kind of ActionLog entry this is
    #  }
    attr_accessor :actions

    # Creates a new ActionLog entry in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this ActionLog entry is to be associated
    # @option opts [String]  :partner_contact_id *REQUIRED* Your system's unique ID for the contact for whom the ActionLog entry is being created.
    # @option opts [String]  :title *REQUIRED*  A brief title for this ActionLog entry (85 characters or less)
    # @option opts [String]  :body *REQUIRED*  The body of this ActionLog entry (255 characters or less)
    #
    # @return [MoxiworksPlatform::ActionLog]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #   MoxiworksPlatform::ActionLog.create(
    #         moxi_works_agent_id: 'abc123',
    #         partner_contact_id: 'mySystemsUniqueContactID',
    #         title: 'New home keys were delivered to Firstname Lastname',
    #         body: 'Firstname Lastname were delivered their keys to1234 there ave',
    #     )
    #
    def self.create(opts={})
       self.send_request(:post, opts)
    end

    # Search an Agent's ActionLog entries in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID  for the agent to which this ActionLog is associated -- moxi_works_agent_id or agent_uuid must be passed
    # @option opts [String]  :agent_uuid *REQUIRED* The Agent UUID for the agent to which this ActionLog is associated -- moxi_works_agent_id or agent_uuid must be passed
    # @option opts [String]  :partner_contact_id *REQUIRED* Your system's unique ID for the contact for whom the ActionLog entry is being created. -- partner_contact_id or moxi_works_contact_id must be passed
    # @option opts [String]  :moxi_works_contact_id *REQUIRED* MoxiWorks'  unique ID for the contact for whom the ActionLog entry is being created. -- partner_contact_id or moxi_works_contact_id must be passed
    #
    # @return [Array] containing MoxiworksPlatform::ActionLog objects
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #     results = MoxiworksPlatform::ActionLog.search(
    #     moxi_works_agent_id: '123abc',
    #        )
    #
    def self.search(opts={})
      raise ::MoxiworksPlatform::Exception::ArgumentError,
            'arguments must be passed as named parameters' unless opts.is_a? Hash
      url ||= "#{MoxiworksPlatform::Config.url}/api/action_logs"
      required_opts = [:moxi_works_agent_id, :partner_contact_id]
      required_opts.each do |opt|
        raise ::MoxiworksPlatform::Exception::ArgumentError, "#{opt} required" if
            opts[opt].nil? or opts[opt].to_s.empty?
      end
      results = MoxiResponseArray.new()
      RestClient::Request.execute(method: :get,
                                  url: url,
                                  payload: opts, headers: self.headers) do |response|
        puts response if MoxiworksPlatform::Config.debug
        results.headers = response.headers
        self.check_for_error_in_response(response)
        json = JSON.parse(response)

        results.page_number = 1
        results.total_pages = 1

        json['actions'].each do |r|
          results << MoxiworksPlatform::ActionLog.new(r) unless r.nil? or r.empty?
        end
      end
      results
    end

    # Send our remote request to the Moxi Works Platform
    #
    # @param [String] method The HTTP method to be used when connecting; ex: :put, :post, :get
    # @param [Hash] opts
    # @option opts [String]  :moxi_works_agent_id  *REQUIRED* -- either :moxi_works_agent_id or :agent_uuid is required -- The Moxi Works Agent ID for the agent
    # @option opts [String]  :agent_uuid *REQUIRED* -- either :moxi_works_agent_id or :agent_uuid is required -- The Moxi Works Agent ID for the agent
    # @option opts [String]  :partner_contact_id *REQUIRED* Your system's unique ID for the contact for whom the ActionLog entry is being created.
    # @option opts [String]  :title *REQUIRED*  A brief title for this ActionLog entry (85 characters or less)
    # @option opts [String]  :body *REQUIRED*  The body of this ActionLog entry (255 characters or less)
    #
    #
    # @return [MoxiworksPlatform::ActionLog]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    def self.send_request(method, opts={}, url=nil)
      raise ::MoxiworksPlatform::Exception::ArgumentError,
            'arguments must be passed as named parameters' unless opts.is_a? Hash
      url ||= "#{MoxiworksPlatform::Config.url}/api/action_logs"
      agent_identifier = opts[:moxi_works_agent_id] || opts[:agent_uuid]
      raise ::MoxiworksPlatform::Exception::ArgumentError, "#agent_uuid or moxi_works_agent_id required" if
        agent_identifier.blank?
      required_opts = [:partner_contact_id, :title, :body]
      required_opts.each do |opt|
        raise ::MoxiworksPlatform::Exception::ArgumentError, "#{opt} required" if
            opts[opt].nil? or opts[opt].to_s.empty?
      end
      super(method, opts, url)
    end
  end
end
