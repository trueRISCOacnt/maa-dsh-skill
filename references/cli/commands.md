# maa-cli 全部命令参考（由 maa <cmd> --help 自动收集，maa-cli v0.7.5）

> 生成方式：maa mangen（man 手册见 man/ 目录）+ 各子命令 --help 输出。命令参数若与文档冲突，以本文件为准。

## maa（根命令）
```
A tool for Arknights.

Usage: maa.exe [OPTIONS] <COMMAND>

Commands:
  install         Install maa maa_core and resources
  update          Update maa maa_core and resources
  self            Manage maa-cli self
  hot-update      Hot update for resource
  dir             Print path of maa directories
  version         Print version of given component
  run             Run a custom task
  startup         Startup Game and Enter Main Screen
  closedown       Close game client
  fight           Run fight task
  copilot         Run copilot task
  ssscopilot      Run SSSCopilot task
  paradoxcopilot  Run Paradox Simulation copilot task
  roguelike       Run rouge-like task
  reclamation     Run Reclamation Algorithm task
  convert         Convert file format between TOML, YAML and JSON
  activity        Show stage activity of given client
  remainder       Get the remainder of given divisor and current date
  cleanup         Clearing the caches of maa-cli and maa core
  list            List all available tasks
  import          Import configuration files from a local path or a remote URL
  init            Initialize configurations for maa-cli
  complete        Generate completion script for given shell
  mangen          Generate man page
  help            Print this message or the help of the given subcommand(s)

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```

## maa activity
```
Show stage activity of given client

Usage: maa.exe activity [OPTIONS] [CLIENT]

Arguments:
  [CLIENT]
          [default: Official]
          [possible values: Official, Bilibili, Txwy, YoStarEN, YoStarJP, YoStarKR]

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa cleanup
```
Clearing the caches of maa-cli and maa core

Usage: maa.exe cleanup [OPTIONS] [TARGETS]...

Arguments:
  [TARGETS]...
          Specify the path for deletion

          Possible values:
          - cli-cache:  Cache files for maa-cli
          - core-cache: Cache files for MaaCore
          - debug:      Debug files (including log and other debug files)
          - log:        Log files (both for MaaCore and maa-cli)

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa closedown
```
Close game client

Usage: maa.exe closedown [OPTIONS] [CLIENT]

Arguments:
  [CLIENT]
          [default: Official]
          [possible values: Official, Bilibili, Txwy, YoStarEN, YoStarJP, YoStarKR]

Options:
  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa complete
```
Generate completion script for given shell

Usage: maa.exe complete [OPTIONS] <SHELL>

Arguments:
  <SHELL>
          [possible values: bash, elvish, fish, powershell, zsh]

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa convert
```
Convert file format between TOML, YAML and JSON

This command will convert a file from TOML, YAML or JSON format to another format. This is useful when you want to write your infrastructure configuration in TOML or YAML format, and use it in MaaCore, which only supports JSON format.

It may also be useful when you want to migrate your cli configuration from one format to another format.

Usage: maa.exe convert [OPTIONS] <INPUT> [OUTPUT]

Arguments:
  <INPUT>
          Path of the input file

  [OUTPUT]
          Path of the output file, if not specified, the output will be printed to stdout

Options:
  -f, --format <FORMAT>
          Format of the output file, can be one of "toml", "yaml" and "json"
          
          If not specified, the format will be guessed from the file extension of the output file. If output file is not specified, the output will be default to "json".
          
          [possible values: json, yaml, toml]

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa copilot
```
Run copilot task

Usage: maa.exe copilot [OPTIONS] [URI_LIST]...

Arguments:
  [URI_LIST]...
          URI of the copilot task file
          
          It can be a maa URI or a local file path. Multiple URIs can be provided to fight multiple stages. For URI, it can be in the format of maa://<code>, maa://<code>s, file://<path>, which represents a single copilot task, a copilot task set, and a local file respectively, where file:// prefix can be omitted.

