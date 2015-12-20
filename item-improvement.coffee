path = require 'path-extra'

# Shortcuts and Components
window._ = require 'underscore'
window.$ = (param) -> document.querySelector(param)
window.$$ = (param) -> document.querySelectorAll(param)
window.React = require 'react'
window.ReactDOM = require 'react-dom'
window.ReactBootstrap = require 'react-bootstrap'
window.FontAwesome = require 'react-fontawesome'

# Node modules
window.config = remote.require './lib/config'

# language setting
window.language = config.get 'poi.language', navigator.language


# Custom theme
window.theme = config.get 'poi.theme', '__default__'
window.isDarkTheme = /(dark|black|slate|superhero|papercyan)/i.test theme
if theme == '__default__'
  $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/components/bootstrap/dist/css/bootstrap.css"
else
  $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/assets/themes/#{theme}/css/#{theme}.css"
window.addEventListener 'theme.change', (e) ->
  window.theme = e.detail.theme
  if theme == '__default__'
    $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/components/bootstrap/dist/css/bootstrap.css"
  else
    $('#bootstrap-css')?.setAttribute 'href', "file://#{ROOT}/assets/themes/#{theme}/css/#{theme}.css"

# i18n configure
window.i18n = {}
window.i18n.main = new(require 'i18n-2')
  locales: ['en-US', 'ja-JP', 'zh-CN']
  defaultLocale: 'zh-CN'
  directory: path.join(__dirname,  'i18n')
  updateFiles: false
  indent: "\t"
  extension: '.json'
  devMode: false
i18n.main.setLocale(window.language)
window.i18n.resources = {}
window.i18n.resources.__ = (str) -> return str
window.i18n.resources.translate = (locale, str) -> return str
window.i18n.resources.setLocale = (str) -> return

require 'coffee-react/register'
require './views'
