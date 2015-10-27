define cobbler::module (
  $engine = undef,
  $type = 'manage',
  $use_template = false,
  $template =  "${engine}.template",
  $order  = 99,
) {
  validate_string($engine) 
  validate_bool($use_template)
  

  # Add definition to modules.conf
  concat::fragment {"${cobbler::config_modules}_$name":
    target  => $cobbler::config_modules,
    content => inline_template("[<%= @name -%>]
module = <%= @type -%>_<%= @engine %>
"),
  }

  if ($use_template) {
    # Configuration template
    file { "${cobbler::config_path}/${template}":
      ensure  => $cobbler::ensure,
      content => template("${module_name}/${template}.erb"),
    }
  }


  
}
