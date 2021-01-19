plan choria::provision(
  TargetSpec $targets,
  String[1] $srvdomain,
  Boolean $client = false,
  Boolean $server = false,
  Array[String[1]] $agents = ['bolt_tasks', 'filemgr', 'nettest', 'package', 'puppet', 'service'],
) {
  run_plan('facts', 'targets' => $targets)

  get_targets($targets).each |$target| {
    $manage_package_repo = $target.facts['os']['family'] ? {
      'Debian' => true,
      'RedHat' => true,
      default  => false,
    }

    apply($target) {
      warning($target)
      file { '/tmp/plop':
        ensure => file,
      }

      class { 'choria':
        manage_package_repo => $manage_package_repo,
        server              => $server,
        srvdomain           => $srvdomain,
        manage_mcollective  => false,
      }

      class { 'mcollective':
        client         => $client,
        plugin_classes => [
          'mcollective_choria',
          'mcollective_util_actionpolicy',
          ] + $agents.map |$agent| { "mcollective_agent_${agent}" },
      }
    }
  }
}
