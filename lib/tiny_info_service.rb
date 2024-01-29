require 'time'
require 'tiny_tcp_service'

# usage:
#  s = TinyInfoService.new(
#    1234,
#    'TinyInfoService',
#    2,
#    {
#      'uptime': {
#        'kind': 'shell_cmd',
#        'shell_cmd': 'uptime'
#      }
#    }
#  )
#  s.stop!
class TinyInfoService
  TIME_MULTIPLIERS = {
    's' => 1,
    'm' => 60,
    'h' => 60 * 60,
    'd' => 60 * 60 * 24
  }

  def initialize(port, label, refresh_interval_in_seconds, config)
    @service = TinyTCPService.new(port)
    @service.msg_handler = self
    @label = label
    @msg_counter = 0
    @err_counter = 0
    @label = label
    @label_and_port = "#{@label}:#{port}"
    @config = config
    @config.each do |key, details|
      @config[key]['cache'] = _parse_cache(details['cache']) if details['cache']
    end

    @cache = {}
    @cache_hits = 0

    # status printing thread
    Thread.new do
      start_time = Time.now
      print "\e[?25l" # hide cursor
      loop do
        break unless @service.running?
        sec_runtime = Time.now - start_time
        human_runtime = "%02d:%02d:%02d" % [sec_runtime / 3600, sec_runtime / 60 % 60, sec_runtime % 60]

        print "\e[1;1H"
        puts "label/port: #{@label_and_port.rjust(28)}\e[K"
        puts "time      : #{DateTime.now.iso8601.rjust(28)}\e[K"
        puts "runtime   : #{human_runtime.rjust(28)}\e[K"
        puts "clients   : #{@service.num_clients.to_s.rjust(28)}\e[K"
        puts "msgs      : #{@msg_counter.to_s.rjust(28)}\e[K"
        puts "errs      : #{@err_counter.to_s.rjust(28)}\e[K"

        sleep refresh_interval_in_seconds
      end
      print "\e[?25h" # show cursor
    end
  end

  # interface for TinyTCPService
  def call(m)
    raise TinyTCPService::BadClient.new("nil message") if m.nil?

    case
    when m[0] == '?'
      # return list of keys
      req = m[1..]

      if @config.keys.include?(req)
        @msg_counter += 1
        case @config[req]['kind']
        when 'shell_cmd'
          cached_value = @cache[req]['value'] if  @config[req]['cache'] &&
                                                  @cache.dig(req, 'value') &&
                                                  Time.now - @cache[req]['time'] < @config[req]['cache']

          if cached_value
            @cache_hits += 1
            return cached_value
          end

          result = `#{@config[req]['shell_cmd']}`

          if $?.exitstatus == 0
            t = @config[req]['transform']
            final = t ? eval("result#{t}") : result

            @cache[req] = {
              'value' => final,
              'time' => Time.now
            }

            final
          else
            _error!
          end
        else
          _error!
        end
      else
        _error!
      end
    else
      _error!
    end
  end

  def join
    @service.join
  end

  def _parse_cache(cache_value)
    cache_value[..-2].to_f * TIME_MULTIPLIERS[cache_value[-1]]
  end

  def _error!
    @err_counter += 1
    'err'
  end
end
