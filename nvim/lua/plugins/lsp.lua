-- lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ansiblels = {
        settings = {
          ansible = {
            ansible = {
              path = "ansible", -- path to ansible executable
            },
            executionEnvironment = {
              enabled = false,
            },
            python = {
              interpreterPath = "python3",
            },
            validation = {
              enabled = true,
              lint = {
                enabled = true,
                path = "ansible-lint",
              },
            },
          },
        },
      },
      bashls = {
        settings = {
          bashIde = {
            globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
          },
        },
      },
      powershell_es = {
        bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      },
      systemd_lsp = {},
      markdown_oxide = {},
      yamlls = {
        on_init = function(client)
          client.server_capabilities.documentFormattingProvider = true
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            format = { enable = true },
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
              kubernetes = "*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
              ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
              ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
              ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
              ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
              ["http://json.schemastore.org/docker-compose"] = "docker-compose.{yml,yaml}",
            },
          },
        },
      },
      helm_ls = {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      },
      tofu_ls = {},
      gopls = {},
      golangci_lint_ls = {
        init_options = {
          command = {
            "golangci-lint",
            "run",
            "--output.text.path=",
            "--output.tab.path=",
            "--output.html.path=",
            "--output.checkstyle.path=",
            "--output.junit-xml.path=",
            "--output.teamcity.path=",
            "--output.sarif.path=",
            "--show-stats=false",
            "--output.json.path=stdout",
          },
        },
      },
      ruby_lsp = {
        init_options = {
          formatter = "auto",
        },
      },
      eslint = {
        settings = {
          validate = "on",
          packageManager = nil,
          useESLintClass = false,
          experimental = {},
          codeActionOnSave = {
            enable = false,
            mode = "all",
          },
          format = true,
          quiet = false,
          onIgnoredFiles = "off",
          rulesCustomizations = {},
          run = "onType",
          problems = {
            shortenToSingleLine = false,
          },
          nodePath = "",
          workingDirectory = { mode = "auto" },
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine",
            },
            showDocumentation = {
              enable = true,
            },
          },
        },
      },
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      },
      phpactor = {},
      awk_ls = {},
      docker_language_server = {},
      graphql = {},
      html = {
        init_options = {
          provideFormatter = true,
          embeddedLanguages = { css = true, javascript = true },
          configurationSection = { "html", "css", "javascript" },
        },
      },
      java_language_server = {},
      jinja_lsp = {},
      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
            codeLens = { enable = true },
            hint = { enable = true, semicolon = "Disable" },
          },
        },
      },
      postgres_lsp = {},
      puppet = {},
      sqlls = {},
      basics_ls = {
        settings = {
          buffer = {
            enable = true,
            minCompletionLength = 4,
          },
          path = {
            enable = true,
          },
          snippet = {
            enable = false,
            sources = {},
          },
        },
      },
    },
  },
}
