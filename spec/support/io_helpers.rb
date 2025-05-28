module IOHelpers
  def write_team_yml(extra_data: false)
    write_file('config/teams/my_team.yml', <<~YML.strip)
      name: My Team
      extra_data: #{extra_data}
    YML
  end

  def write_file(path, content = '')
    pathname = Pathname.new(path)
    FileUtils.mkdir_p(pathname.dirname)
    pathname.write(content)
  end
end

RSpec.configure do |config|
  config.include IOHelpers
end
