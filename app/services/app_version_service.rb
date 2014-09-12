class AppVersionService
  def get_version_number
    AppVersion.first.version_number
  end
end