Options:
      --raid <RAID>
          Whether to fight stage in raid mode
          
          normal for normal, raid for raid, both to run twice for both modes.
          
          Also accepts legacy values 0, 1, and 2.

          Possible values:
          - normal: Run the stage in normal mode only
          - raid:   Run the stage in raid mode only
          - both:   Run the stage twice, once in each mode
          
          [default: normal]

      --formation
          Enable auto formation
          
          When multiple uri are provided or a copilot task set contains multiple stages, force to true. Otherwise, default to false.

      --formation-index <FORMATION_INDEX>
          Select which formation to use (1-4)
          
          If not provided, use the current formation

      --add-trust
          Fill empty slots by ascending trust value during auto formation

      --ignore-requirements
          

      --use-sanity-potion
          Use sanity potion to restore sanity when it's not enough

      --support-unit-usage <SUPPORT_UNIT_USAGE>
          Support operator usage mode.
          
          Effective only when formation is true. Available modes:
          
          - 0: Do not use support operators (default).
          - 1: Use support operator only if exactly one operator is missing; otherwise, do not use support.
          - 2: Use support operator if one is missing; otherwise, use the specified one.
          - 3: Use support operator if one is missing; otherwise, use a random one.

      --support-unit-name <SUPPORT_UNIT_NAME>
          Use given support unit name, don't use support unit if not provided

      --loop-times <LOOP_TIMES>
          Loop times

  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa dir
```
Print path of maa directories

This command will print the path used by maa-cli. Some of these paths are used by maa-core and maa-run.

Usage: maa.exe dir [OPTIONS] <DIR>

Arguments:
  <DIR>
          Possible values:
          - data:       Directory of maa-cli's data
          - library:    Directory of maa-cli's dynamic library
          - config:     Directory of maa-cli's config
          - cache:      Directory of maa-cli's cache
          - resource:   Directory of MaaCore's resource
          - hot-update: Directory of MaaCore's hot update
          - log:        Directory of MaaCore's log

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa fight
```
Run fight task

Usage: maa.exe fight [OPTIONS] [STAGE]

Arguments:
  [STAGE]
          Stage to fight, e.g. 1-7, leave empty to fight current/last stage

Options:
  -m, --medicine <MEDICINE>
          Number of medicine (Sanity Potion) used to fight, default to 0

      --expiring-medicine <EXPIRING_MEDICINE>
          Number of expiring medicine (Sanity Potion) used to fight, default to 0

      --stone <STONE>
          Number of stone (Originite Prime) used to fight, default to 0

      --times <TIMES>
          Exit after fighting given times, default to infinite

  -D, --drops <DROPS>
          Exit after collecting given number of drops, default to no limit
          
          Example: -D30012=100 to exit after get 100 Orirock Cube, 30012 is the item ID of Orirock Cube, you can find it at item_index.json. You can specify multiple drops, by repeating this option, e.g. -D30012=100 -D30011=100 to exit after get 100 Orirock or 100 Orirock Cube.

      --series <SERIES>
          Repeat times of single proxy combat (-1 ~ 6), default to 1
          
          - -1: disable switching series,
          - 0: automatically switch to the maximum number of series currently available, if the current sanity is less than 6 times, select the minimum number of times available,
          - 1 ~ 6: uee the specified number of times (default to 1).

      --report-to-penguin
          Whether report drops to the Penguin Statistics

      --penguin-id <PENGUIN_ID>
          Penguin Statistics ID to report drops, leave empty to report anonymously

      --report-to-yituliu
          Whether report drops to the yituliu

      --yituliu-id <YITULIU_ID>
          Yituliu ID to report drops, leave empty to report anonymously

      --client-type <CLIENT_TYPE>
          Client type used to restart the game client if game crashed
          
          [possible values: Official, Bilibili, Txwy, YoStarEN, YoStarJP, YoStarKR]

      --dr-grandet
          Whether to use Originites like Dr. Grandet
          
          In DrGrandet mode, Wait in the using Originites confirmation screen until the 1 point of sanity has been restored and then immediately use the Originite.

  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa hot-update
