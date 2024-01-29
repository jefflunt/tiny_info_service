Gem::Specification.new do |s|
  s.name        = "tiny_info_service"
  s.version     = "1.0.0"
  s.description = "uses the tiny_tcp_service gem to implement a system information service"
  s.summary     = "uses the tiny_tcp_service gem to implement a system information service"
  s.authors     = ["Jeff Lunt"]
  s.email       = "jefflunt@gmail.com"
  s.files       = ["lib/tiny_info_service.rb"]
  s.homepage    = "https://github.com/jefflunt/tiny_info_serivce"
  s.license     = "MIT"
  s.add_runtime_dependency "tiny_tcp_service", [">= 0"]
end
