# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "active_admin", to: "active_admin.js", preload: true
pin "trumbowyg_init", to: "trumbowyg_init.js", preload: true