```
Hot update for resource

This command will update hot updateable resource by fetch git repository MaaResource. Note: the basic resource installed with maa-core will not be updated.

The remote of can be configured in the config file of maa-cli.

Usage: maa.exe hot-update [OPTIONS]

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa import
```
Import configuration files from a local path or a remote URL

This command allows you to import various types of configuration files into the `maa-cli`
config directory. It can be used to add new tasks, profiles, and other configurations.

Usage: maa.exe import [OPTIONS] <SRC>

Arguments:
  <SRC>
          The source of the configuration file to be imported
          
          This can be a local file path or a remote HTTP(S) URL.
          
          When importing from a URL, be sure to only use trusted sources. The file will be downloaded and placed in your configuration directory.
          
          If you are importing from a URL that does not have a clear filename in the path (e.g., a URL with query parameters), you should use the --name option to specify a filename for the imported configuration.
          
          When importing a local file that is a symbolic link, the contents of the target file will be copied, not the link itself.

Options:
  -n, --name <NAME>
          The desired name for the imported configuration file.
          
          If not specified, the filename will be derived from the source path or URL. This is particularly useful when importing from a URL that doesn't have a clear filename.

  -f, --force
          Force the import operation even if a file with the same name already exists.
          
          For CLI-read configurations, this also applies to files with the same stem but a different extension.

  -t, --config-type <CONFIG_TYPE>
          The category of the configuration file, which determines its storage location and validation rules

          Possible values:
          - cli:             CLI configuration file
          - profile:         Assistant/Profile configuration
          - task:            Task configuration
          - infrast:         Infrastructure configuration
          - resource:        Resource configuration
          - copilot:         Copilot configuration
          - sss-copilot:     SSSCopilot configuration
          - paradox-copilot: ParadoxCopilot configuration
          
          [default: task]

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa init
```
Initialize configurations for maa-cli

Usage: maa.exe init [OPTIONS]

Options:
  -n, --name <NAME>
          Name of the profile
          
          The name of the profile to initialize. If not specified, the default profile will be initialized.

  -f, --format <FORMAT>
          Format of the configuration file
          
          The type of the configuration file to save can be one of "toml", "yaml" and "json". If not specified, default to "json".
          
          [possible values: json, yaml, toml]

      --force
          Force to initialize even if the profile already exists

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa install
```
Install maa maa_core and resources

This command will install maa-core and resources by downloading prebuilt packages. Note: If the maa-core and resource are already installed, please update them by maa-cli update. Note: If you want to install maa-run, please use maa-cli self install.

Usage: maa.exe install [OPTIONS] [CHANNEL]

Arguments:
  [CHANNEL]
          Channel to download prebuilt package
          
          There are three channels of maa-core prebuilt packages, stable, beta and alpha. The default channel is stable, you can use this flag to change the channel. If you want to use the latest features of maa-core, you can use beta or alpha channel. You can also configure the default channel in the cli configure file $MAA_CONFIG_DIR/cli.toml with the key maa_core.channel. Note: the alpha channel is only available for windows.
          
          [possible values: stable, beta, alpha]

Options:
      --no-resource
          Do not install resource
          
          By default, resources are shipped with maa-core, and we will install them when installing maa-core. If you do not want to install resource, you can use this flag to disable it. You can also configure the default value in the cli configure file $MAA_CONFIG_DIR/cli.toml with the key maa_core.component.resource; set it to false to disable installing resource by default. This is useful when you want to install maa-core only. For my own, I will use this flag to install maa-core, because I use the latest resource from github, and this flag can avoid the resource being overwritten. Note: if you use resources that too new or too old, you may encounter some problems. Use at your own risk.

  -t, --test-time <TEST_TIME>
          Time to test download speed
          
          There are several mirrors of maa-core prebuilt packages. This command will test the download speed of these mirrors, and choose the fastest one to download. This flag is used to set the time in seconds to test download speed. If test time is 0, speed test will be skipped.

      --api-url <API_URL>
          URL of api to get version information
          
          This flag is used to set the URL of api to get version information. It can also be changed by environment variable MAA_API_URL.

  -f, --force
          Force to install even if the maa and resource already exists
          
          If the maa-core and resource already exists, we will not install them again by default. If you want to install them again, please use this flag. This flag is useful when the installation is failed, and you want to install them again. If you want to update the maa-core or resource, please use maa-cli update instead.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa list
