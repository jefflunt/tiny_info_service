see `lib/tiny_work_service.rb`

# Documentation for TinyInfoService

## Overview
TinyInfoService is a lightweight Ruby service that provides system information over a TCP connection. It uses a given configuration to execute shell commands and return their output to connected clients. This service can be customized for various system metrics like uptime, disk space, and load averages.

## Dependencies
- Ruby environment
- A TCP service library (`TinyTCPService`)

## Configuration File
The configuration file is in YAML format. The main elements are:

- **label**: A string representing the service's label.
- **port**: The TCP port number on which the service listens.
- **refresh_interval_in_seconds**: How often the status thread updates, in seconds.
- **infos**: A dictionary of information keys, each containing:
  - **kind**: Type of the information source (e.g., `shell_cmd`).
  - **shell_cmd**: The shell command to be executed.
  - **transform** (optional): Ruby code as a string to transform the command output.
  - **cache** (optional): Duration to cache the output, specified in seconds (`s`), minutes (`m`), hours (`h`), or days (`d`).

## Usage
1. **Initialization**:
   To initialize the service, create an instance of `TinyInfoService` with the following parameters:
   - `port`: Port number for the TCP server.
   - `label`: A descriptive label for the service.
   - `refresh_interval_in_seconds`: Interval for refreshing the status.
   - `config`: A hash containing configuration details.

   Example:
   ```ruby
   s = TinyInfoService.new(
     1234,
     'TinyInfoService',
     2,
     # ... configuration hash ...
   )
   ```

2. **Stopping the Service**:
   To stop the service, you can use the `stop!` method of the underlying `TinyTCPService` instance:
   ```ruby
   s.stop!
   ```

## Configuration Options
- **Shell Command Execution**:
  The service can execute any shell command provided in the configuration. This is specified with the `shell_cmd` key.

- **Transforming Output**:
  If you need to process the output of a shell command before sending it to the client, use the `transform` option. This should be a valid Ruby expression that operates on the `result` variable.

- **Caching**:
  Responses can be cached for a specified duration to reduce load. Use the `cache` option in the format `[value][unit]` where `unit` is one of `s` (seconds), `m` (minutes), `h` (hours), or `d` (days).

## Example Configuration
```yaml
label: 'TinyWorkService'
port: 1234
refresh_interval_in_seconds: 2.0
infos:
  localhost.uptime:
    kind: shell_cmd
    shell_cmd: "uptime"
    transform: ".split('up').last.split('users').first.split(',').first(2).join.strip"
    cache: 1.5m
  # ... other configurations ...
```

In this example, the service will run on port 1234, updating its status every 2 seconds. It can provide information like `localhost.uptime`, which runs the `uptime` command, transforms the output, and caches it for 1.5 minutes.

## Notes
- Ensure that any shell commands used do not pose a security risk.
- The service does not handle concurrent TCP connections; design your client accordingly.
- Transformations should be carefully written to avoid errors in execution.
