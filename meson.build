# Name our project
project('thiefshot', ['vala', 'c'],
    version: '0.0.1'
)

# Application ID
thief_app_id = 'thiefshot'

# Import main lib files
gnome = import('gnome')
i18n = import('i18n')

# Set this for convenience
conf = configuration_data()

# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          thief_app_id ])

conf.set_quoted('PKGDATADIR', pkgdatadir)
# Generate config.h
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('RELEASE_NAME', thief_app_id)
conf.set_quoted('VERSION', meson.project_version())
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

cc = meson.get_compiler('c')

# Let's define our executable
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/Constants.vala',
    'src/Markdown.vala',
    c_args: c_args,
    dependencies: [
        dependency('gobject-2.0'),
        dependency('webkit2gtk-4.0'),
        dependency('gtksourceview-4'),
        dependency('gtk+-3.0'),
        dependency('clutter-1.0'),
        dependency('gee-0.8')
    ],
    vala_args: [
        meson.source_root() + '/vapi/config.vapi'
    ],
    install : true
)