```
List all available tasks

Usage: maa.exe list [OPTIONS]

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa mangen
```
Generate man page

Usage: maa.exe mangen [OPTIONS] --path <PATH>

Options:
      --path <PATH>
          Path of the output file

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa paradoxcopilot
```
Run Paradox Simulation copilot task

Usage: maa.exe paradoxcopilot [OPTIONS] [URI_LIST]...

Arguments:
  [URI_LIST]...
          URI of the paradox copilot task file
          
          It can be a maa URI or a local file path. Multiple URIs can be provided. For URI, it can be in the format of maa://<code>, maa://<code>s, file://<path>, which represents a single copilot task, a copilot task set, and a local file respectively, where file:// prefix can be omitted.

Options:
  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa reclamation
```
Run Reclamation Algorithm task

Usage: maa.exe reclamation [OPTIONS] <THEME>

Arguments:
  <THEME>
          Theme of the reclamation algorithm
          
          - Tales: Tales Within the Sand
          
          [possible values: Tales]

Options:
  -m, --mode <MODE>
          Reclamation Algorithm task mode
          
                  0: farm prosperity points by repeatedly entering and exiting stages.
                      This task mode should only be used when no save exists.
                      Using it with an active save may result in losing your progress.
                  1: farm prosperity points by crafting tools.
                      This task mode should only be used when you already have a save and can craft certain tools.
                      It is recommend to start task from a new calculation day.
                      Using it may result in losing your progress after last calculation day.
              
          
          [default: 1]

  -C, --tools-to-craft <TOOLS_TO_CRAFT>
          Name of tool to craft in mode 1
          
          [default: 荧光棒]

      --increase-mode <INCREASE_MODE>
          Method to interactive with the add button when increasing the crafting quantity
          
          0: increase the number by clicking the button.
          1: increase the number by holding the button.
          
          [default: 0]

      --num-craft-batches <NUM_CRAFT_BATCHES>
          Number of batches in each game run, with each batch containing 99 items
          
          [default: 16]

  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa remainder
```
Get the remainder of given divisor and current date

This command is used to calculate the value of remainder. Which is may helpful to fill remainder in task condition.

Usage: maa.exe remainder [OPTIONS] <DIVISOR>

Arguments:
  <DIVISOR>
          The value of divisor

Options:
      --timezone <TIMEZONE>
          Time zone of the date

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa roguelike
```
Run rouge-like task

Usage: maa.exe roguelike [OPTIONS] <THEME>

Arguments:
  <THEME>
          Theme of the roguelike
          
          [possible values: Phantom, Mizuki, Sami, Sarkaz, JieGarden]

Options:
      --mode <MODE>
          Mode of the roguelike
          
          0: mode for score; 1: mode for ingots; 2: combination of 0 and 1, deprecated; 3: mode for pass, not implemented yet; 4: mode that exist after 3rd floor; 5: mode for collapsal paradigms, only for Sami, use with expected_collapsal_paradigms
          
          [default: 0]

      --squad <SQUAD>
          Squad to start with in Chinese, e.g. "指挥分队" (default), "后勤分队"

      --core-char <CORE_CHAR>
          Starting core operator in Chinese, e.g. "维什戴尔"

      --roles <ROLES>
          Starting operators recruitment combination in Chinese, e.g. "取长补短", "先手必胜" (default)

      --starts-count <STARTS_COUNT>
          Stop after given count, if not given, never stop

      --difficulty <DIFFICULTY>
          Difficulty, not valid for Phantom theme (no numerical difficulty)
          
          If the given difficulty is larger than the maximum difficulty of the theme, it will be capped to the maximum difficulty. If not given, 0 will be used.

      --disable-investment
          Disable investment

      --investment-with-more-score
          Try to gain more score in investment mode
          
          By default, some actions will be skipped in investment mode to save time. If this option is enabled, try to gain exp score in investment mode.

      --investments-count <INVESTMENTS_COUNT>
          Stop exploration investment reaches given count

      --no-stop-when-investment-full
          Do not stop exploration when investment is full

      --use-support
          Use support operator

      --use-nonfriend-support
          Use non-friend support operator

      --start-with-elite-two
          Start with elite two

      --only-start-with-elite-two
          Only start with elite two

      --stop-at-final-boss
          Stop exploration before final boss

      --refresh-trader-with-dice
          Whether to refresh trader with dice (only available in Mizuki theme)

      --use-foldartal
          Whether to use Foldartal in Sami theme

  -F, --start-foldartals <START_FOLDARTALS>
          A list of expected Foldartal to be started with

  -P, --expected-collapsal-paradigms <EXPECTED_COLLAPSAL_PARADIGMS>
          A list of expected collapsal paradigms

      --start-with-seed
          Whether to start with seed, only available in Sarkaz theme and mode 1

  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa run
