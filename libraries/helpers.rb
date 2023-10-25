module Gpg
  module Helpers
    include Chef::Mixin::ShellOut

    def key_exists(new_resource, key = nil)
      gpg_check = gpg_cmd
      gpg_check << override_command(new_resource) if new_resource.override_default_keyring

      gpg_check << if new_resource.keyserver
                     "--list-keys #{key}"
                   else
                     "--list-keys | grep #{new_resource.name_real}"
                   end

      cmd = Mixlib::ShellOut.new(
        gpg_check,
        user: new_resource.user,
        group: new_resource.group
      )

      cmd.run_command
      cmd.exitstatus == 0
    end

    def override_command(new_resource)
      "--no-default-keyring --secret-keyring #{new_resource.secring_file} --keyring #{new_resource.pubring_file}"
    end

    # Ensure GPG uses the correct home directory for the current resource
    def gpg_cmd
      "gpg2 --homedir #{new_resource.home_dir} "
    end

    def gpg2_packages
      platform_family?('suse') ? %w(haveged gpg2) : %w(haveged gnupg2)
    end
  end
end