```
Run a custom task

All arguments will be passed to maa-run, type --help to get more information. The task is defined in the config directory of maa-cli, you can use maa dir config to get the path of config directory, and then create a directory named tasks in it. In the tasks directory, you can create a TOML or JSON file, to define a task. More information can be found in the README. You can also use maa-cli list to list all available tasks.

Usage: maa.exe run [OPTIONS] <TASK>

Arguments:
  <TASK>
          Name of the task to run
          
          The task name is the name of the task file without the extension. The task file must be in the tasks directory of the config directory. The task file must be in the TOML, YAML or JSON format.

Options:
  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa self
```
Manage maa-cli self

This command is used to manage maa-cli self and maa-run. Note: If you want to install or update maa-core and resource, please use maa-cli install or maa-cli update instead.

Usage: maa.exe self [OPTIONS] <COMMAND>

Commands:
  update  Update maa-cli self
  help    Print this message or the help of the given subcommand(s)

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa self-update
```
maa.exe : error: unrecognized subcommand 'self-update'
At line:1 char:1035
+ ... version"); foreach ($c in $cmds) { $h = & $maa $c --help 2>&1 | Out-S ...
+                                             ~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (error: unrecogn...d 'self-update':String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 

  tip: some similar subcommands exist: 'hot-update', 'self'

Usage: maa.exe [OPTIONS] <COMMAND>

For more information, try '--help'.
```

## maa sscopilot
```
maa.exe : error: unrecognized subcommand 'sscopilot'
At line:1 char:1035
+ ... version"); foreach ($c in $cmds) { $h = & $maa $c --help 2>&1 | Out-S ...
+                                             ~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (error: unrecogn...and 'sscopilot':String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 

  tip: some similar subcommands exist: 'complete', 'copilot', 'ssscopilot'

Usage: maa.exe [OPTIONS] <COMMAND>

For more information, try '--help'.
```

## maa startup
```
Startup Game and Enter Main Screen

Usage: maa.exe startup [OPTIONS] [CLIENT_TYPE]

Arguments:
  [CLIENT_TYPE]
          [possible values: Official, Bilibili, Txwy, YoStarEN, YoStarJP, YoStarKR]

Options:
      --account-name <ACCOUNT_NAME>
          

  -a, --addr <ADDR>
          ADB serial number of device or MaaTools address set in PlayCover
          
          By default, MaaCore connects to game with ADB,
          and this parameter is the serial number of the device
          (default to `emulator-5554` if not specified here and not set in config file).
          And if you want to use PlayCover,
          you need to set the connection type to PlayCover in the config file
          and then you can specify the address of MaaTools here.

  -p, --profile <PROFILE>
          Profile (asst config file) name
          
          A profile is a config file that contains the configuration passed to MaaCore.
          By default, we will try to load the config file `$MAA_CONFIG_DIR/profiles/default.toml`.
          If the file does not exist, we will try to load the config file `$MAA_CONFIG_DIR/asst.toml`
          for backward compatibility, which is the old config file name.
          If you want to use another config file, you can specify the profile name here.
          The config file should be placed in the directory `$MAA_CONFIG_DIR/profiles/`.

      --user-resource
          Load resources from the config directory
          
          By default, MaaCore loads resources from the resource installed with MaaCore.
          If you want to modify some configuration of MaaCore or you want to use your own resources,
          you can use this option to load resources from the `resource` directory,
          which is a subdirectory of the config directory.
          
          This option can also be enabled by setting the value of the key `user_resource` to true
          in the asst configure file `$MAA_CONFIG_DIR/asst.toml`.
          
          Note:
          CLI will load resources shipped with MaaCore firstly,
          then some client specific or platform specific when needed,
          lastly, it will load resources from the config directory.
          MaaCore will overwrite the resources loaded before,
          if there are some resources with the same name.
          Use at your own risk!

      --dry-run
          Parse the your config but do not connect to the game
          
          This option is useful when you want to check your config file.
          It will parse your config file and set the log level to debug.
          If there are some errors in your config file,
          it will print the error message and exit.

      --no-summary
          Do not display task summary
          
          By default, maa will display task summary after all tasks are finished.
          If you want to disable this behavior, you can use this option.

      --no-auto-reconnect
          Do not reconnect when game loses connection to server
          
          By default, maa will automatically reconnect when the game client
          loses connection to the game server. Use this option to
          disable this behavior for this run.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa update
```
Update maa maa_core and resources

This command will update maa-core and resources by downloading prebuilt packages. If the version of maa-core is not newer, we will not update it. Note: If the maa-core and resource are not installed, please install them by maa-cli install.

Usage: maa.exe update [OPTIONS] [CHANNEL]

Arguments:
  [CHANNEL]
          Channel to download prebuilt package
          
          There are three channels of maa-core prebuilt packages, stable, beta and alpha. The default channel is stable, you can use this flag to change the channel. If you want to use the latest features of maa-core, you can use beta or alpha channel. You can also configure the default channel in the cli configure file $MAA_CONFIG_DIR/cli.toml with the key maa_core.channel. Note: the alpha channel is only available for windows.
          
          [possible values: stable, beta, alpha]

Options:
      --no-resource
          Do not install resource
          
          By default, resources are shipped with maa-core, and we will install them when installing maa-core. If you do not want to install resource, you can use this flag to disable it. You can also configure the default value in the cli configure file $MAA_CONFIG_DIR/cli.toml with the key maa_core.component.resource; set it to false to disable installing resource by default. This is useful when you want to install maa-core only. For my own, I will use this flag to install maa-core, because I use the latest resource from github, and this flag can avoid the resource being overwritten. Note: if you use resources that too new or too old, you may encounter some problems. Use at your own risk.

  -t, --test-time <TEST_TIME>
          Time to test download speed
          
          There are several mirrors of maa-core prebuilt packages. This command will test the download speed of these mirrors, and choose the fastest one to download. This flag is used to set the time in seconds to test download speed. If test time is 0, speed test will be skipped.

      --api-url <API_URL>
          URL of api to get version information
          
          This flag is used to set the URL of api to get version information. It can also be changed by environment variable MAA_API_URL.

      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

## maa version
```
Print version of given component

This command will print the version of given component. If no component is given, it will print the version of all components.

Usage: maa.exe version [OPTIONS] [COMPONENT]

Arguments:
  [COMPONENT]
          [default: all]
          [possible values: all, maa-cli, maa-core]

Options:
      --batch
          Enable batch mode
          
          If there are some input parameters in the task file, some prompts will be displayed to ask for input. In batch mode, the prompts will be skipped, and parameters will be set to default values.

  -v, --verbose...
          Increase verbosity, repeat for more verbosity

  -q, --quiet...
          Decrease verbosity, repeat for more quiet

      --log-file[=<PATH>]
          Redirect log to file instead of stderr
          
          If no log file is specified, the log will be written to $(maa dir log)/YYYY/MM/DD/HH:MM:SS.log.

  -h, --help
          Print help (see a summary with '-h')
```

